import json
import jwt
from odoo import http, exceptions
from odoo.http import request

class UserRegistrationAPI(http.Controller):

    @http.route('/register', type='json', auth='none', methods=['POST'])
    def register_user(self, **kwargs):
        try:
            user_data = kwargs.get('user_data')
            requested_access_rights = kwargs.get('access_rights')  # List of access right names

            # Check if the user already exists
            existing_user = request.env['res.users'].sudo().search([
                ('login', '=', user_data['username'])
            ])

            if existing_user:
                return {'error': 'User with the same username already exists'}

            # Create a new user
            new_user = request.env['res.users'].sudo().create({
                'login': user_data['username'],
                'password': user_data['password'],
                'name': user_data['name'],
                'company_id': user_data['company'],
                'company_ids': user_data['allowed_company']
            })

            if new_user:
                # Assign requested access rights (groups) to the user
                assigned_group_ids = []
                for group_name in requested_access_rights:
                    groups = request.env['res.groups'].sudo().search([('name', '=', group_name)])
                    for group in groups:
                        assigned_group_ids.append(group.id)

                new_user.write({'groups_id': [(6, 0, assigned_group_ids)]})
                # Generate an access token for the registered user
                payload = {'user_id': new_user.id}
                secret_key = 'your_secret_key'  # Replace with a secure secret key
                access_token = jwt.encode(payload, secret_key, algorithm='HS256')
                return {'access_token': access_token}
            else:
                return {'error': 'User registration failed'}

        except Exception as e:
            return {'error': str(e)}

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

    # @http.route('/login', type='json', auth='none', methods=['POST'])
    # def login_user(self, **kwargs):
    #     try:
    #         username = kwargs.get('username')
    #         password = kwargs.get('password')
    #
    #         # Implement user authentication logic here
    #         # Verify user credentials
    #         user = request.env['res.users'].sudo().search([('login', '=', username)])
    #
    #         if user and user.sudo()._check_credentials(password):
    #             # Generate an access token for the user
    #             payload = {'user_id': user.id}
    #             secret_key = 'your_secret_key'  # Replace with a secure secret key
    #             access_token = jwt.encode(payload, secret_key, algorithm='HS256')
    #
    #             # Store the access token in the user's record
    #             user.write({'access_token': access_token})
    #
    #             return {'access_token': access_token}
    #         else:
    #             print(username, password)
    #             return {'error': 'Invalid credentials'}
    #
    #     except Exception as e:
    #         return {'error': str(e)}

    @http.route('/get_users', type='json', auth="none", methods=['GET'])
    def get_users_by_role(self):
        try:
            # Define role names to filter by
            role_names = ['Admin', 'Super Admin', 'Officer', 'Manager']

            # Fetch users with the specified roles
            users_data = []
            users = request.env['res.users'].sudo().search([])

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

    @http.route('/get_users_hr', type='json', auth="user", methods=['GET'])
    def get_users_hr(self):
        try:
            group_id = 21
            users = request.env['res.users'].sudo().search([('groups_id', 'in', [group_id])])
            data = [{'id': user.id, 'name': user.name} for user in users]
            return {'success': True, 'data': data}
        except Exception as e:
            return {'error': str(e)}



