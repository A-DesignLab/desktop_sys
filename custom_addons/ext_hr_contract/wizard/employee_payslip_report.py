# -*- coding:utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.

from odoo import api, fields, models
import base64
import io
import xlwt
from odoo.exceptions import ValidationError


class PrintExcel(models.TransientModel):
    _name = 'employee.payslip.excel.report'
    _description = 'Excel Report'

    excel_file = fields.Binary('Excel Report')
    file_name = fields.Char('Report File Name', readonly=True)


class EmployeePayslipReport(models.TransientModel):
    _name = 'employee.payslip.report'
    _description = 'Employee Payslip Report'

    employee_id = fields.Many2many(string="Employee", comodel_name='hr.employee')
    start_date = fields.Date("Start Date", required=True)
    end_date = fields.Date("End Date", required=True)

    def _get_payslip_data(self, payslip=None, flag=None):
        if payslip:
            p_month = payslip.date_from.month
            salary = payslip.contract_id.wage or 0
            hra_alw = payslip.contract_id.hra or 0
            travel_alw = payslip.contract_id.travel_allowance or 0
            medical_alw = payslip.contract_id.medical_allowance or 0
            gov_fees_alw = payslip.contract_id.gov_fees or 0
            substance = payslip.contract_id.substance or 0
            total = salary + substance + hra_alw + travel_alw + medical_alw + gov_fees_alw
            remaining_total = payslip.remaining_total

        return p_month, salary, hra_alw, travel_alw, medical_alw, gov_fees_alw, substance, total, remaining_total

    def print_report(self):
        if self.end_date < self.start_date:
            raise ValidationError('Sorry, End Date Must be greater Than Start Date...')
        search_domain = []
        search_domain.append(('state', '=', 'done'))
        search_domain.append(('date_from', '>=', self.start_date))
        search_domain.append(('date_from', '<=', self.end_date))
        if self.employee_id:
            search_domain.append(('employee_id', 'in', self.employee_id.ids))
        else:
            all_employee = self.env['hr.employee'].search([])
            search_domain.append(('employee_id', 'in', all_employee.ids))

        payslip_ids = self.env['hr.payslip'].search(search_domain)

        employee_payslip_dict = {}

        for payslip in payslip_ids:
            if payslip.employee_id not in employee_payslip_dict:
                payslip_dict = {}
                salary_details_list = []
                salary_details = self._get_payslip_data(payslip=payslip)
                payslip_dict['month'] = salary_details[0]
                payslip_dict['salary'] = salary_details[1]
                payslip_dict['hra'] = salary_details[2]
                payslip_dict['travel'] = salary_details[3]
                payslip_dict['medical'] = salary_details[4]
                payslip_dict['gov_fess'] = salary_details[5]
                payslip_dict['substance'] = salary_details[6]
                payslip_dict['total'] = salary_details[7]
                payslip_dict['remaining_total'] = salary_details[8]
                salary_details_list.append(payslip_dict)
                employee_payslip_dict[payslip.employee_id] = salary_details_list

            else:
                payslip_dict = {}
                salary_details = self._get_payslip_data(payslip=payslip)
                payslip_dict['month'] = salary_details[0]
                payslip_dict['salary'] = salary_details[1]
                payslip_dict['hra'] = salary_details[2]
                payslip_dict['travel'] = salary_details[3]
                payslip_dict['medical'] = salary_details[4]
                payslip_dict['gov_fess'] = salary_details[5]
                payslip_dict['substance'] = salary_details[6]
                payslip_dict['total'] = salary_details[7]
                payslip_dict['remaining_total'] = salary_details[8]
                salary_details_list.append(payslip_dict)
                employee_payslip_dict.update({payslip.employee_id: salary_details_list})

        workbook = xlwt.Workbook()
        worksheet = workbook.add_sheet('Sheet 1')
        center = xlwt.easyxf('align:vertical center, horizontal center; font:bold on; font:height 220;')
        table_title = xlwt.easyxf(
            'align:vertical center, horizontal center; font:bold on; font:height 220; font: name Myriad Hebrew;')
        format0 = xlwt.easyxf(
            'font:height 200,bold True;pattern: pattern solid, fore_colour sky_blue; align:vertical center; align: horizontal center; font: name Myriad Hebrew;')
        year = xlwt.easyxf(
            'font: bold on;pattern: pattern solid, fore_colour yellow; align:vertical center; align: horizontal center; font: name Myriad Hebrew;')
        month = xlwt.easyxf(
            'font: bold on;pattern: pattern solid, fore_colour gray25; align:vertical center; align: horizontal center; font: name Myriad Hebrew;')

        row = 1
        col = 0
        for employee_id, value in employee_payslip_dict.items():
            worksheet.write_merge(row, row + 2, col, col, employee_id.name, format0)
            worksheet.col(col).width = 256 * 20
            col += 1
            worksheet.write_merge(row, row + 2, col, col)
            worksheet.col(col).width = 256 * 20
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Salary', table_title)
            worksheet.col(col).width = 256 * 18
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Basic', table_title)
            worksheet.col(col).width = 256 * 20
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Substance', table_title)
            worksheet.col(col).width = 256 * 25
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Housing', table_title)
            worksheet.col(col).width = 256 * 25
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Transportation', table_title)
            worksheet.col(col).width = 256 * 20
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Medical', table_title)
            worksheet.col(col).width = 256 * 20
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Gov Fees', table_title)
            worksheet.col(col).width = 256 * 25
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Extra Description', table_title)
            worksheet.col(col).width = 256 * 25
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Bonus', table_title)
            worksheet.col(col).width = 256 * 25
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'Total Paid', table_title)
            worksheet.col(col).width = 256 * 25
            col += 1
            worksheet.write_merge(row, row + 2, col, col, 'To be Paid', table_title)
            worksheet.col(col).width = 256 * 25
            col += 1

            row += 3
            col = 0
            worksheet.write(row, col, self.start_date.year, year)
            col += 1
            worksheet.write(row, col, "Month", month)

            row += 1
            col = 1
            paid_total = 0
            basic_total = 0
            substance_total = 0
            hra_total = 0
            medical_total = 0
            travel_total = 0
            gov_fess_total = 0
            bonus_total = 0

            for details in value:
                worksheet.write(row, col, details['month'], center)
                col += 1
                worksheet.write(row, col, details['total'], center)
                paid_total += details['total']
                col += 1
                worksheet.write(row, col, details['salary'], center)
                col += 1
                basic_total += details['salary']
                worksheet.write(row, col, details['substance'], center)
                col += 1
                substance_total += details['substance']
                worksheet.write(row, col, details['hra'], center)
                col += 1
                hra_total += details['hra']
                worksheet.write(row, col, details['travel'], center)
                col += 1
                travel_total += details['travel']
                worksheet.write(row, col, details['medical'], center)
                col += 1
                medical_total += details['medical']
                worksheet.write(row, col, details['gov_fess'], center)
                col += 1
                gov_fess_total += details['gov_fess']
                worksheet.write(row, col, 0, center)
                col += 1
                worksheet.write(row, col, 0, center)
                col += 1
                bonus_total += 0
                worksheet.write(row, col, details['total'], center)
                col += 1
                worksheet.write(row, col, details['remaining_total'], center)
                col += 1

                if len(details) > 1:
                    row += 1
                    col = 1

            row += 1
            col = 1
            worksheet.write(row, col, "TOTAL", year)
            col += 1
            worksheet.write(row, col, paid_total, year)
            col += 1
            worksheet.write(row, col, basic_total, year)
            col += 1
            worksheet.write(row, col, substance_total, year)
            col += 1
            worksheet.write(row, col, hra_total, year)
            col += 1
            worksheet.write(row, col, travel_total, year)
            col += 1
            worksheet.write(row, col, medical_total, year)
            col += 1
            worksheet.write(row, col, gov_fess_total, year)
            col += 1
            worksheet.write(row, col, "", year)
            col += 1
            worksheet.write(row, col, bonus_total, year)
            col += 1
            worksheet.write(row, col, paid_total, year)
            col += 1
            worksheet.write(row, col, 0, year)
            col += 1

            row += 4
            col = 0

        filename = 'Employee Payslip Report Excel.xlsx'
        workbook.save(filename)
        file = open(filename, "rb")
        file_data = file.read()
        out = base64.encodebytes(file_data)
        export_id = self.env['employee.payslip.excel.report'].sudo().create({'excel_file': out, 'file_name': filename})

        return {
            'view_mode': 'form', 'res_id': export_id.id, 'res_model': 'employee.payslip.excel.report',
            'view_type': 'form',
            'type': 'ir.actions.act_window', 'context': self._context, 'target': 'new',
        }