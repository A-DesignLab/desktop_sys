from odoo import models, fields

class ContractHistory(models.Model):

    _inherit = "hr.contract.history"

    gov_fees = fields.Monetary('Gov Fees', help="Employee's monthly government fees.", readonly=True, group_operator="avg")
    insurance = fields.Monetary('Insurance', help="Employee's monthly insurance.", readonly=True, group_operator="avg")
    transport = fields.Monetary('Transport', help="Employee's monthly transportation cost.", readonly=True, group_operator="avg")
    housing = fields.Monetary('Housing', help="Employee's monthly housing cost.", readonly=True, group_operator="avg")
    substance = fields.Monetary('Substance', help="Employee's monthly substance cost.", readonly=True, group_operator="avg")