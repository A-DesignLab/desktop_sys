from odoo import http
from odoo.http import request


class DepartmentController(http.Controller):
    @http.route(['/get_company'], type='json', website=True, auth="user")
    def show_company(self):
        company_ids = request.env['res.company'].sudo().search([])
        company = []
        for rec in company_ids:
            vals = {
                "Company name": rec.name,
                "id": rec.id,
            }
            company.append(vals)
        data = {'status': 200, 'response': company, 'message': 'Success'}
        return data

    @http.route(['/get_department'], type='json', website=True, auth="user")
    def show_department(self):
        department_ids = request.env['hr.department'].sudo().search([])
        department = []
        for rec in department_ids:
            vals = {
                "Department name": rec.name,
                "id": rec.id,
            }
            department.append(vals)
        data = {'status': 200, 'response': department, 'message': 'Success'}
        return data

    @http.route(['/create_department'], type='json', auth="user")
    def create_department(self, **rec):
        if request.get_json_data():
            if rec['name']:
                vals = {
                    'name': rec['name']
                }
                new_department = request.env['hr.department'].sudo().create(vals)
                args = {'success': True, 'message': 'Success', 'id': new_department.id}
        return args

    # @http.route(['/update_department'], type='json', auth="user")
    # def update_department(self, **rec):
    #     if request.get_json_data():
    #         if rec['id']:
    #             department = request.env['hr.department'].sudo().search([('id', '=', rec['id'])])
    #             if department:
    #                 department.sudo().write(rec)
    #             args = {'success': True, 'message': 'Success update'}
    #     return args

    @http.route(['/update_department'], type='json', auth="user")
    def update_department(self, **rec):
        args = {'success': False, 'message': 'Invalid request'}

        if request.get_json_data():
            if rec.get('id'):
                department = request.env['hr.department'].sudo().search([('id', '=', rec['id'])])
                if department:
                    # Check if 'parent_id' is in the record and call the function if true
                    if 'parent_id' in rec:

                        rec['parent_id'] = self.get_or_create_parent_department(rec['parent_id'])

                    department.sudo().write(rec)
                    args = {'success': True, 'message': 'Success update'}
                else:
                    args['message'] = 'Department not found'

        return args

    def get_or_create_parent_department(self, parent_id):
        # Implement your logic here to get or create the parent department
        # For example:
        parent_department = request.env['hr.department'].sudo().search([('name', '=', parent_id)])
        if parent_department:
            return parent_department.id
        else:
            new_parent_department = request.env['hr.department'].sudo().create({'name': parent_id})
            return new_parent_department.id
