from odoo import http, exceptions
from odoo.http import request

class GroupsAPI(http.Controller):

    @http.route('/groups_info', type='json', auth='user', methods=['GET'])
    def get_group_information(self):
        try:
            # Fetch all groups in the database
            groups = request.env['res.groups'].search([])

            group_info = []
            for group in groups:
                group_info.append({
                    'groups_id': group.id,
                    'name': group.name,
                })

            return group_info

        except Exception as e:
            return {'error': str(e)}

