from odoo import http, exceptions
from odoo.http import request

class ResourceCalendarAPI(http.Controller):

    @http.route('/get_resource_calendars', type='json', auth='public', methods=['GET'])
    def get_resource_calendars(self):
        try:
            resource_calendars = request.env['resource.calendar'].search([])
            calendar = []
            for rec in resource_calendars:
                vals = {
                    "calendar name": rec.name,
                    "id": rec.ids,
                }
                calendar.append(vals)
            data = {'status': 200, 'response': calendar, 'message': 'Success'}

            return data
        except Exception as e:
            return {'success': False, 'error': str(e)}

    @http.route('/delete_resource_calendar', type='json', auth='user', methods=['POST'])
    def delete_res_calendar(self, **kwargs):
        try:
            resource_id = kwargs.get('resource_id')

            if resource_id:
                # Check if the user has the necessary permissions to delete resource calendar
                if request.env.user.has_group('hr.group_hr_manager'):
                    # Delete the resource calendar
                    resource = request.env['resource.calendar'].browse(int(resource_id))
                    related_records_company = request.env['res.company'].search([('resource_calendar_id', '=', int(resource_id))])
                    related_records_company.write({'resource_calendar_id': False})
                    # related_records = request.env['hr.contract'].search([('resource_calendar_id', '=', int(resource_id))])
                    # for record in related_records:
                    #     if record.resource_calendar_id:  # Check if resource_calendar_id is not already NULL
                    #         record.write({'resource_calendar_id': False})
                    if resource:
                        resource.sudo().unlink()
                        return {'message': 'Resource Calendar deleted successfully'}
                    else:
                        return {'error': 'Resource calendar not found'}
                else:
                    return {'error': 'Permission denied'}
            else:
                return {'error': 'Resource ID is required'}
        except exceptions.AccessError as e:
            return {'error': 'Access denied'}
        except Exception as e:
            return {'error': str(e)}
