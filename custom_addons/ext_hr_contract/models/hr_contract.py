from odoo import models, fields, api

class Contract(models.Model):
    _inherit = "hr.contract"


    transport = fields.Monetary('Transport', required=False, tracking=True, help="Employee's monthly transportation cost.")
    contract_transport = fields.Monetary("Contract Transport", compute='_compute_contract_transport')
    housing = fields.Monetary('Housing', required=False, tracking=True, help="Employee's monthly housing cost.")
    contract_housing = fields.Monetary("Contract Housing", compute='_compute_contract_housing')
    insurance = fields.Monetary('Insurance', required=False, tracking=True, help="Employee's monthly insurance cost.")
    contract_insurance = fields.Monetary("Contract Insurance", compute='_compute_contract_insurance')
    substance = fields.Monetary('Substance', required=False, tracking=True, help="Employee's monthly substance cost.")
    contract_substance = fields.Monetary("Contract Substance", compute='_compute_contract_substance')
    gov_fees = fields.Monetary('Gov Fees', required=False, tracking=True, help="Employee's monthly Government Fees.")
    contract_gov_fees = fields.Monetary("Contract Gov Fees", compute='_compute_contract_gov_fees')
    annual_gov_fees = fields.Monetary('Annual', required=False, tracking=True, help="Employee's annual gov fees cost.")
    contract_annual_gov_fees = fields.Monetary("Contract Annual Gov Fees", compute='_compute_annual_gov_fees')

    @api.depends('contract_transport')
    def _compute_contract_transport(self):
        for contract in self:
            payroll_ids = self.env['hr.payslip.line'].search(
                [('salary_rule_id.code', '=', 'Trans'), ('employee_id', '=', contract.employee_id.id)])
            transaport_amount = sum(payroll_ids.mapped('amount'))
            contract.contract_transport = transaport_amount

    @api.depends('contract_housing')
    def _compute_contract_housing(self):
        for contract in self:
            payroll_ids = self.env['hr.payslip.line'].search(
                [('salary_rule_id.code', '=', 'House'), ('employee_id', '=', contract.employee_id.id)])
            housing_amount = sum(payroll_ids.mapped('amount'))
            contract.contract_housing = housing_amount

    @api.depends('contract_insurance')
    def _compute_contract_insurance(self):
        for contract in self:
            payroll_ids = self.env['hr.payslip.line'].search(
                [('salary_rule_id.code', '=', 'House'), ('employee_id', '=', contract.employee_id.id)])
            insurance_amount = sum(payroll_ids.mapped('amount'))
            contract.contract_insurance = insurance_amount

    @api.depends('contract_substance')
    def _compute_contract_substance(self):
        for contract in self:
            payroll_ids = self.env['hr.payslip.line'].search(
                [('salary_rule_id.code', '=', 'House'), ('employee_id', '=', contract.employee_id.id)])
            substance_amount = sum(payroll_ids.mapped('amount'))
            contract.contract_substance = substance_amount

    @api.depends('contract_gov_fees')
    def _compute_contract_gov_fees(self):
        for contract in self:
            payroll_ids = self.env['hr.payslip.line'].search(
                [('salary_rule_id.code', '=', 'House'), ('employee_id', '=', contract.employee_id.id)])
            gov_fees_amount = sum(payroll_ids.mapped('amount'))
            contract.contract_gov_fees = gov_fees_amount


    @api.depends('gov_fees')
    def _compute_annual_gov_fees(self):
        for contract in self:
            contract.contract_annual_gov_fees = contract._get_contract_gov_fees()
            contract.annual_gov_fees = contract.contract_annual_gov_fees * 12



