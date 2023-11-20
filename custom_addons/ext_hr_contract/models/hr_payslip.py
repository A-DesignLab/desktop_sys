# -*- coding:utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.

from odoo import api, fields, models, _
import calendar
from datetime import datetime
from dateutil import relativedelta
from odoo.tools import date_utils
from odoo.exceptions import UserError

ROUNDING_FACTOR = 16
from collections import defaultdict
from odoo.tools import float_utils


class EmployeeAnnualCost(models.Model):
    _name = 'hr.payslip'
    _inherit = ['hr.payslip', 'account.financial.year.op']

    state = fields.Selection(selection_add=[
        ('draft', 'Draft'),
        ('first_approve', 'Admin Approve'),
        ('second_approve', 'Super Approve'),
        ('verify', 'Waiting'),
        ('done', 'Done'),
        ('cancel', 'Rejected'),
    ], string='Status', index=True, readonly=True, copy=False, default='draft',
        help="""* When the payslip is created the status is \'Draft\'
                \n* If the payslip is under verification, the status is \'Waiting\'.
                \n* If the payslip is confirmed then status is set to \'Done\'.
                \n* When user cancel payslip the status is \'Rejected\'.""")

    company_currency_id = fields.Many2one(string='Company Currency', related='company_id.currency_id', readonly=True)
    remaining_gov_fees_awl = fields.Monetary(string="Remaining Gov Fees Allowance",
                                             compute='_compute_remaining_allowance',
                                             help="Shows Remaining Gov Fees According Time",
                                             currency_field='company_currency_id', readonly=True, store=True)
    remaining_substance_awl = fields.Monetary(string="Remaining Substance Allowance",
                                              compute='_compute_remaining_allowance',
                                              help="Shows Remaining Substance According Time",
                                              currency_field='company_currency_id', readonly=True, store=True)
    remaining_medical_alw = fields.Monetary(string="Remaining Medical Allowance",
                                            compute='_compute_remaining_allowance',
                                            help="Shows Remaining Medical According Time",
                                            currency_field='company_currency_id', readonly=True, store=True)
    remaining_travel_alw = fields.Monetary(string="Remaining Travel Allowance",
                                           compute='_compute_remaining_allowance',
                                           help="Shows Remaining Travel According Time",
                                           currency_field='company_currency_id', readonly=True, store=True)
    remaining_housing_alw = fields.Monetary(string="Remaining Housing Allowance",
                                            compute='_compute_remaining_allowance',
                                            help="Shows Remaining Housing According Time",
                                            currency_field='company_currency_id', readonly=True, store=True)
    remaining_salary = fields.Monetary(string="Remaining Salary", compute='_compute_remaining_allowance',
                                       help="Shows Remaining Salary According Time",
                                       currency_field='company_currency_id', readonly=True, store=True)
    remaining_total = fields.Monetary(string="Total Remaining", compute='_compute_remaining_allowance',
                                      help="Show Total remaining According Time", currency_field='company_currency_id',
                                      readonly=True, store=True)
    employee_bonus = fields.Monetary(string="Employee Bonus", currency_field='company_currency_id')
    employee_department = fields.Char(string="Department", compute='_get_department', store=True)

    def action_send_to_admin_approve(self):
        self.write({'state': 'first_approve'})

    def action_send_to_super_admin(self):
        self.write({'state': 'second_approve'})

    @api.depends('contract_id')
    def _get_department(self):
        for contract in self:
            contract.employee_department = contract.employee_id.department_id.name

    def get_attendance_from_employee(self, employee, date_from, date_to):
        criteria = [
            ('check_in', '>=', date_from),
            ('check_out', '<=', date_to),
            ('employee_id', '=', employee.id),
        ]
        attendance_model = self.env['hr.attendance']
        attendances = attendance_model.search(criteria)
        if not attendances:
            raise UserError(
                _("Sorry, but there is no Attendance for the entire Payslip period for user %s") % employee.name,
            )
        return attendances

    def get_worked_day_lines(self, contracts, date_from, date_to):
        res = super(EmployeeAnnualCost, self).get_worked_day_lines(self.contract_id, self.date_from, self.date_to)
        if self.employee_id.employee_type in ['worker']:
            attendances = self.get_attendance_from_employee(date_from=self.date_from, date_to=self.date_to,
                                                            employee=self.employee_id)
            diff_hours = 0
            worked_hours = 0.0
            days = 0
            day_hours = defaultdict(float)
            for attend in attendances:
                worked_hours_format = "{:.2f}".format(attend.worked_hours)
                if float(worked_hours_format) == 0.00:
                    raise UserError("No Worked Hours Found in Attendance Line")
                if worked_hours_format:
                    diff_hours += attend.worked_hours - attend.total_hours
                    worked_hours += attend.worked_hours
                    day_hours[attend.check_in.date()] += (attend.check_in - attend.check_out).total_seconds() / 3600
            if day_hours:
                days = sum(
                    float_utils.round(ROUNDING_FACTOR * day_hours[day] / day_hours[day] / ROUNDING_FACTOR)
                    for day in day_hours
                )
            if diff_hours > 0:
                over_time = {
                    'name': "OverTime",
                    'sequence': 3,
                    'code': 'OVER',
                    'number_of_days': diff_hours / ROUNDING_FACTOR / 3600,
                    'number_of_hours': diff_hours,
                    'contract_id': self.contract_id.id,
                }
                res.append(over_time)
            if diff_hours < 0:
                deduction = {
                    'name': "Deduction",
                    'sequence': 3,
                    'code': 'DEDUCT',
                    'number_of_days': diff_hours / ROUNDING_FACTOR / 3600,
                    'number_of_hours': diff_hours,
                    'contract_id': self.contract_id.id,
                }
                res.append(deduction)
            if day_hours and days:
                attendances = {
                    'name': _("Attendance"),
                    'sequence': 3,
                    'code': 'WORK100',
                    'number_of_days': 0.0,
                    'number_of_hours': worked_hours - diff_hours,
                    'contract_id': self.contract_id.id,
                }
                res.append(attendances)
            res[0].update({'code': 'TOTAL_DAYS'})
        return res

    @api.model
    def _get_payslip_lines(self, contract_ids, payslip_id):
        def _sum_salary_rule_category(localdict, category, amount):
            if category.parent_id:
                localdict = _sum_salary_rule_category(localdict, category.parent_id, amount)
            localdict['categories'].dict[category.code] = category.code in localdict['categories'].dict and \
                                                          localdict['categories'].dict[category.code] + amount or amount
            return localdict

        class BrowsableObject(object):
            def __init__(self, employee_id, dict, env):
                self.employee_id = employee_id
                self.dict = dict
                self.env = env

            def __getattr__(self, attr):
                return attr in self.dict and self.dict.__getitem__(attr) or 0.0

        class InputLine(BrowsableObject):
            """a class that will be used into the python code, mainly for usability purposes"""

            def sum(self, code, from_date, to_date=None):
                if to_date is None:
                    to_date = fields.Date.today()
                self.env.cr.execute("""
                        SELECT sum(amount) as sum
                        FROM hr_payslip as hp, hr_payslip_input as pi
                        WHERE hp.employee_id = %s AND hp.state = 'done'
                        AND hp.date_from >= %s AND hp.date_to <= %s AND hp.id = pi.payslip_id AND pi.code = %s""",
                                    (self.employee_id, from_date, to_date, code))
                return self.env.cr.fetchone()[0] or 0.0

        class WorkedDays(BrowsableObject):
            """a class that will be used into the python code, mainly for usability purposes"""

            def _sum(self, code, from_date, to_date=None):
                if to_date is None:
                    to_date = fields.Date.today()
                self.env.cr.execute("""
                        SELECT sum(number_of_days) as number_of_days, sum(number_of_hours) as number_of_hours
                        FROM hr_payslip as hp, hr_payslip_worked_days as pi
                        WHERE hp.employee_id = %s AND hp.state = 'done'
                        AND hp.date_from >= %s AND hp.date_to <= %s AND hp.id = pi.payslip_id AND pi.code = %s""",
                                    (self.employee_id, from_date, to_date, code))
                return self.env.cr.fetchone()

            def sum(self, code, from_date, to_date=None):
                res = self._sum(code, from_date, to_date)
                return res and res[0] or 0.0

            def sum_hours(self, code, from_date, to_date=None):
                res = self._sum(code, from_date, to_date)
                return res and res[1] or 0.0

        class Payslips(BrowsableObject):
            """a class that will be used into the python code, mainly for usability purposes"""

            def sum(self, code, from_date, to_date=None):
                if to_date is None:
                    to_date = fields.Date.today()
                self.env.cr.execute("""SELECT sum(case when hp.credit_note = False then (pl.total) else (-pl.total) end)
                                FROM hr_payslip as hp, hr_payslip_line as pl
                                WHERE hp.employee_id = %s AND hp.state = 'done'
                                AND hp.date_from >= %s AND hp.date_to <= %s AND hp.id = pl.slip_id AND pl.code = %s""",
                                    (self.employee_id, from_date, to_date, code))
                res = self.env.cr.fetchone()
                return res and res[0] or 0.0

        # we keep a dict with the result because a value can be overwritten by another rule with the same code
        result_dict = {}
        rules_dict = {}
        worked_days_dict = {}
        inputs_dict = {}
        blacklist = []
        payslip = self.env['hr.payslip'].browse(payslip_id)
        for worked_days_line in payslip.worked_days_line_ids:
            worked_days_dict[worked_days_line.code] = worked_days_line
        for input_line in payslip.input_line_ids:
            inputs_dict[input_line.code] = input_line

        categories = BrowsableObject(payslip.employee_id.id, {}, self.env)
        inputs = InputLine(payslip.employee_id.id, inputs_dict, self.env)
        worked_days = WorkedDays(payslip.employee_id.id, worked_days_dict, self.env)
        payslips = Payslips(payslip.employee_id.id, payslip, self.env)
        rules = BrowsableObject(payslip.employee_id.id, rules_dict, self.env)

        baselocaldict = {'categories': categories, 'rules': rules, 'payslip': payslips, 'worked_days': worked_days,
                         'inputs': inputs}
        # get the ids of the structures on the contracts and their parent id as well
        contracts = self.env['hr.contract'].browse(contract_ids)
        if len(contracts) == 1 and payslip.struct_id:
            structure_ids = list(set(payslip.struct_id._get_parent_structure().ids))
        else:
            structure_ids = contracts.get_all_structures()
        # get the rules of the structure and thier children
        rule_ids = self.env['hr.payroll.structure'].browse(structure_ids).get_all_rules()
        # run the rules by sequence
        sorted_rule_ids = [id for id, sequence in sorted(rule_ids, key=lambda x: x[1])]
        sorted_rules = self.env['hr.salary.rule'].browse(sorted_rule_ids)
        total_working_days = 0
        for total_working in self.worked_days_line_ids:
            total_working_days += total_working.number_of_days
        attendance_work_line = self.worked_days_line_ids.filtered(lambda r: r.code == "WORK100")
        input_line_ids = self.input_line_ids
        amount = 0
        baselocaldict.update({
            'input_amount': amount,
            'hours_rate': 0.0,
            'overtime': 0.0,
            'deduction': 0.0,
            'basic_salary': 0
        })
        for inputs in input_line_ids:
            amount += inputs.amount
        baselocaldict.update({
            'input_amount': amount
        })
        wage = self.contract_id.wage
        if not wage:
            raise UserError(_("Sorry, but there is no wage defined in contract !!!"))
        # if total_working_days:
        #     per_day_salary = wage / total_working_days
        #     working_hour = self.employee_id.resource_calendar_id.hours_per_day
        per_day_salary = wage / 30
        working_hour = 8
        if working_hour:
            hour_rate = per_day_salary / working_hour
            print(hour_rate)
            baselocaldict.update({
                'basic_salary': attendance_work_line.number_of_hours * hour_rate or 0
            })
            if self.worked_days_line_ids.filtered(lambda r: r.code == "DEDUCT"):
                deduct_hours = self.worked_days_line_ids.filtered(lambda r: r.code == "DEDUCT").number_of_hours
                sorted_rules += self.env['hr.salary.rule'].search([('code', '=', 'DECBONUS')])
                baselocaldict.update({
                    'overtime': 0.0,
                    'deduction': float(deduct_hours) * hour_rate
                })

            else:
                extra_hours = self.worked_days_line_ids.filtered(lambda r: r.code == "OVER").number_of_hours
                sorted_rules += self.env['hr.salary.rule'].search([('code', '=', 'EXTBONUS')])
                baselocaldict.update({
                    'deduction': 0.0,
                    'overtime': float(extra_hours) * hour_rate
                })
        for contract in contracts:
            employee = contract.employee_id
            localdict = dict(baselocaldict, employee=employee, contract=contract)
            for rule in sorted_rules:
                key = rule.code + '-' + str(contract.id)
                localdict['result'] = None
                localdict['result_qty'] = 1.0
                localdict['result_rate'] = 100
                # check if the rule can be applied
                if rule._satisfy_condition(localdict) and rule.id not in blacklist:
                    # compute the amount of the rule
                    amount, qty, rate = rule._compute_rule(localdict)
                    # check if there is already a rule computed with that code
                    previous_amount = rule.code in localdict and localdict[rule.code] or 0.0
                    # set/overwrite the amount computed for this rule in the localdict
                    tot_rule = contract.company_id.currency_id.round(amount * qty * rate / 100.0)
                    localdict[rule.code] = tot_rule
                    rules_dict[rule.code] = rule
                    # sum the amount for its salary category
                    localdict = _sum_salary_rule_category(localdict, rule.category_id, tot_rule - previous_amount)
                    # create/overwrite the rule in the temporary results
                    result_dict[key] = {
                        'salary_rule_id': rule.id,
                        'contract_id': contract.id,
                        'name': rule.name,
                        'code': rule.code,
                        'category_id': rule.category_id.id,
                        'sequence': rule.sequence,
                        'appears_on_payslip': rule.appears_on_payslip,
                        'condition_select': rule.condition_select,
                        'condition_python': rule.condition_python,
                        'condition_range': rule.condition_range,
                        'condition_range_min': rule.condition_range_min,
                        'condition_range_max': rule.condition_range_max,
                        'amount_select': rule.amount_select,
                        'amount_fix': rule.amount_fix,
                        'amount_python_compute': rule.amount_python_compute,
                        'amount_percentage': rule.amount_percentage,
                        'amount_percentage_base': rule.amount_percentage_base,
                        'register_id': rule.register_id.id,
                        'amount': amount,
                        'employee_id': contract.employee_id.id,
                        'quantity': qty,
                        'rate': rate,
                    }
                else:
                    # blacklist this rule and its children
                    blacklist += [id for id, seq in rule._recursive_search_of_rules()]

        return list(result_dict.values())

    def _compute_remaining_allowance(self):
        self.remaining_gov_fees_awl = 0
        self.remaining_substance_awl = 0
        self.remaining_travel_alw = 0
        self.remaining_medical_alw = 0
        self.remaining_housing_alw = 0
        self.remaining_salary = 0
        self.remaining_total = 0
        for record in self:
            if record.contract_id:
                contract_id = record.contract_id
                if contract_id.date_start or contract_id.date_end:
                    travel_alw = contract_id.travel_allowance
                    medical_alw = contract_id.medical_allowance
                    gov_fees_alw = contract_id.gov_fees
                    substance = contract_id.substance
                    housing_alw = contract_id.hra
                    salary_remain = contract_id.wage

                    date1 = int(record.fiscalyear_last_month)
                    date2 = record.date_to.month
                    month_count = date1 - date2

                    record.remaining_gov_fees_awl = month_count * gov_fees_alw
                    record.remaining_substance_awl = month_count * substance
                    record.remaining_medical_alw = month_count * medical_alw
                    record.remaining_travel_alw = month_count * travel_alw
                    record.remaining_housing_alw = month_count * housing_alw
                    record.remaining_salary = month_count * salary_remain
                    record.remaining_total = record.remaining_gov_fees_awl + record.remaining_substance_awl + record.remaining_medical_alw + record.remaining_travel_alw + record.remaining_housing_alw + record.remaining_salary
