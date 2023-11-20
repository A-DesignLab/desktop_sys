import json
from odoo import http, exceptions
from odoo.http import request

class SalaryStructureController(http.Controller):

    @http.route('/create_salary_struc', type='json', auth='user', methods=['POST'])
    def create_salary_struc(self, **rec):
        if request.get_json_data():
            if rec['name']:
                vals = {
                    'name': rec['name'],
                    'code': rec['code'],
                    'rule_ids': rec['rule_ids'],
                }
                new_struc = request.env['hr.payroll.structure'].sudo().create(vals)
                return {'success': True, 'message': 'Salary Structure created successfully!', 'salary_structure_id': new_struc.id}

    @http.route(['/get_salary_struc'], type='json', website=True, auth="user", methods=['GET'])
    def get_salary_struc(self):
        struc_ids = request.env['hr.payroll.structure'].sudo().search([])
        structure = []
        for rec in struc_ids:
            vals = {
                "structure name": rec.name,
                "id": rec.id,
            }
            structure.append(vals)
        data = {'status': 200, 'response': structure, 'message': 'Success'}
        return data

    @http.route('/delete_salary_struc', type='json', auth='user', methods=['POST'])
    def delete_struc(self, **kwargs):
        try:
            structure_id = kwargs.get('id')

            if structure_id:
                # Check if the user has the necessary permissions to delete employees
                if request.env.user.has_group('hr.group_hr_manager'):
                    # Delete the employee
                    structure = request.env['hr.payroll.structure'].browse(int(structure_id))
                    if structure:
                        structure.sudo().unlink()
                        return {'message': 'Salary structure deleted successfully'}
                    else:
                        return {'error': 'Salary structure not found'}
                else:
                    return {'error': 'Permission denied'}
            else:
                return {'error': 'Salary structure ID is required'}
        except exceptions.AccessError as e:
            return {'error': 'Access denied'}
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

