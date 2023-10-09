from odoo import models, fields, api

class HrAttendance(models.Model):
    _inherit = 'hr.attendance'

    bonus = fields.Float(string='Bonus', compute='_compute_bonus', store=True, readonly=True)
    deduct = fields.Float(string='Deduct', compute='_compute_deduct', store=True, readonly=True)

    @api.depends('')
    def _compute_bonus(self):
        for attendance in self:
            if attendance.overtime > 0:
                attendance.bonus = attendance.overtime
            else:
                attendance.bonus = False

    @api.depends('overtime')
    def _compute_deduct(self):
        for attendance in self:
            if attendance.overtime <= 0:
                attendance.deduct = attendance.overtime
            else:
                attendance.deduct = False