from odoo import http, exceptions
from odoo.http import request, Response

class GroupsAPI(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/groups_info', type='json', auth='public', methods=['GET'], csrf=True)
    def get_group_information(self):
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
                return {"error": "Access Denied !!! Please Provide Vaild Token"}
            # Fetch all groups in the database
            groups = request.env['res.groups'].with_user(current_user).search([])

            group_info = []
            for group in groups:
                group_info.append({
                    'groups_id': group.id,
                    'name': group.name,
                })

            return group_info

        except Exception as e:
            Response.status = "400"
            return {"status": "failed", "error": str(e)}

