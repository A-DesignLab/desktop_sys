from odoo import http, exceptions
from odoo.http import request

class SalaryRulesController(http.Controller):

    @http.route('/create_salary_rule', type='json', auth='user')
    def create_salary_rule(self, **rec):
        if request.get_json_data():
            if rec['name']:
                vals = {
                    'name': rec['name'],
                    'code': rec['code'],
                    'category_id': rec['category_id'],
                    'sequence': rec['sequence'],
                    'amount_python_compute': rec['condition_python'],
                }
                new_rule = request.env['hr.salary.rule'].sudo().create(vals)
                return {'success': True, 'message': 'Salary rule created successfully!', 'salary_rule_id': new_rule.id}

    @http.route(['/get_salary_rule'], type='json', website=True, auth="user")
    def get_salary_rule(self):
        rule_ids = request.env['hr.salary.rule'].sudo().search([])
        rules = []
        for rec in rule_ids:
            vals = {
                "rule name": rec.name,
                "id": rec.ids,
            }
            rules.append(vals)
        data = {'status': 200, 'response': rules, 'message': 'Success'}
        return data

    @http.route('/delete_salary_rule', type='json', auth='user', methods=['POST'])
    def delete_rule(self, **kwargs):
        try:
            salary_id = kwargs.get('id')

            if salary_id:
                # Check if the user has the necessary permissions to delete employees
                if request.env.user.has_group('hr.group_hr_manager'):
                    # Delete the employee
                    rule = request.env['hr.salary.rule'].browse(int(salary_id))
                    if rule:
                        rule.sudo().unlink()
                        return {'message': 'Salary rule deleted successfully'}
                    else:
                        return {'error': 'Salary rule not found'}
                else:
                    return {'error': 'Permission denied'}
            else:
                return {'error': 'Salary rule ID is required'}
        except exceptions.AccessError as e:
            return {'error': 'Access denied'}
        except Exception as e:
            return {'error': str(e)}