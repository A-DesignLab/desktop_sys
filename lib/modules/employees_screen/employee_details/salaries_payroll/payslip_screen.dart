import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

class PayslipScreen extends StatefulWidget {
  final Map<String, Object> user;
  const PayslipScreen({super.key, required this.user});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  late TextEditingController _bonusController;
  late TextEditingController _basicSalaryNote;
  late TextEditingController _substanceNote;
  late TextEditingController _housingNote;
  late TextEditingController _transportationNote;
  late TextEditingController _insuranceNote;
  late TextEditingController _govFeesNote;
  late TextEditingController _bonusNote;
  late TextEditingController _overTimeNote;
  late TextEditingController _deductionNote;

  @override
  void initState() {
    super.initState();
    _bonusController = TextEditingController();
    _basicSalaryNote = TextEditingController();
    _substanceNote = TextEditingController();
    _housingNote = TextEditingController();
    _transportationNote = TextEditingController();
    _insuranceNote = TextEditingController();
    _govFeesNote = TextEditingController();
    _bonusNote = TextEditingController();
    _overTimeNote = TextEditingController();
    _deductionNote = TextEditingController();
  }

  @override
  void dispose() {
    _bonusController.dispose();
    _basicSalaryNote.dispose();
    _substanceNote.dispose();
    _housingNote.dispose();
    _transportationNote.dispose();
    _insuranceNote.dispose();
    _govFeesNote.dispose();
    _bonusNote.dispose();
    _overTimeNote.dispose();
    _deductionNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // ************************************************************//
    // Variable From Employee Model
    double basicSalary = double.parse(widget.user['basic_salary'] as String);
    double substance = double.parse(widget.user['substance'] as String);
    double housing = double.parse(widget.user['housing'] as String);
    double transportation = double.parse(widget.user['transportation'] as String);
    double insurance = double.parse(widget.user['insurance'] as String);
    double govFees = double.parse(widget.user['gov_fees'] as String);
    double overtime = double.parse(widget.user['overtime'] as String);
    double deduction = double.parse(widget.user['deduction'] as String);
    double bonus = double.parse(widget.user['bonus'] as String);
    // Calculation of Salary
    double dailyFee = (basicSalary / 30);
    double hourlyFee = (basicSalary / 30) / 8;
    double requiredHoursPerMonth = 9 * 30;
    double overtimeFee = hourlyFee * overtime;
    double deductedHoursFee = hourlyFee * deduction;
    double totalSum = basicSalary + substance + housing + transportation + insurance + govFees+ overtimeFee+ deductedHoursFee + bonus;
  // ************************************************************//
    // Format For Dates
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    var monthDate = DateFormat.MMMM('en_US');
    var yearDate = DateFormat.y();
    String formatSignatureDate = formatter.format(now);
    String formatMonthDate = monthDate.format(now);
    String formatYearDate = yearDate.format(now);


    // ************************************************************//
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslip', style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: ElevatedButton(
              onPressed: ()
              {
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF311B92),
                textStyle: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
              child: const Text(
                'Print',
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                'Payslip',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              Text(
                'Salary Slip of  ${widget.user['name']} for $formatMonthDate-$formatYearDate',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),

              // Name of Employee
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Full Name: ',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${widget.user['name']}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                thickness: 1.5,
              ),

              // Hours Details
              SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 600,
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 600,
                        columns: const [
                          DataColumn2(
                            label: Text(''),
                            size: ColumnSize.L,
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              const DataCell(
                                Text(
                                  'Day Cost',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${dailyFee.toStringAsFixed(2)} SAR',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              const DataCell(
                                Text(
                                  'Hour Cost',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${hourlyFee.toStringAsFixed(2)} SAR',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 600,
                        columns: const [
                          DataColumn2(
                            label: Text(''),
                            size: ColumnSize.L,
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              const DataCell(
                                Text(
                                  'Required Hours per Month',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '$requiredHoursPerMonth h',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              const DataCell(
                                Text(
                                  'Hours Worked',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${widget.user['total_hours']} h',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Salary Slip Details
              Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 200.0, left: 200),
                child: SizedBox(
                  height: 530,
                  width: 300,
                  child: DataTable2(
                    columnSpacing: 100,
                    horizontalMargin: 100,
                    minWidth: 1500,
                    headingRowColor: MaterialStateProperty.all(Colors.amber),
                    headingTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),
                    columns: const [
                      DataColumn2(
                        label: Text('Description'),
                        size: ColumnSize.L,
                      ),
                      DataColumn(
                        label: Text('Cost'),
                      ),
                      DataColumn(
                        label: Text('Note'),
                      ),
                    ],
                    rows: [
                      // Basic Salary
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Basic Salary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '$basicSalary SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _basicSalaryNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Substance
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Substance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '$substance SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _substanceNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Housing
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Housing',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '$housing SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _housingNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Transportation
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Transportation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '$transportation SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _transportationNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Insurance
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Insurance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '$insurance SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _insuranceNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // GovFees
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Government Fees',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '$govFees SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _govFeesNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Bonus
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Bonus',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _bonusController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: '${widget.user['bonus']} SAR',
                                  hintText: '$bonus SAR',
                                ),
                                  onSubmitted: (String value) async
                                  {
                                    setState(() {
                                      if(_bonusController.text.trim().isEmpty)
                                      {
                                        Navigator.pop(context);
                                      }
                                      widget.user['bonus'] = _bonusController.text.trim();
                                    });
                                  },
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _bonusNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Overtime Hours
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Overtime Hours',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${overtimeFee.toStringAsFixed(2)} SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                              customTextField(controller: _overTimeNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Deduction Hours
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Deduction Hours',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${deductedHoursFee.toStringAsFixed(2)} SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            customTextField(controller: _deductionNote, labelText: '-', onSubmitted: (String value){}),
                          ),
                        ],
                      ),

                      // Total Sum of all Quarters
                      DataRow(
                        color: MaterialStateProperty.all(Colors.black),
                        cells: [
                          const DataCell(
                            Text(
                              'TOTAL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${totalSum.toStringAsFixed(2)} SAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const DataCell(
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(
                thickness: 1.5,
              ),

              // Signs Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  customSignsColumn(signTitle: 'CEO', signName: 'Tamir Khalil',),
                  customSignsColumn(signTitle: 'COO', signName: 'Elmohannad Gad',),
                  customSignsColumn(signTitle: 'HR', signName: 'Doaa Alam',),
                  customSignsColumn(signTitle: 'Employee', signName: '${widget.user['name']}',),
                  customSignsColumn(signTitle: 'Date', signName: formatSignatureDate,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget customSignsColumn(
{
  required String signTitle,
  required String signName,
}) => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          signTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            signName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );


Widget customTextField(
{
  required TextEditingController controller,
  required void Function(String)? onSubmitted,
  required String labelText,
  String? hintText,
}) =>TextField(
  controller: controller,
  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    labelText: labelText,
    hintText: hintText,
  ),
  onSubmitted: onSubmitted,
  textAlign: TextAlign.center,
);

