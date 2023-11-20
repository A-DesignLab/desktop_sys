from odoo import http, exceptions
from odoo.http import request


class EmployeeController(http.Controller):
    @http.route(['/get_employee'], type='json', website=True, auth="user")
    def get_employee(self):
        employee_ids = request.env['hr.employee'].sudo().search([])
        employee = []
        for rec in employee_ids:
            vals = {
                "Employee name": rec.name,
                "id": rec.id,
                "Department": rec.department_id.name,
                "Job": rec.job_id.name
            }
            employee.append(vals)
        data = {'status': 200, 'response': employee, 'message': 'Success'}
        return data

    @http.route(['/create_employee'], type='json', auth="user")
    def create_employee(self, **rec):
        if request.get_json_data():
            if rec['name']:
                job_id = self.get_or_create_job_pos(rec['job_position'])
                dep_id = self.get_or_create_department(rec['department_id'])
                vals = {
                    'name': rec['name'],
                    'department_id': dep_id,
                    'employee_type': rec['employee_type'],
                    # 'resource_calendar_id': rec['stander_hours'],
                    'tz': rec['time_zone'],
                    'job_id': job_id,
                }
                existing_employee = request.env['hr.employee'].sudo().search([
                    ('name', '=', vals['name'])
                ])

                if existing_employee:
                    return {'error': 'Employee with the same name already exists'}
                else:
                    new_employee = request.env['hr.employee'].sudo().create(vals)
                    args = {'success': True, 'message': 'Success', 'id': new_employee.id}
        return args

    def get_or_create_job_pos(self, job_name):
        # Check if the job already exists
        existing_job = request.env['hr.job'].sudo().search([('name', '=', job_name)])

        if existing_job:
            return existing_job.id
        else:
            # Create a new job position
            new_job = request.env['hr.job'].sudo().create({'name': job_name})
            return new_job.id

    def get_or_create_department(self, dep_name):
        # Check if the department already exists
        existing_dep = request.env['hr.department'].sudo().search([('name', '=', dep_name)])

        if existing_dep:
            return existing_dep.id
        else:
            # Create a new department
            new_dep = request.env['hr.department'].sudo().create({'name': dep_name})
            return new_dep.id

    @http.route(['/update_employee'], type='json', auth="user")
    def update_employee(self, **rec):
        if request.get_json_data():
            if rec['id']:
                employee = request.env['hr.employee'].sudo().search([('id', '=', rec['id'])])
                if employee:
                    employee.sudo().write(rec)
                args = {'success': True, 'message': 'Success update'}
        return args

    @http.route('/delete_employee', type='json', auth='user', methods=['POST'])
    def delete_employee(self, **kwargs):
        try:
            employee_id = kwargs.get('employee_id')

            if employee_id:
                # Check if the user has the necessary permissions to delete employees
                if request.env.user.has_group('hr.group_hr_manager'):
                    request.env['hr.leave'].sudo().search([('employee_id', '=', int(employee_id))]).unlink()
                    request.env['hr.payslip'].sudo().search([('employee_id', '=', int(employee_id))]).unlink()
                    # Delete the employee
                    employee = request.env['hr.employee'].browse(int(employee_id))
                    if employee:
                        employee.sudo().unlink()
                        return {'message': 'Employee deleted successfully'}
                    else:
                        return {'error': 'Employee not found'}
                else:
                    return {'error': 'Permission denied'}
            else:
                return {'error': 'Employee ID is required'}
        except exceptions.AccessError as e:
            return {'error': 'Access denied'}
        except Exception as e:
            return {'error': str(e)}