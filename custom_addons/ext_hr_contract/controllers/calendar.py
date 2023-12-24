from odoo import http, exceptions
from odoo.http import request, Response

class ResourceCalendarAPI(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/get_resource_calendars', type='json', auth='public', methods=['GET'], csrf=True)
    def get_resource_calendars(self):
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
            resource_calendars = request.env['resource.calendar'].with_user(current_user).search([])
            calendar = []
            for rec in resource_calendars:
                vals = {
                    "calendar_name": rec.name,
                    "id": rec.ids,
                }
                calendar.append(vals)
            data = {'status': 200, 'message': 'Resource Calendars Details', 'response': calendar}
            return data

        except Exception as e:
            Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/delete_resource_calendar', type='json', auth='public', methods=['POST'], csrf=True)
    def delete_res_calendar(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("resource_id", ''):
                error_list.append({"resource_id": "Resource Field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            resource = request.env['resource.calendar'].with_user(current_user).browse(int(data.get("resource_id")))
            related_records_company = request.env['res.company'].with_user(current_user).search([('resource_calendar_id', '=', int(resource.id))])
            related_records_company.with_user(current_user).write({'resource_calendar_id': False})

            if resource:
                resource.with_user(current_user).unlink()
                return {'message': 'Resource Calendar deleted successfully'}
            else:
                return {'error': 'Resource calendar not found'}

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}