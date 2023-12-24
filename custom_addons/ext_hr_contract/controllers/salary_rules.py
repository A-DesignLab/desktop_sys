from odoo import http, exceptions
from odoo.http import request, Response


class SalaryRulesController(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/create_salary_rule', type='json', auth='public', methods=['POST'], csrf=True)
    def create_salary_rule(self):
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
            if request.get_json_data():
                vals = {
                    'name': data.get('name'),
                    'code': data.get('code'),
                    'category_id': data.get('category_id'),
                    'sequence': data.get('sequence'),
                    'amount_python_compute': data.get('condition_python'),
                }
                new_rule = request.env['hr.salary.rule'].with_user(current_user).create(vals)
                return {'success': True, 'message': 'Salary rule created successfully!', 'salary_rule_id': new_rule.id}

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route(['/get_salary_rule'], type='json', website=True, auth="public", methods=['GET'], csrf=True)
    def get_salary_rule(self):
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
            rule_ids = request.env['hr.salary.rule'].with_user(current_user).search([])
            rules = []
            for rec in rule_ids:
                vals = {
                    "rule name": rec.name,
                    "id": rec.ids,
                }
                rules.append(vals)
            data = {'status': 200, 'response': rules, 'message': 'Success'}
            return data
        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/delete_salary_rule', type='json', auth='public', methods=['POST'], csrf=True)
    def delete_rule(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("salary_id", ''):
                error_list.append({'salary_id': "Salary Field is required !!!"})
            if error_list:
                Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            if request.get_json_data():
                if data.get('salary_id'):
                    rule = request.env['hr.salary.rule'].browse(int(data.get('salary_id')))
                    if rule:
                        rule.with_user(current_user).unlink()
                        return {'message': 'Salary rule deleted successfully'}

        except Exception as e:
            return {'error': str(e)}