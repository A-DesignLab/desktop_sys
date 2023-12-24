from odoo import http, fields
from datetime import datetime
from odoo.http import request, Response
from odoo.exceptions import UserError, ValidationError
import logging
_logger = logging.getLogger(__name__)
import pytz


class PayslipController(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    def _check_employee(self, emp_id):
        check_emp = None
        contract = None
        structure_id = None
        if emp_id:
            check_emp = request.env['hr.employee'].sudo().search([('id', '=', emp_id)])
            if not check_emp:
                raise UserError("Employee Not Found")
            contract = check_emp.contract_ids.filtered(lambda c: c.state == 'open')
            if not contract:
                raise UserError("Employee Don't Have Any Running Contract")
            structure_id = contract.struct_id.id
        return {'emp': check_emp, 'contract': contract, 'struct_id': structure_id}

    @http.route('/get_payslip', type='json', website=True, auth="public", csrf=True)
    def get_payslip(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({'api_token': "API Token is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            payslip_ids = request.env['hr.payslip'].with_user(current_user).search([])
            payslip = []
            for rec in payslip_ids:
                vals = {
                    "employee_name": rec.employee_id.name,
                    "payslip_name": rec.name,
                    "state": rec.state,
                    "payslip_id": rec.id
                }
                payslip.append(vals)
            data = {'status': 200, 'message': 'Payslip Data', 'response': payslip}
            return data

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/create_payslip', type='json', methods=['POST'], auth="public", csrf=True)
    def create_payslip(self, **rec):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({'api_token': "API Token is required !!!"})
            if not data.get("employee_id", ''):
                error_list.append({"employee_id": "Employee field is required !!!"})
            if not data.get("date_from", ''):
                error_list.append({"date_from": "Date From field is required !!!"})
            if not data.get("date_to", ''):
                error_list.append({"date_to": "Date To field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            employee_id = int(data.get('employee_id'))
            check_emp = self._check_employee(employee_id)
            date_from = datetime.strptime(data.get('date_from'), '%Y-%m-%d')
            date_to = datetime.strptime(data.get('date_to'), '%Y-%m-%d')
            if date_to < date_from:
                raise UserError("Payslip 'Date From' must be earlier 'Date To'")
            vals = {
                'employee_id': check_emp.get('emp').id,
                'date_from': date_from,
                'date_to': date_to,
                'contract_id': check_emp.get('contract').id or "",
                'struct_id': check_emp.get('struct_id') or ""
            }
            new_payslip = request.env['hr.payslip'].with_user(current_user).create(vals)
            new_payslip.onchange_employee()
            work_line_ids = []
            for work_lines in new_payslip.worked_days_line_ids:
                work_line_ids.append({
                    'id': work_lines.id,
                    'name': work_lines.name,
                    'code': work_lines.code,
                    'numbers_of_days': work_lines.number_of_days,
                    'numbers_of_hours': work_lines.number_of_hours
                })
            args = {'success': True,
                    'message': 'Payslip Created Successfully of %s' % new_payslip.employee_id.name,
                    'payslip_id': new_payslip.id,
                    'date_from': new_payslip.date_from,
                    'date_to': new_payslip.date_to,
                    'payslip_name': new_payslip.name,
                    'struct_id': new_payslip.struct_id.id,
                    'struct_name': new_payslip.struct_id.name,
                    'worked_days_line_ids': work_line_ids
                    }
            return args

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/compute_salary_slip', type='json', auth='public', methods=['POST'], csrf=True)
    def compute_salary_slip(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({'api_token': "API Token is required !!!"})
            if not data.get('payslip_id', ''):
                error_list.append({'payslip_id': "Payslip ID is required !!!"})
            if error_list:
                Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            payslip_ids = request.env['hr.payslip'].with_user(current_user).search([('id', '=', data.get('payslip_id'))])
            if not payslip_ids:
                Response.status = "400"
                return {"error": "Payslip Not found !!!"}
            payslip_ids.with_user(current_user).compute_sheet()
            salary_lines = []
            details_by_salary_rule_category = []
            for salary_computation in payslip_ids.line_ids:
                salary_lines.append({
                    'id': salary_computation.id,
                    'name': salary_computation.name,
                    'code': salary_computation.code,
                    'category_id': salary_computation.category_id.id,
                    'category_name': salary_computation.category_id.name,
                    'quantity': salary_computation.quantity,
                    'rate': salary_computation.rate,
                    'salary_rule_id': salary_computation.salary_rule_id.id,
                    'salary_rule_name': salary_computation.salary_rule_id.name,
                    'amount': salary_computation.amount,
                    'total': salary_computation.total
                })
            for details_salary in payslip_ids.details_by_salary_rule_category:
                details_by_salary_rule_category.append({
                    'id': details_salary.id,
                    'category_id': details_salary.category_id.id,
                    'category_name': details_salary.category_id.name,
                    'code': details_salary.code,
                    'total': details_salary.total
                })
            return {'success': True,
                    'message': 'Salary slip computed successfully',
                    'payslip_id': payslip_ids.id,
                    'payslip_name': payslip_ids.name,
                    'payslip_number': payslip_ids.number,
                    'salary_lines': salary_lines,
                    'details_rules_category_lines': details_by_salary_rule_category}

        except Exception as e:
            return {'error': str(e)}

    @http.route('/change_payslip_state', type='json', auth="public", methods=['POST'], csrf=True)
    def change_payslip_state(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get('api_token', ''):
                error_list.append({'api_token': "Token is required !!!"})
            if not data.get("payslip_id", ''):
                error_list.append({"payslip_id": "payslip_id field is required !!!"})
            if not data.get("state", ''):
                error_list.append({"state": "state field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            # Retrieve the payslip record
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            payslip = request.env['hr.payslip'].sudo().search([('id', '=', (data.get("payslip_id")))])
            if not payslip:
                # Response.status = "400"
                return {"message": "Payslip not found"}

            # Check if the requested state is valid
            states = dict(request.env['hr.payslip'].fields_get(allfields=['state'])['state']['selection'])
            state_list = list(states.keys())
            state = data.get('state')
            if state not in state_list:
                # Response.status = "400"
                return {'message': 'Invalid payslip state', 'States Available': state_list}

            # Update the payslip state
            payslip.with_user(current_user).write({'state': state})
            return {'success': True, 'message': f'Payslip state changed to {state}'}

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/send_to_first_approve', type='json', auth='public', methods=['POST'], csrf=True)
    def send_to_first_approve(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get('api_token', ''):
                error_list.append({'api_token': "Token is required !!!"})
            if not data.get("payslip_id", ''):
                error_list.append({"payslip_id": "Payslip ID field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            payslip = request.env['hr.payslip'].sudo().search([('id', '=', data.get("payslip_id")), ('state', '=', "draft")])
            if not payslip:
                # Response.status = "400"
                return {"message": "Payslip not found Either it's Already send to admin approve !!!"}
            payslip.with_user(current_user).action_send_to_admin_approve()
            return {'success': True, 'message': f'Payslip Send To Admin Approve Successfully'}

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/send_to_second_approve', type='json', auth='public', methods=['POST'], csrf=True)
    def send_to_second_approve(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get('api_token', ''):
                error_list.append({'api_token': "Token is required !!!"})
            if not data.get("payslip_id", ''):
                error_list.append({"payslip_id": "Payslip ID field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            payslip = request.env['hr.payslip'].sudo().search([('id', '=', (data.get("payslip_id"))), ('state', '=', "first_approve")])
            if not payslip:
                # Response.status = "400"
                return {"message": "Payslip not found Either it's Already send to Super Admin approve !!!"}
            payslip.with_user(current_user).action_send_to_super_admin()
            return {'success': True, 'message': f'Payslip Send To Super Admin Approve Successfully'}

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/confirm_payslip', type='json', auth='public', methods=['POST'], csrf=True)
    def confirm_payslip(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get('api_token', ''):
                error_list.append({'api_token': "Token is required !!!"})
            if not data.get("payslip_id", ''):
                error_list.append({"payslip_id": "Payslip ID field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            payslip = request.env['hr.payslip'].sudo().search([('id', '=', (data.get("payslip_id"))), ('state', '=', 'second_approve')])
            if not payslip:
                # Response.status = "400"
                return {"message": "Payslip not found Either it's Already Confirmed !!!"}
            payslip.with_user(current_user).action_payslip_done()
            return {'success': True, 'message': f'Payslip Confirmed Successfully'}

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/excel_report', type='json', auth='public', methods=['POST'], csrf=True)
    def generate_excel_report(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get('api_token', ''):
                error_list.append({'api_token': "Token is required !!!"})
            if not data.get('employee_id', ''):
                error_list.append({'employee_id': "Employee ID is required !!!"})
            if not data.get('start_date', ''):
                error_list.append({'start_date': "Start Date is required !!!"})
            if not data.get('end_date', ''):
                error_list.append({'end_date': "End Date is required !!!"})
            if error_list:
                Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            check_emp = request.env['hr.employee'].sudo().search([('id', 'in', data.get('employee_id'))])
            check_in = datetime.strptime(data.get('start_date'), '%Y-%m-%d')
            check_out = datetime.strptime(data.get('end_date'), '%Y-%m-%d')
            # Set the server time zone
            user_tz = current_user.tz
            tz = pytz.timezone(user_tz)
            check_in = tz.localize(check_in).astimezone(pytz.utc).replace(tzinfo=None)
            check_out = tz.localize(check_out).astimezone(pytz.utc).replace(tzinfo=None)
            if not check_emp:
                # Response.status = "400"
                return {"error": "Employee Not Found !!!"}
            vals = {
                'employee_id': check_emp.ids,
                'end_date': check_out,
                'start_date': check_in,
            }
            generate_excel_report = request.env['employee.payslip.report'].with_user(current_user).create(vals)
            # Call the print_report method from EmployeePayslipReport
            excel_report = generate_excel_report.print_report()
            if excel_report:
                find_excel_report = request.env['employee.payslip.excel.report'].sudo().search([('id', '=', excel_report['res_id'])])
                args = {'success': True, 'message': 'Employee Payslip Report Generated',
                        "date_from": check_in, "date_to": check_out,
                        "file_name": find_excel_report.file_name, "excel_file": find_excel_report.excel_file}
                return args

        except Exception as e:
            _logger.info("Error Message : %s" % str(e))
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/delete_payslip', type='json', auth='public', methods=['POST'], csrf=True)
    def delete_payslip(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get("payslip_id", ''):
                error_list.append({'payslip_id': "Contract Field is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}

            payslip = request.env['hr.payslip'].with_user(current_user).search([('id', '=', data.get('payslip_id'))])
            if payslip:
                details = {'payslip_id': payslip.id, 'payslip_name': payslip.name}
                payslip.with_user(current_user).unlink()
                return {'message': 'Payslip deleted successfully', "Details": details}
            else:
                # Response.status = "400"
                return {'error': 'Payslip not found'}

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}