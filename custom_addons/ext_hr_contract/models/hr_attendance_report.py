from odoo import api, fields, models

class HRAttendanceReport(models.Model):
    _inherit = 'hr.attendance.report'

    bonus_hours = fields.Float("Bonus Hours", readonly=True)
    deduct_hours = fields.Float("Deduct Hours", readonly=True)

    # def _join(self):
    #     return """
    #         LEFT JOIN hr_employee ON hr_employee.id = hra.employee_id
    #         LEFT JOIN hr_attendance_ ot
    #             ON hra.ot_check = 1
    #             AND ot.employee_id = hra.employee_id
    #             AND ot.date = hra.check_in
    #             AND ot.adjustment = FALSE
    #     """