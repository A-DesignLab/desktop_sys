from odoo import http, exceptions
from odoo.http import request, Response
import logging
_logger = logging.getLogger(__name__)


class EmployeeController(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/get_employee', type='json', website=True, methods=['GET'], auth="public", csrf=True)
    def get_employee(self):
        if request.get_json_data():
            data = request.get_json_data()
            error_list = []
            try:
                if not data.get('api_token'):
                    error_list.append({"api_token": "API Token is required !!!"})
                if error_list:
                    Response.status = "400"
                    return {"code": "RequiredField", "Error": error_list}
                current_user = self._check_user_token(data.get('api_token', ''))
                if not current_user:
                    Response.status = "400"
                    return {"error": "Access Denied !!! Please Provide Valid Token"}
                employee_ids = request.env['hr.employee'].with_user(current_user).search([])
                employee = []
                for rec in employee_ids:
                    vals = {
                        "employee_name": rec.name,
                        "employee_id": rec.id,
                        "department": rec.department_id.name,
                        "job": rec.job_id.name
                    }
                    employee.append(vals)
                data = {'status': 200, 'message': 'All Employee Details', 'response': employee}
                return data

            except Exception as e:
                _logger.info("Error Message : %s" % str(e))
                Response.status = "400"
                return {"status": "failed", "error": str(e)}

    @http.route('/create_employee', type='json', methods=['POST'], auth="public", csrf=True)
    def create_employee(self, **rec):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get('api_token'):
                error_list.append({"api_token": "API Token is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "Error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            employee_type = data.get('employee_type')
            if data.get('name'):
                if employee_type == 'worker':
                    calendar_resource = request.env['resource.calendar'].sudo().search(
                        [('name', '=', 'Standard 48 hours/week')], limit=1)
                else:
                    calendar_resource = request.env['resource.calendar'].sudo().search(
                        [('name', '=', 'Standard 40 hours/week')], limit=1)
                job_id = self.get_or_create_job_pos(data.get('job_position'))
                dep_id = self.get_or_create_department(data.get('department_id'))
                vals = {
                    'name': data.get('name'),
                    'department_id': dep_id,
                    'employee_type': data.get('employee_type'),
                    'resource_calendar_id': calendar_resource.id,
                    'tz': 'Asia/Riyadh',
                    'job_id': job_id,
                }
                existing_employee = request.env['hr.employee'].with_user(current_user).search([
                    ('name', '=', data.get('name'))
                ])

                if existing_employee:
                    # Response.status = "400"
                    return {'error': 'Employee with the same name already exists'}
                else:
                    new_employee = request.env['hr.employee'].with_user(current_user).create(vals)
                    args = {'success': True, 'message': 'Employee Created', 'id': new_employee.id}
                    return args

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/update_employee', type='json', auth="public", methods=['POST'], csrf=True)
    def update_employee(self, **rec):
        if request.get_json_data():
            data = request.get_json_data()
            error_list = []
            try:
                if not data.get('api_token'):
                    error_list.append({"api_token": "API Token is required !!!"})
                if not data.get('employee_id'):
                    error_list.append({"employee_id": "Employee ID field is required !!!"})
                if error_list:
                    # Response.status = "400"
                    return {"code": "RequiredField", "Error": error_list}
                current_user = self._check_user_token(data.get('api_token', ''))
                if not current_user:
                    # Response.status = "400"
                    return {"error": "Access Denied !!! Please Provide Valid Token"}
                employee = request.env['hr.employee'].with_user(current_user).search([('id', '=', data.get('employee_id'))])
                data.pop('api_token')
                data.pop('employee_id')
                if employee:
                    employee.with_user(current_user).write(data)
                    return {'success': True, 'message': 'Employee Updated Successfully', "id": employee.id, "Name": employee.name}
                else:
                    # Response.status = "400"
                    return {'success': False, 'message': 'Employee Not Found !!!'}

            except Exception as e:
                _logger.info("Error Message : %s" % str(e))
                # Response.status = "400"
                return {"status": "failed", "error": str(e)}

    @http.route('/delete_employee', type='json', auth='public', methods=['POST'], csrf=True)
    def delete_employee(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("employee_id", ''):
                error_list.append({'employee_id': "Employee Field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            employee = request.env['hr.employee'].with_user(current_user).search([('id', '=', data.get('employee_id'))])
            if employee:
                details = {'employee_id': employee.id, 'employee_name': employee.name}
                employee.with_user(current_user).unlink()
                return {'message': 'Employee deleted successfully', "Details": details}
            else:
                # Response.status = "400"
                return {'error': 'Employee not found'}

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

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