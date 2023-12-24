from odoo import http, fields, _
from odoo.exceptions import AccessError
from datetime import datetime
from dateutil.relativedelta import relativedelta
import pytz
from odoo.http import request, Response


class HrAttendanceAPI(http.Controller):

    def _check_user_token(self, api_token):
        current_user = False
        if api_token:
            current_user = request.env['res.users'].sudo().search([('api_token', '=', api_token)])
        return current_user

    @http.route('/create_attendance', type='json', auth='public', methods=['POST'], csrf=True)
    def create_attendance(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get('employee_id'):
                error_list.append({'employee_id': "Employee ID is required !!!"})
            if not data.get("check_in_time", ''):
                error_list.append({"check_in_time": "Check-In-Time is required !!!"})
            if not data.get("check_out_time", ''):
                error_list.append({"check_out_time": "Check-Out-Time is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            employee_id = request.env['hr.employee'].sudo().search([('id', '=', data.get('employee_id'))])
            if not employee_id:
                return {"error": "Employee Not Found !!!", "code": 400}

            # Convert times to UTC
            check_in = datetime.strptime(data.get("check_in_time"), '%Y-%m-%d %H:%M:%S')
            check_out = datetime.strptime(data.get("check_out_time"), '%Y-%m-%d %H:%M:%S')

            # Set the server time zone
            user_tz = current_user.tz
            tz = pytz.timezone(user_tz)
            check_in = tz.localize(check_in).astimezone(pytz.utc).replace(tzinfo=None)
            check_out = tz.localize(check_out).astimezone(pytz.utc).replace(tzinfo=None)
            # Create the attendance record
            attendance_data = {
                'employee_id': employee_id.id,
                'check_in': check_in,
                'check_out': check_out,
            }
            if data.get('attendance_id'):
                new_attendance = request.env['hr.attendance'].with_user(current_user).browse(int(data.get('attendance_id')))
                new_attendance.with_user(current_user).write(attendance_data)
            else:
                new_attendance = request.env['hr.attendance'].with_user(current_user).create(attendance_data)

            return {
                'success': True,
                'message': 'Attendance created / Updated successfully',
                'attendance_id': new_attendance.id,
                'employee_id': new_attendance.employee_id.id,
                'emp_name': new_attendance.employee_id.name,
                'total_hours': new_attendance.total_hours,
                'worked_hours': new_attendance.worked_hours,
                'difference_hours': new_attendance.diffrence_hours
            }

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/delete_attendance', type='json', auth='public', methods=['POST'], csrf=True)
    def delete_attendance(self, **kwargs):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get('attendance_id'):
                error_list.append({'attendance_id': "Attendance ID is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            # Check if the attendance record exists
            attendance_record = request.env['hr.attendance'].sudo().browse(int(data.get('attendance_id')))
            if not attendance_record:
                return {'error': 'Attendance record not found', "code": 400}
            values = {
                'attendance_id': attendance_record.id,
                'Name': attendance_record.employee_id.name
            }
            # Delete the attendance record
            attendance_record.with_user(current_user).unlink()

            return {'success': True,
                    'message': 'Attendance deleted successfully',
                    'value': values
                    }

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/get_employee_attendance', type='json', auth='public', methods=['GET'])
    def get_employee_attendance(self):
        data = request.get_json_data()
        error_list = []
        try:
            if not data.get("api_token", ''):
                error_list.append({"api_token": "Api Token is required !!!"})
            if not data.get('start_date'):
                error_list.append({'start_date': "Start Date is required !!!"})
            if not data.get('end_date'):
                error_list.append({'end_date': "End Date is required !!!"})
            if not data.get('employee_id'):
                error_list.append({'employee_id': "Employee ID is required !!!"})
            if error_list:
                # Response.status = "400"
                return {"code": "RequiredField", "message": "Cannot be empty", "error": error_list}
            current_user = self._check_user_token(data.get('api_token', ''))
            if not current_user:
                # Response.status = "400"
                return {"error": "Access Denied !!! Please Provide Valid Token"}
            employee_id = request.env['hr.employee'].with_user(current_user).search([('id', '=', data.get('employee_id'))])
            if not employee_id:
                return {"error": "Employee Not Found !!!", "code": 400}

            start_date = datetime.strptime(data.get('start_date'), '%Y-%m-%d')
            end_date = datetime.strptime(data.get('end_date'), '%Y-%m-%d')
            user_tz = current_user.tz
            tz = pytz.timezone(user_tz)
            check_in = tz.localize(start_date).astimezone(pytz.utc).replace(tzinfo=None)
            check_out = tz.localize(end_date).astimezone(pytz.utc).replace(tzinfo=None)
            attendance_records = request.env['hr.attendance'].with_user(current_user).search([
                ('employee_id', '=', int(data.get('employee_id'))),
                ('check_in', '>=', check_in),
                ('check_out', '<=', check_out),
            ])
            if not attendance_records:
                # Response.status = "400"
                return {"error": "Attendance Records Not Found !!!"}
            # Extract relevant information from attendance records
            result = []
            for attendance in attendance_records:
                result.append({
                    'attendance_id': attendance.id,
                    'check_in': attendance.check_in,
                    'check_out': attendance.check_out,
                    'difference_hours': attendance.diffrence_hours,
                    'employee_id': attendance.employee_id.id,
                    'emp_name': attendance.employee_id.name,
                    'total_hours': attendance.total_hours,
                    'worked_hours': attendance.worked_hours,
                })

            return {
                'success': True,
                'message': 'Attendance Data',
                'results': result
            }

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/get_attendance', type='json', auth='public', methods=['GET'], csrf=True)
    def get_attendance(self, **rec):
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
            if data.get("attendance_id"):
                attendance_ids = request.env['hr.attendance'].with_user(current_user).search([('id', '=', data.get("attendance_id"))])
            else:
                attendance_ids = request.env['hr.attendance'].with_user(current_user).search([])
            attendance = []
            for rec in attendance_ids:
                vals = {
                    "check_in": rec.check_in,
                    "check_out": rec.check_out,
                    "total_hours": rec.diffrence_hours,
                    "employee": rec.employee_id.name,
                    "id": rec.id,
                }
                attendance.append(vals)
            data = {'status': 200, 'response': attendance, 'message': 'Success'}
            return data

        except Exception as e:
            Response.status = "400"
            return {"status": "failed", "error": str(e)}

    @http.route('/get_goal_hours_sum', type='json', auth='public', methods=['GET'], csrf=True)
    def get_goal_hours_sum(self, **kwargs):
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
            employee_id = self.get_employee_dic(data.get('employee_id'))
            if 'error' in employee_id:
                # Response.status = 400
                return employee_id
            # Get the current month and year
            today = datetime.now()
            start_date = today.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            end_date = (start_date + relativedelta(months=1, days=-1)).replace(hour=23, minute=59, second=59)

            # Fetch the attendance records for the specified employee_id and current month
            attendance_records = request.env['hr.attendance'].with_user(current_user).search([
                ('employee_id', '=', employee_id['employee_id']),
                ('check_in', '>=', start_date),
                ('check_out', '<=', end_date),
            ])

            # Calculate the sum of goal_hours
            goal_hours_sum = sum(attendance.goal_hours for attendance in attendance_records)

            return {'goal_hours_sum': "{:.2f}".format(goal_hours_sum)}

        except Exception as e:
            # Response.status = "400"
            return {"status": "failed", "error": str(e)}

    def get_employee_dic(self, employee_id):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('id', '=', employee_id)])
        if existing_employee:
            return {'employee_id': existing_employee.id}
        else:
            # return employee not exist
            return {'error': 'Employee ID deos not exist'}

    def get_employee(self, employee_name):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])
        if existing_employee:
            return existing_employee.id
        else:
            # return employee not exist
            # Raise an exception with a custom error message
            raise EmployeeNotFoundError('Employee not found')


class EmployeeNotFoundError(Exception):
    pass