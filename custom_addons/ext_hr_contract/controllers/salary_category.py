from odoo import http, exceptions
from odoo.http import request

class SalaryCategoryController(http.Controller):

    @http.route(['/get_salary_cat'], type='json', website=True, auth="user")
    def get_salary_cat(self):
        cat_ids = request.env['hr.salary.rule.category'].sudo().search([])
        cats = []
        for rec in cat_ids:
            vals = {
                "Category name": rec.name,
                "id": rec.id,
            }
            cats.append(vals)
        data = {'status': 200, 'response': cats, 'message': 'Success'}
        return data

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
