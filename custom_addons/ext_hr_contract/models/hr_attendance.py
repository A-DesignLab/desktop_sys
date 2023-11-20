# -*- coding:utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.

from odoo import api, fields, models
from datetime import datetime
from dateutil import relativedelta


class ExtendHrAttendance(models.Model):
    _inherit = 'hr.attendance'
    total_hours = fields.Float(related='employee_id.resource_calendar_id.hours_per_day', string="Working Hours")
    diffrence_hours = fields.Float(string="Difference Hours", compute='_compute_difference_hours')
    goal_hours = fields.Float(string="Goal Hours", compute='_compute_goal_hours')

    def _compute_difference_hours(self):
        self.diffrence_hours = None
        for rec in self:
            diffrence_hours = rec.worked_hours - 8
            rec.diffrence_hours = diffrence_hours

    def _compute_goal_hours(self):
        self.goal_hours = None
        for rec in self:
            if rec.diffrence_hours > 0:
                goal_hours = rec.worked_hours - rec.diffrence_hours
                rec.goal_hours = goal_hours
            else:
                rec.goal_hours = rec.worked_hours