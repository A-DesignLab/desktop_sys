from odoo import http, fields, _
from odoo.http import request
from datetime import datetime
from dateutil.relativedelta import relativedelta
import pytz


class HrAttendanceAPI(http.Controller):

    @http.route('/create_attendance', type='json', auth='user', methods=['POST'])
    def create_attendance(self, **kwargs):
        try:
            employee_id = self.get_employee_dic(kwargs['employee_id'])
            if 'error' in employee_id:
                return employee_id  # Return the error dictionary directly

            check_in_time = kwargs.get('check_in_time')
            check_out_time = kwargs.get('check_out_time')

            if not check_in_time or not check_out_time:
                return {'error': 'Check-in and check-out times are required'}

            # Convert times to UTC
            check_in = datetime.strptime(check_in_time, '%Y-%m-%d %H:%M:%S')
            check_out = datetime.strptime(check_out_time, '%Y-%m-%d %H:%M:%S')

            # Set the server time zone
            server_tz = pytz.timezone('Etc/GMT+3')  # Replace with your server's time zone
            check_in = check_in.astimezone(server_tz).replace(tzinfo=None)
            check_out = check_out.astimezone(server_tz).replace(tzinfo=None)

            # Create the attendance record
            attendance_data = {
                'employee_id': employee_id['employee_id'],
                'check_in': check_in,
                'check_out': check_out,
            }

            new_attendance = request.env['hr.attendance'].sudo().create(attendance_data)

            return {'success': True, 'message': 'Attendance created successfully', 'attendance_id': new_attendance.id}

        except Exception as e:
            return {'error': str(e)}

    @http.route('/update_attendance', type='json', auth='user', methods=['POST'])
    def update_attendance(self, **kwargs):
        try:
            attendance_id = kwargs.get('attendance_id')
            if not attendance_id:
                return {'error': 'Attendance ID is required'}

            # Check if the attendance record exists
            attendance_record = request.env['hr.attendance'].sudo().browse(int(attendance_id))
            if not attendance_record:
                return {'error': 'Attendance record not found'}

            # Check if the user has the necessary permissions to update attendance
            if request.env.user.has_group('hr.group_hr_manager'):
                # Convert times to UTC
                check_in_time = kwargs.get('check_in_time')
                check_out_time = kwargs.get('check_out_time')
                server_tz = pytz.timezone('Etc/GMT+3')  # Replace with your server's time zone

                if check_in_time:
                    check_in = datetime.strptime(check_in_time, '%Y-%m-%d %H:%M:%S')
                    check_in = check_in.astimezone(server_tz).replace(tzinfo=None)

                    # Check if the employee is already checked in
                    if attendance_record.check_in:
                        attendance_record.write({'check_in': check_in})

                if check_out_time:
                    check_out = datetime.strptime(check_out_time, '%Y-%m-%d %H:%M:%S')
                    check_out = check_out.astimezone(server_tz).replace(tzinfo=None)
                    attendance_record.write({'check_out': check_out})

                return {'success': True, 'message': 'Attendance updated successfully'}
            else:
                return {'error': 'Permission denied'}

        except Exception as e:
            return {'error': str(e)}

    @http.route('/get_employee_attendance', type='json', auth='user', methods=['POST'])
    def get_employee_attendance(self, **kwargs):
        try:
            start_date = kwargs.get('start_date')
            end_date = kwargs.get('end_date')
            employee_id = self.get_employee(kwargs['employee_id'])

            if employee_id and start_date and end_date:
                # Parse start_date and end_date into datetime objects
                start_datetime = fields.Datetime.from_string(start_date)
                end_datetime = fields.Datetime.from_string(end_date)

                # Fetch the attendance records for the specified employee_id and period
                attendance_records = request.env['hr.attendance'].sudo().search([
                    ('employee_id', '=', int(employee_id)),
                    ('check_in', '>=', start_datetime),
                    ('check_out', '<=', end_datetime),
                ])

                # Extract relevant information from attendance records
                result = []
                for attendance in attendance_records:
                    result.append({
                        'check_in': attendance.check_in,
                        'check_out': attendance.check_out,
                        'diffrence_hours': attendance.diffrence_hours,
                        'employee_id': attendance.employee_id.id,
                    })

                return {'attendance_records': result}

            else:
                return {'error': 'Employee ID, start_date, and end_date are required'}

        except EmployeeNotFoundError as e:
            return {'error': str(e)}

    @http.route('/get_attendance', type='json', auth='user', methods=['GET'])
    def get_attendance(self, **rec):
        attendance_ids = request.env['hr.attendance'].sudo().search([])
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

    @http.route('/get_goal_hours_sum', type='json', auth='user', methods=['POST'])
    def get_goal_hours_sum(self, **kwargs):
        try:
            employee_id = self.get_employee_dic(kwargs['employee_id'])
            if 'error' in employee_id:
                return employee_id
            # Get the current month and year
            today = datetime.now()
            start_date = today.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            end_date = (start_date + relativedelta(months=1, days=-1)).replace(hour=23, minute=59, second=59)

            # Fetch the attendance records for the specified employee_id and current month
            attendance_records = request.env['hr.attendance'].sudo().search([
                ('employee_id', '=', employee_id['employee_id']),
                ('check_in', '>=', start_date),
                ('check_out', '<=', end_date),
            ])

            # Calculate the sum of goal_hours
            goal_hours_sum = sum(attendance.goal_hours for attendance in attendance_records)

            return {'goal_hours_sum': "{:.2f}".format(goal_hours_sum)}

        except Exception as e:
            return {'error': str(e)}

    @http.route('/delete_attendance', type='json', auth='user', methods=['POST'])
    def delete_attendance(self, **kwargs):
        try:
            attendance_id = kwargs.get('attendance_id')
            if not attendance_id:
                return {'error': 'Attendance ID is required'}

            # Check if the attendance record exists
            attendance_record = request.env['hr.attendance'].sudo().browse(int(attendance_id))
            if not attendance_record:
                return {'error': 'Attendance record not found'}

            # Delete the attendance record
            attendance_record.unlink()

            return {'success': True, 'message': 'Attendance deleted successfully'}

        except Exception as e:
            return {'error': str(e)}

    def get_employee_dic(self, employee_name):
        # Check if the employee already exists
        existing_employee = request.env['hr.employee'].sudo().search([('name', '=', employee_name)])
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
