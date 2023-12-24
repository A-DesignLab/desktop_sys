import json
from odoo import http, exceptions
from odoo.http import request

class SalaryStructureController(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/create_salary_struc', type='json', auth='public', methods=['POST'])
    def create_salary_struc(self, **rec):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if error_list:
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            vals = {
                'name': data.get('name'),
                'code': data.get('code'),
                'rule_ids': data.get('rule_ids'),
            }
            new_struc = request.env['hr.payroll.structure'].with_user(current_user).create(vals)
            return {'success': True, 'message': 'Salary Structure created successfully!', 'salary_structure_id': new_struc.id}
        except Exception as e:
            return {"status": "failed", "error": str(e)}

    @http.route(['/get_salary_struc'], type='json', website=True, auth="public", methods=['GET'])
    def get_salary_struc(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if error_list:
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            struc_ids = request.env['hr.payroll.structure'].with_user(current_user).search([])
            structure = []
            for rec in struc_ids:
                vals = {
                    "structure name": rec.name,
                    "id": rec.id,
                }
                structure.append(vals)
            data = {'status': 200, 'response': structure, 'message': 'Success'}
            return data
        except Exception as e:
            return {"status": "failed", "error": str(e)}

    @http.route('/delete_salary_struc', type='json', auth='public', methods=['POST'])
    def delete_struc(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if error_list:
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            structure_id = data.get('id')

            if structure_id:
                structure = request.env['hr.payroll.structure'].browse(int(structure_id))
                if structure:
                    structure.with_user(current_user).unlink()
                    return {'message': 'Salary structure deleted successfully'}
                else:
                    return {'error': 'Salary structure not found'}

            else:
                return {'error': 'Salary structure ID is required'}
        except Exception as e:
            return {'error': str(e)}

    @http.route("/salary_struc/add_rule", methods=["POST"], type="json", auth="public")
    def add_rule_to_structure(self, **post):
        # Extract data from the request
        structure_id = post.get("structure_id")
        rule_id = post.get("rule_id")

        # Check if the structure and rule exist
        structure = request.env["hr.payroll.structure"].sudo().browse(structure_id)
        rule = request.env["hr.salary.rule"].sudo().browse(rule_id)

        if not structure or not rule:
            return json.dumps({"error": "Invalid structure_id or rule_id"})

        # Add the rule to the structure
        structure.write({"rule_ids": [(4, rule.id, 0)]})

        # Return a JSON response
        return json.dumps({"message": "Rule added to the structure successfully"})

