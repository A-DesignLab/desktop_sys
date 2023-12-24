import json
from odoo import http, exceptions
from odoo.http import request, Response
import logging
_logger = logging.getLogger(__name__)


class UserRegistrationAPI(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    def _login_data(self, user_id, is_api=False):
        try:
            if is_api:
                base_url = request.env['ir.config_parameter'].sudo().get_param('web.base.url')
                api_token = user_id.sudo()._get_api_token()
                user_id.api_token = api_token or ""
                return {
                    "id": user_id.id,
                    "name": user_id.name,
                    "company_id": user_id.company_id.id or 0,
                    "company_name": user_id.company_id.name or "",
                    "profile_image": base_url + "/web/image/res.users/%s/image_256" % (user_id.id),
                    "email": user_id.email or '',
                    "api_token": api_token,
                }

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/login', type='json', auth='public', methods=['POST'], csrf=True)
    def login_user(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("username", ''):
                error_list.append({"username": "Username field is required !!!"})
            if not data.get("password", ''):
                error_list.append({"password": "Password field is required !!!"})
            if not data.get("db_name"):
                error_list.append({"db_name": "DB Name field is required !!!"})
            if error_list:
                Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            _logger.info("Trying to login using %s for API access" % (data.get("username", '')))
            user_id = request.session.authenticate(data.get("db_name", ''), data.get("username", ''), data.get('password'))
            if user_id:
                user_id = request.env['res.users'].sudo().browse(user_id)
                user_data = self._login_data(user_id, True)
                request.session.logout()
                _logger.info("Logged In Successfully for username %s for API access " % (data.get("username", '')))
                return {
                    "status": 200,
                    "message": "Login successfully",
                    "login_info": user_data
                }

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/sign_up', type='json', auth="public", methods=['POST'], csrf=True)
    def web_auth_signup(self):
        data = request.get_json_data()
        error_list = []
        group_ids = []
        try:
            if not data.get("login", ''):
                error_list.append({"login": "Login field is required !!!"})
            if not data.get("name", ''):
                error_list.append({"name": "Name field is required !!!"})
            if not data.get("password"):
                error_list.append({"password": "Password field is required !!!"})
            if not data.get("email"):
                error_list.append({"email": "Email field is required !!!"})
            if not data.get("mobile"):
                error_list.append({"mobile": "Mobile field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            if data.get('is_admin'):
                admin = request.env.ref('base.group_erp_manager')
                group_ids.append(admin.id)
                biling_account = request.env.ref('account.group_account_manager')
                group_ids.append(biling_account.id)
                employee = request.env.ref('hr.group_hr_manager')
                group_ids.append(employee.id)
                payroll_manager = request.env.ref('ext_hr_contract.group_hr_payroll_super_admin')
                group_ids.append(payroll_manager.id)
                holidays_manager = request.env.ref('hr_holidays.group_hr_holidays_manager')
                group_ids.append(holidays_manager.id)
            if data.get('is_officer'):
                officer = request.env.ref('hr.group_hr_user')
                group_ids.append(officer.id)
            if data.get('is_manager'):
                admin = request.env.ref('base.group_erp_manager')
                group_ids.append(admin.id)
                biling_account = request.env.ref('account.group_account_invoice')
                group_ids.append(biling_account.id)
                employee = request.env.ref('hr.group_hr_user')
                group_ids.append(employee.id)
                payroll_manager = request.env.ref('om_hr_payroll.group_hr_payroll_manager')
                group_ids.append(payroll_manager.id)
                holidays_manager = request.env.ref('hr_holidays.group_hr_holidays_manager')
                group_ids.append(holidays_manager.id)
            sign_up_data = {"login": data.get('login'), "name": data.get('name'), "password": data.get('password'), "email": data.get('email'), "mobile": data.get('mobile'), "tz":"Asia/Riyadh"}
            sign_up = request.env['res.users'].sudo().signup(sign_up_data)
            user_id = request.env['res.users'].sudo().search([('login', '=', sign_up[0])])
            if user_id:
                group_user = request.env.ref('base.group_user') or False
                group_ids.append(group_user.id)
                user_id.partner_id.sudo().write({'email': user_id.login})
                user_id.sudo().write({'active': True, 'groups_id': [(6, 0, group_ids)]})
                user_id.action_create_employee()
                return {"message": "User Created Successfully", 'user_id': user_id.id, 'name': user_id.name, 'success': True}

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/modify_access_rights', type='json', auth='user', methods=['POST'])
    def modify_access_rights(self, **kwargs):
        try:
            user_id = kwargs.get('user_id')
            access_rights = kwargs.get('access_rights')

            if user_id and access_rights:
                # Check if the user has the necessary permissions to modify access rights
                if request.env.user.has_group('base.group_system'):
                    # Update the user's access rights
                    user = request.env['res.users'].browse(int(user_id))
                    if user:
                        user.sudo().groups_id = [(6, 0, access_rights)]
                        return {'message': 'Access rights modified successfully'}
                    else:
                        return {'error': 'User not found'}
                else:
                    return {'error': 'Permission denied'}
            else:
                return {'error': 'User ID and access rights are required'}
        except exceptions.AccessError as e:
            return {'error': 'Access denied'}
        except Exception as e:
            return {'error': str(e)}

    @http.route('/get_users', type='json', auth="public", methods=['GET'], csrf=True)
    def get_users_by_role(self):
        data = request.get_json_data()
        try:
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            # Define role names to filter by
            role_names = ['Admin', 'Super Admin', 'Officer', 'Manager']

            # Fetch users with the specified roles
            users_data = []
            users = request.env['res.users'].with_user(current_user).search([])

            for user in users:
                user_roles = [group.name for group in user.groups_id]
                matching_roles = [role for role in user_roles if role in role_names]
                if matching_roles:
                    user_data = {
                        'id': user.id,
                        'name': user.name,
                        'password': user.password,
                        'username': user.login,
                        'roles': matching_roles,
                        'group_ids': user.groups_id
                    }
                    users_data.append(user_data)
            return {'status': 200, 'response': users_data}
        except Exception as e:
            return json.dumps({'error': str(e)})

    @http.route('/get_users_hr', type='json', auth="public", methods=['GET'])
    def get_users_hr(self):
        data = request.get_json_data()
        try:
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            group_id = 21
            users = request.env['res.users'].with_user(current_user).search([('groups_id', 'in', [group_id])])
            data = [{'id': user.id, 'name': user.name} for user in users]
            return {'success': True, 'data': data}
        except Exception as e:
            return {'error': str(e)}
