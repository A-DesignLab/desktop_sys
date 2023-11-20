from odoo import http, exceptions
from odoo.http import request


class ContractController(http.Controller):

    @http.route(['/get_contract'], type='json', website=True, auth="user")
    def get_contract(self):
        contract_ids = request.env['hr.contract'].sudo().search([])
        contract = []
        for rec in contract_ids:
            vals = {
                "contract name": rec.name,
                "contract id": rec.id,
                "employee_id": rec.employee_id.name,
                "Department": rec.department_id.name,
                "wage": rec.wage,
            }
            contract.append(vals)
        data = {'status': 200, 'response': contract, 'message': 'Success'}
        return data

    @http.route('/get_employee_contract', type='json', auth='user', methods=['GET'])
    def get_employee_contract(self, **kwargs):
        try:
            employee_data = self.get_employee(kwargs['employee_name'])
            employee_id = employee_data['employee_id']
            contract = employee_data['contract_id']
            contract_records = request.env['hr.contract'].sudo().search([('id', '=', contract)])

            if contract:
                # Extract relevant details from the contract
                for contract in contract_records:
                    contract_details = {
                        'employee_name': employee_id,
                        'contract_name': contract.name,
                        'wage': contract.wage,
                        'department': contract.department_id.name if contract.department_id else None,
                        'housing': contract.hra,
                        'transport': contract.travel_allowance,
                        'substance': contract.substance,
                        'gov_fees': contract.gov_fees,
                        'insurance': contract.medical_allowance
                    }

                    return {'success': True, 'contract_details': contract_details}
                else:
                    return {'error': 'No contract found for the employee'}

        except Exception as e:
            return {'error': str(e)}

    @http.route(['/create_contract'], type='json', auth="user")
    def create_contract(self, **rec):
        if request.get_json_data():
            if rec['name']:
                hr_id = self.get_or_create_hr(rec['hr'])
                employee_id, department_id = self.get_or_create_employee(rec['employee_id'], rec['department_id'])
                struct_exists = request.env['hr.payroll.structure'].sudo().search([('id', '=', rec['salary_struct'])])
                if struct_exists:
                    vals = {
                        'name': rec['name'],
                        'employee_id': employee_id,
                        'department_id': department_id,
                        'date_end': rec['end_date'],
                        'date_start': rec['start_date'],
                        'wage': rec['wage'],
                        'hr_responsible_id': hr_id,
                        'struct_id': rec['salary_struct'],
                        'hra': rec['housing'],
                        'travel_allowance': rec['transportation'],
                        'da': rec['dearness'],
                        'medical_allowance': rec['insurance'],
                        'gov_fees': rec['gov_fees'],
                        'substance': rec['substance'],
                        'other_allowance': rec['other_alw']
                    }
                    # If employee exists, assign department_id to the contract
                    if department_id:
                        vals['department_id'] = department_id
                    new_contract = request.env['hr.contract'].sudo().create(vals)
                    args = {'success': True, 'message': 'Success', 'id': new_contract.id}
                else:
                    return {'error': 'Salary Structure not found'}
        return args

    @http.route(['/update_contract'], type='json', auth="user")
    def update_contract(self, **rec):
        if request.get_json_data():
            if rec['id']:
                contract = request.env['hr.contract'].sudo().search([('id', '=', rec['id'])])
                if contract:
                    contract.sudo().write(rec)
                args = {'success': True, 'message': 'Success update'}
        return args

    @http.route('/delete_contract', type='json', auth='user', methods=['POST'])
    def delete_contract(self, **kwargs):
        try:
            contract_id = kwargs.get('contract_id')

            if contract_id:
                # Check if the user has the necessary permissions to delete employees
                if request.env.user.has_group('hr.group_hr_manager'):
                    # Delete the contract
                    contract = request.env['hr.contract'].browse(int(contract_id))
                    if contract:
                        contract.sudo().unlink()
                        return {'message': 'Contract deleted successfully'}
                    else:
                        return {'error': 'Contract not found'}
                else:
                    return {'error': 'Permission denied'}
            else:
                return {'error': 'Contract ID is required'}
        except exceptions.AccessError as e:
            return {'error': 'Access denied'}
        except Exception as e:
            return {'error': str(e)}

    def get_employee(self, employee_name):
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

    def get_or_create_employee(self, employee_name, department_name):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])

        if existing_employee:
            return existing_employee.id, existing_employee.department_id.id
        else:
            # Create a new employee
            new_department_id = self.get_or_create_department(department_name)
            new_employee = request.env['hr.employee'].sudo().create({'name': employee_name})
            return new_employee.id, new_department_id

    def get_or_create_hr(self, hr_name):
        # Check if the hr responsible already exists
        group_id = 21
        existing_hr = request.env['res.users'].sudo().search([('name', '=', hr_name)])
        if existing_hr:
            # Check if the user has group id = 21 in their assigned groups_id
            if group_id in existing_hr.groups_id.ids:
                return existing_hr.id
            else:
                # Update the groups_id to include the group with id 21
                existing_hr.write({'groups_id': [(4, group_id)]})
                return existing_hr.id
        else:
            # Create a new hr
            assigned_group_ids = [12, 8, 76, 21, 29, 15, 18, 117, 91, 115, 79, 34, 43, 45, 3, 9, 39, 19, 111, 20, 1, 13, 37, 125, 6, 112, 124, 17, 75, 14, 28, 95, 113, 110, 42, 44, 40, 7, 27, 85, 116, 114, 78, 74, 73, 90, 89]
            new_hr = request.env['res.users'].sudo().create({'name': hr_name, 'login': hr_name, 'groups_id': [(6, 0, assigned_group_ids)], 'company_id': 1, 'company_ids': [1]})
            return new_hr.id


class EmployeeNotFoundError(Exception):
    pass

