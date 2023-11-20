from odoo import _, api, fields, models


class HrContract(models.AbstractModel):
    _inherit = "hr.contract"
    _description = 'Employee Contract'

    gov_fees = fields.Monetary(string="Gov Fees Allowance", help="Gov Fees")
    substance = fields.Monetary(string="Substance", help="Substance")