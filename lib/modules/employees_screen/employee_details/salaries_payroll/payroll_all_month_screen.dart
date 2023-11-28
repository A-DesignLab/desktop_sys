import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

class PayrollAllMonthsScreen extends StatelessWidget {
  final Map<String, Object> user;
  const PayrollAllMonthsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    var months = [];
    months.add('January');
    var allMonths = ['January','February','March',"April","May","June","July","August","September","October","November","December",];
// ************************************************************//
    // Variable From Employee Model
    double basicSalary = double.parse(user['basic_salary'] as String);
    double substance = double.parse(user['substance'] as String);
    double housing = double.parse(user['housing'] as String);
    double transportation = double.parse(user['transportation'] as String);
    double insurance = double.parse(user['insurance'] as String);
    double govFees = double.parse(user['gov_fees'] as String);
    double overtime = double.parse(user['overtime'] as String);
    double deduction = double.parse(user['deduction'] as String);
    // Calculation of Salary
    double hourlyFee = (basicSalary / 30) / 8;
    double overtimeFee = hourlyFee * overtime;
    double deductedHoursFee = hourlyFee * deduction;
    double totalSum = basicSalary + substance + housing + transportation + insurance + govFees+ overtimeFee+ deductedHoursFee;
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
        title: const Text('Payroll', style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: ElevatedButton(
              onPressed: () {},
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
              Row(
                children: [
                  Container(
                    width: 150,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF311B92),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(25),bottomRight: Radius.circular(25),),
                    ),
                    child: Text(
                      formatYearDate,
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'PAYROLL ANNUAL SUMMARY REPORT',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(
                thickness: 5,
                color: Color(0xFF311B92),
              ),

              // Name of Employee
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
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
                      '${user['name']}',
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
                height: 210,
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
                        rows: const [
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Avg. Daily Hours ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '4h 5m',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Total Regular Hours Worked',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '1820h',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Total Overtime Hours Worked',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '387h',
                                  style: TextStyle(
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
                        rows: const [
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Pay Type ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  'Hourly',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Rate',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '19/h SAR',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'Total Wage',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '60800 SAR',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
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
                padding: const EdgeInsets.only(right: 20.0, left: 20),
                child: SizedBox(
                  height: 480,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    headingRowColor: MaterialStateProperty.all(Colors.amber),
                    headingTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),
                    columns: const [
                      DataColumn2(
                        label: Text('MONTHS'),
                        size: ColumnSize.L,
                      ),
                      DataColumn(
                        label: Text('REGULAR HOURS'),
                      ),
                      DataColumn(
                        label: Text('OVERTIME HOURS'),
                      ),
                      DataColumn(
                        label: Text('TOTAL HOURS'),
                      ),
                      DataColumn(
                        label: Text('TOTAL WAGE'),
                        numeric: true,
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      months.length,
                            (index) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    months[index],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    '159h 33m',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    '9h 35m',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    '168h 68m',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    '5200 SAR',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  ),
                ),

              // Total Details
              Padding(
                padding: const EdgeInsets.only(right: 20.0, left: 20),
                child: SizedBox(
                  height: 100,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    headingTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),
                    columns: const [
                      DataColumn2(
                        label: Text(''),
                        size: ColumnSize.L,
                      ),
                      DataColumn(
                        label: Text(''),
                      ),
                      DataColumn(
                        label: Text(''),
                      ),
                      DataColumn(
                        label: Text(''),
                      ),
                      DataColumn(
                        label: Text(''),
                        numeric: true,
                      ),
                    ],
                    rows: [
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


/*
[
// January Quarter
const DataRow(
cells: [
DataCell(
Text(
'January',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'159h 33m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'9h 35m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'168h 68m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5200 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// February Quarter
const DataRow(
cells: [
DataCell(
Text(
'February',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'155h 20m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'2h 20m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'164h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5130 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// March Quarter
const DataRow(
cells: [
DataCell(
Text(
'March',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'160h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'4h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'164h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5020 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// April Quarter
const DataRow(
cells: [
DataCell(
Text(
'April',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'480h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'159h 9m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'10h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5100 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// May Quarter
const DataRow(
cells: [
DataCell(
Text(
'May',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'142h 49m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'11h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'153h 49m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5300 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// June Quarter
const DataRow(
cells: [
DataCell(
Text(
'June',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'147h 18m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'11h 40m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'158h 58m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5400 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// July Quarter
const DataRow(
cells: [
DataCell(
Text(
'July',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'160h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'165h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5100 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// August Quarter
const DataRow(
cells: [
DataCell(
Text(
'August',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'140h 55m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'145h 55m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5100 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// September Quarter
const DataRow(
cells: [
DataCell(
Text(
'September',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'158h 25m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'4h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'162h 25m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5090 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// October Quarter
const DataRow(
cells: [
DataCell(
Text(
'October',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'145h 24m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'12h 10m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'157h 34m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5300 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// November Quarter
const DataRow(
cells: [
DataCell(
Text(
'November',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'160h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'7h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'167h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5120 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// December Quarter
const DataRow(
cells: [
DataCell(
Text(
'December',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'160h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'7h 25m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'167h 25m',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
DataCell(
Text(
'5130 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
),
),
),
],
),

// Total Sum of all Quarters
DataRow(
color: MaterialStateProperty.all(Colors.black),
cells: const [
DataCell(
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
'1820h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
color: Colors.white,
),
),
),
DataCell(
Text(
'387h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
color: Colors.white,
),
),
),
DataCell(
Text(
'2207h',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
color: Colors.white,
),
),
),
DataCell(
Text(
'60800 SAR',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
color: Colors.white,
),
),
),
],
),
]*/
