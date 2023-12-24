from odoo import http, exceptions
from odoo.http import request, Response


class ContractController(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/get_contract', type='json', auth='public', methods=['GET'], csrf=True)
    def get_contract(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            contract_ids = request.env['hr.contract'].with_user(current_user).search([])
            contract = []
            for rec in contract_ids:
                vals = {
                    "contract_name": rec.name,
                    "contract_id": rec.id,
                    "employee_id": rec.employee_id.id,
                    "employee_name": rec.employee_id.name,
                    "department": rec.department_id.name,
                    "wage": rec.wage,
                    "satus": rec.state,
                }
                contract.append(vals)
            data = {'status': 200, 'message': 'Contract Info', 'response': contract}
            return data

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/get_employee_contract', type='json', auth='public', methods=['GET'], csrf=True)
    def get_employee_contract(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("employee_name", ''):
                error_list.append({'employee_name': "Employee Field is required !!!"})
            if error_list:
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}

            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            employee_data = self.get_employee(data.get('employee_name'))
            employee_id = employee_data['employee_id']
            contract_ids = employee_data['contract_ids']

            # Search for all contracts related to the employee
            contract_records = request.env['hr.contract'].with_user(current_user).search([('id', 'in', contract_ids)])

            if contract_records:
                # Extract relevant details from each contract
                contracts_details = []
                for contract in contract_records:
                    contract_details = {
                        'employee_name': data.get('employee_name'),
                        'contract_name': contract.name,
                        'contract_id': contract.id,
                        'wage': contract.wage,
                        'department': contract.department_id.name if contract.department_id else None,
                        'housing': contract.hra,
                        'transport': contract.travel_allowance,
                        'substance': contract.substance,
                        'gov_fees': contract.gov_fees,
                        'insurance': contract.medical_allowance
                    }
                    contracts_details.append(contract_details)

                return {'success': True, 'contracts_details': contracts_details}
            else:
                return {'error': 'No contracts found for the employee'}

        except Exception as e:
            return {'error': str(e)}

    @http.route('/create_contract', type='json', auth='public', methods=['POST'], csrf=True)
    def create_contract(self, **rec):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("hr", ''):
                error_list.append({'hr': "HR Field is required !!!"})
            if error_list:
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            hr_id = self.get_or_create_hr(data.get('hr'))
            employee_id, department_id, employee_type = self.get_or_create_employee(
                data.get('employee_name'), data.get('department_name'), data.get('employee_type'))
            if employee_type == 'worker':
                calendar_resource = request.env['resource.calendar'].sudo().search(
                    [('name', '=', 'Standard 48 hours/week')], limit=1)
                struct = request.env['hr.payroll.structure'].sudo().search(
                    [('name', '=', 'Worker Structure')], limit=1)
                # Set calendar_resource_id based on employee type
                resource_calendar_id = calendar_resource.id
                # Set struct_id based on employee type
                struct_id = struct.id
            else:
                calendar_resource = request.env['resource.calendar'].sudo().search(
                    [('name', '=', 'Standard 40 hours/week')], limit=1)
                struct = request.env['hr.payroll.structure'].sudo().search(
                    [('name', '=', 'Employee Structure')], limit=1)
                # Set calendar_resource_id based on employee type
                resource_calendar_id = calendar_resource.id
                # Set struct_id based on employee type
                struct_id = struct.id

            vals = {
                'name': data.get('name'),
                'employee_id': employee_id,
                'department_id': department_id,
                'date_end': data.get('end_date'),
                'date_start': data.get('start_date'),
                'wage': data.get('wage'),
                'hr_responsible_id': hr_id,
                'hra': data.get('housing'),
                'travel_allowance': data.get('transportation'),
                'medical_allowance': data.get('insurance'),
                'gov_fees': data.get('gov_fees'),
                'substance': data.get('substance'),
                'other_allowance': data.get('other_alw'),
                'resource_calendar_id': resource_calendar_id,
                'struct_id': struct_id  # Set struct_id
            }

            # If employee exists, assign department_id to the contract
            if department_id:
                vals['department_id'] = department_id

            new_contract = request.env['hr.contract'].with_user(current_user).create(vals)
            args = {'success': True, 'message': 'Success', 'id': new_contract.id}
            return args
        except Exception as e:
            return {"status": "failed", "error": str(e)}

    @http.route('/update_contract', type='json', auth='public', methods=['POST'], csrf=True)
    def update_contract(self, **rec):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("contract_id", ''):
                error_list.append({'contract_id': "Contract Field is required !!!"})
            if error_list:
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}

            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            # Extract api_token from data
            api_token = data.pop('api_token', None)
            contract_id = data.pop('contract_id', None)
            contract = request.env['hr.contract'].with_user(current_user).search([('id', '=', contract_id)])

            if contract:
                # Update the contract with the remaining data
                contract.with_user(current_user).write(data)

                args = {'success': True, 'message': 'Contract Updated Successfully'}
                return args
            else:
                return {"error": "Contract not found"}

        except Exception as e:
            return {"status": "failed", "error": str(e)}

    @http.route('/change_contract_status', type='json', auth="public", methods=['POST'], csrf=True)
    def change_contract_status(self, **rec):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("contract_id", ''):
                error_list.append({'contract_id': "Contract Field is required !!!"})
            if error_list:
                Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            # Search for the contract
            contract = request.env['hr.contract'].with_user(current_user).search([('id', '=', data.get('contract_id'))])
            if not contract:
                return {"error": "Contract not found"}

            # Update the contract status
            contract.with_user(current_user).write({'state': data.get('new_status')})

            return {"status": "success", "message": f"Contract status updated to {data.get('new_status')}"}

        except Exception as e:
            return {"status": "failed", "error": str(e)}

    @http.route('/delete_contract', type='json', auth='public', methods=['POST'], csrf=True)
    def delete_contract(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("contract_id", ''):
                error_list.append({'contract_id': "Contract Field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            contract = request.env['hr.contract'].with_user(current_user).search([('id', '=', data.get('contract_id'))])
            if contract:
                details = {'contract_id': contract.id, 'contract_name': contract.name}
                contract.with_user(current_user).unlink()
                return {'message': 'Contract deleted successfully', "Details": details}
            else:
                # Response.status = "400"
                return {'error': 'Contract not found'}

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    def get_employee(self, employee_name):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])
        if existing_employee:
            contracts = request.env['hr.contract'].sudo().search([('employee_id', '=', int(existing_employee.id))])
            return {'employee_id': existing_employee.id, 'contract_ids': contracts.ids}
        else:
            # return employee not exist
            # Raise an exception with a custom error message
            raise EmployeeNotFoundError('Employee not found')

    def get_or_create_employee(self, employee_name, department_name, employee_type):
        try:
            # Search for an existing employee based on the name
            existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])

            if existing_employee:
                # If the employee exists, return their id, department id, and employee type
                return existing_employee.id, existing_employee.department_id.id, existing_employee.employee_type

            else:
                if department_name:
                    existing_department = request.env['hr.department'].sudo().search([('name', '=', department_name)])
                    if existing_department:
                        # Create a new employee with the provided name and employee type
                        new_employee = request.env['hr.employee'].sudo().create(
                            {'name': employee_name, 'department_id': existing_department.id,
                             'employee_type': employee_type})
                        return new_employee.id, existing_department.id, new_employee.employee_type
                    else:
                        # Create a new department
                        new_department = request.env['hr.department'].sudo().create({'name': department_name})
                        new_department_id = new_department.id  # Get the id attribute
                        # Create a new employee with the provided name and employee type
                        new_employee = request.env['hr.employee'].sudo().create(
                            {'name': employee_name, 'department_id': new_department_id, 'employee_type': employee_type, 'tz': 'Asia/Riyadh'})
                        return new_employee.id, new_department_id, new_employee.employee_type
                else:
                    return {'error': str(e)}
        except Exception as e:
            # Handle any exceptions that may occur during the process
            return {'error': str(e)}

    def get_or_create_hr(self, hr_name):
        # Check if the hr responsible already exists
        group_id = 21
        existing_hr = request.env['res.users'].sudo().search([('name', '=', hr_name)])
        if existing_hr:
            # Check if the user has group id = 21 in their assigned groups_id
            if group_id in existing_hr.groups_id.ids:
                return existing_hr.id
            else:
                # Update the groups_id to include the group with id 21
                existing_hr.write({'groups_id': [(4, group_id)]})
                return existing_hr.id
        else:
            # Create a new hr
            assigned_group_ids = [12, 8, 18, 29, 15, 32, 21, 39, 41, 9, 31, 1, 13, 24, 34, 6, 33, 28, 14, 17, 36, 7, 16, 27, 26]
            new_hr = request.env['res.users'].sudo().create({'name': hr_name, 'login': hr_name, 'groups_id': [(6, 0, assigned_group_ids)], 'company_id': 1, 'company_ids': [1]})
            return new_hr.id


class EmployeeNotFoundError(Exception):
    pass

