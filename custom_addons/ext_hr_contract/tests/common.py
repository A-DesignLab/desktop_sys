from odoo.tests.common import TransactionCase

class TestPayslipBase(TransactionCase):

    _inherit = 'common'


    def setUp(self):
        super(TestPayslipBase, self).setUp()

        self.Contract = self.env["hr.contract"]

        self.rule_Trans = self.SalaryRule.create(
            {
                "name": "Transport Allowance",
                "code": "Trans",
                "sequence": 5,
                "category_id": self.categ_alw.id,
                "condition_select": "none",
                "amount_select": "code",
                "amount_python_compute": "result = contract.transport",
            }
        )
        self.rule_house = self.SalaryRule.create(
            {
                "name": "Housing Allowance",
                "code": "house",
                "sequence": 5,
                "category_id": self.categ_alw.id,
                "condition_select": "none",
                "amount_select": "code",
                "amount_python_compute": "result = contract.housing",
            }
        )

        self.rule_Ins = self.SalaryRule.create(
            {
                "name": "Insurance Allowance",
                "code": "Ins",
                "sequence": 5,
                "category_id": self.categ_alw.id,
                "condition_select": "none",
                "amount_select": "code",
                "amount_python_compute": "result = contract.insurance",
            }
        )

        self.rule_subs= self.SalaryRule.create(
            {
                "name": "Substance Allowance",
                "code": "subs",
                "sequence": 5,
                "category_id": self.categ_alw.id,
                "condition_select": "none",
                "amount_select": "code",
                "amount_python_compute": "result = contract.substance",
            }
        )

        self.rule_gov_fees = self.SalaryRule.create(
            {
                "name": "Government Fees Allowance",
                "code": "gov",
                "sequence": 5,
                "category_id": self.categ_alw.id,
                "condition_select": "none",
                "amount_select": "code",
                "amount_python_compute": "result = contract.gov_fees",
            }
        )

