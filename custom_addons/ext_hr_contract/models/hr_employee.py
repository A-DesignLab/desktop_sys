# -*- coding: utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.
from odoo import _, api, fields, models


class HrEmployeeBaseExtend(models.AbstractModel):
    _inherit = "hr.employee.base"

    employee_type = fields.Selection(selection_add=[
        ('worker', 'Worker')
    ], ondelete={'worker': 'cascade'},
    )
