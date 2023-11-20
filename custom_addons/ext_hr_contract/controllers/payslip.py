from odoo import http, fields
from odoo.http import request


class PayslipController(http.Controller):

    @http.route(['/get_payslip'], type='json', website=True, auth="user")
    def get_payslip(self):
        payslip_ids = request.env['hr.payslip'].sudo().search([])
        payslip = []
        for rec in payslip_ids:
            vals = {
                "Employee name": rec.employee_id.name,
                "Payslip Name": rec.name
            }
            payslip.append(vals)
        data = {'status': 200, 'response': payslip, 'message': 'Success'}
        return data

    @http.route(['/create_payslip'], type='json', auth="user")
    def create_payslip(self, **rec):
        if request.get_json_data():
            if rec['name']:
                vals = {
                    'name': rec['name'],
                    'employee_id': rec['employee_id'],
                    'date_from': rec['date_from'],
                    'date_to': rec['date_to'],
                    'contract_id': rec['contract_id']
                }
                new_payslip = request.env['hr.payslip'].sudo().create(vals)
                args = {'success': True, 'message': 'Success', 'id': new_payslip.id}
        return args

    @http.route('/compute_salary_slip', type='json', auth='user', methods=['POST'])
    def compute_salary_slip(self, **kwargs):
        try:
            employee_data = self.get_employee_contract(kwargs['employee_id'])
            # Additional parameters for payslip name, date_from, and date_to
            employee_id = employee_data['employee_id']
            date_from = kwargs.get('date_from', fields.Date.today())
            date_to = kwargs.get('date_to')
            fixed_bonus = kwargs.get('fixed_bonus')
            slip_data = request.env['hr.payslip'].onchange_employee_id(date_from, date_to, employee_id,
                                                                       contract_id=False)

            # Fetch the employee's attendance records
            attendance = request.env['hr.attendance'].sudo().search([('employee_id', '=', employee_id)])

            # Create a list to store worked_days_line data
            worked_days_lines = []

            # Populate worked_days_lines with data from attendance
            for record in attendance:
                worked_days_lines.append((0, 0, {
                    'name': record.employee_id,  # Replace with the actual field name in hr.attendance
                    'number_of_days': record.number_of_days,
                    'number_of_hours': record.number_of_hours,
                    'contract_id': record.contract_id.id,  # Replace with the actual field in hr.attendance
                    'sequence': record.sequence,  # Replace with the actual field in hr.attendance
                }))

            # Create a new payslip with additional parameters
            payslip_data = {
                'employee_id': employee_id,
                'contract_id': slip_data['value'].get('contract_id'),
                'struct_id': slip_data['value'].get('struct_id'),
                'name': slip_data['value'].get('name'),
                'date_from': date_from,
                'date_to': date_to,
                'credit_note': slip_data['value'].get('credit_note'),
                'employee_bonus': fixed_bonus,
                'worked_days_line_ids': worked_days_lines,
                'company_id': employee_id.company_id.id,
            }

            new_payslip = request.env['hr.payslip'].sudo().create(payslip_data)

            # Compute the salary slip
            new_payslip.compute_sheet()

            return {'success': True, 'message': 'Salary slip computed successfully', 'payslip_id': new_payslip.id}

        except Exception as e:
            return {'error': str(e)}

    def get_employee(self, employee_name):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])
        if existing_employee:
            return existing_employee.id
        else:
            # Return an error dictionary
            return {'error': 'Employee ID does not exist'}

    def get_employee_dic(self, employee_name):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])
        if existing_employee:
            return {'employee_id': existing_employee.id}
        else:
            # return employee not exist
            return {'error': 'Employee ID deos not exist'}
    def get_employee_contract(self, employee_name):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])
        # .filtered(lambda c: c.state == 'draft')
        if existing_employee:
            # Check if the employee has an active contract
            contract = existing_employee.contract_ids.filtered(lambda c: c.state == 'open')

            if contract:
                return {'employee_id': existing_employee.id, 'contract_id': contract.id}
            else:
                raise EmployeeNotFoundError('Employee does not have an active contract')
        else:
            # return employee not exist
            # Raise an exception with a custom error message
            raise EmployeeNotFoundError('Employee not found')


class EmployeeNotFoundError(Exception):
    pass
