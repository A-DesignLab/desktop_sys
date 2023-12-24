from odoo import http
from odoo.http import request, Response


class DepartmentController(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/get_company', type='json', website=True, auth='public', methods=['GET'], csrf=True)
    def get_company(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if error_list:
                Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            company_ids = request.env['res.company'].with_user(current_user).search([])
            company = []
            for rec in company_ids:
                vals = {
                    "company_name": rec.name,
                    "company_id": rec.id,
                }
                company.append(vals)
            data = {'status': 200, 'message': 'All Company Details', 'response': company}
            return data

        except Exception as e:
            Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/get_department', type='json', website=True, auth='public', methods=['GET'], csrf=True)
    def get_department(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if error_list:
                Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            department_ids = request.env['hr.department'].with_user(current_user).search([])
            department = []
            for rec in department_ids:
                vals = {
                    "department_name": rec.name,
                    "department_id": rec.id,
                }
                department.append(vals)
            data = {'status': 200,  'message': 'All Department', 'response': department}
            return data

        except Exception as e:
            Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/create_department', type='json', methods=['POST'], auth="public", csrf=True)
    def create_department(self, **rec):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get('name'):
                error_list.append({"name": "Name Field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            vals = {
                'name': data.get('name')
            }
            new_department = request.env['hr.department'].with_user(current_user).create(vals)
            args = {'success': True, 'message': 'Department Created', 'department_id': new_department.id, 'name': new_department.name}
            return args

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/update_department', type='json', methods=['POST'], auth="public", csrf=True)
    def update_department(self, **rec):
        args = {'success': False, 'message': 'Invalid request'}
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get('id'):
                error_list.append({"id": "Department ID Field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            api_token = data.pop('api_token', None)
            id = data.pop('id', None)
            department = request.env['hr.department'].with_user(current_user).search([('id', '=', id)])
            if department:
                # Check if 'parent_id' is in the record and call the function if true
                if 'parent_id' in data:
                    data['parent_id'] = self.get_or_create_parent_department(data['parent_id'])

                department.with_user(current_user).write(data)
                args = {'success': True, 'message': 'Success update'}
            else:
                args['message'] = 'Department not found'
            return args

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/delete_department', type='json', auth='public', methods=['POST'], csrf=True)
    def delete_department(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("id", ''):
                error_list.append({'id': "department id Field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            department = request.env['hr.department'].with_user(current_user).search([('id', '=', data.get('id'))])

            if department:
                details = {'department_id': department.id, 'department_name': department.name}
                department.with_user(current_user).unlink()
                return {'message': 'department deleted successfully', "Details": details}
            else:
                # Response.status = "400"
                return {'error': 'department not found'}

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    def get_or_create_parent_department(self, parent_id):
        # Implement your logic here to get or create the parent department
        # For example:
        parent_department = request.env['hr.department'].sudo().search([('name', '=', parent_id)])
        if parent_department:
            return parent_department.id
        else:
            new_parent_department = request.env['hr.department'].sudo().create({'name': parent_id})
            return new_parent_department.id
