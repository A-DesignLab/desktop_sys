# -*- coding:utf-8 -*-

{
    'name': 'HR Payroll Extend',
    'category': 'Generic Modules/Human Resources',
    'author': 'Do Incredible',
    'version': '16.0.1.0.1',
    'sequence': 1,
    'website': 'http://doincredible.com',
    'license': 'LGPL-3',
    'summary': 'Generic Payroll system Integrated with Accounting',
    'description': """Generic Payroll system Integrated with Accounting.""",
    'depends': [
        'om_hr_payroll_account',
        'om_hr_payroll',
        'account',
        'hr_attendance'
    ],
    'data': [
        'security/ir.model.access.csv',
        'security/hr_payroll_security.xml',
        'data/hr_salary_rule_demo.xml',
        'data/resource_data.xml',
        'views/hr_payslip_views.xml',
        'views/hr_attendance_view.xml',
        'views/hr_employee_views.xml',
        'views/annual_remaining.xml',
        'views/hr_contract_views.xml',
        'wizard/employee_payslip_report_view.xml'
    ],
    'demo': [],
    'application': True,
}
