from odoo import http, exceptions
from odoo.http import request, Response

class SalaryCategoryController(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/get_salary_cat', type='json', website=True, auth="public", methods=['GET'], csrf=True)
    def get_salary_cat(self):
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

            cat_ids = request.env['hr.salary.rule.category'].with_user(current_user).search([])
            cats = []
            for rec in cat_ids:
                vals = {
                    "category_name": rec.name,
                    "category_id": rec.id,
                }
                cats.append(vals)
            data = {'status': 200, 'message': 'Salary Category', 'response': cats}

            return data

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    # @http.route('/create_salary_category', type='json', auth='user')
    # def create_salary_category(self, name):
    #     # Authenticate the user and perform necessary validations
    #
    #     # Create the new salary category
    #     salary_category = request.env['hr.salary.rule.category'].create({
    #         'name': name,
    #     })
    #
    #     return {'success': True, 'message': 'Salary category created successfully!',
    #             'salary_category_id': salary_category.id}
