import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';


class PayrollScreen extends StatelessWidget {
  final Map<String, Object> user;
  const PayrollScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {

    double basicSalary = double.parse(user['basic_salary'] as String);
    double substance = double.parse(user['substance'] as String);
    double housing = double.parse(user['housing'] as String);
    double transportation = double.parse(user['transportation'] as String);
    double insurance = double.parse(user['insurance'] as String);
    double govFees = double.parse(user['gov_fees'] as String);
    double overtime = double.parse(user['overtime'] as String);
    double deduction = double.parse(user['deduction'] as String);


    double dailyFee = (basicSalary / 30);
    double hourlyFee = (basicSalary / 30) / 8;
    double requiredHoursPerMonth = 9 * 30;
    double overtimeFee = hourlyFee * overtime;
    double deductedHoursFee = hourlyFee * deduction;
    double totalSum = basicSalary + substance + housing + transportation + insurance + govFees+ overtimeFee+ deductedHoursFee;

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
              Row(
                children: [
                  Container(
                    width: 150,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF311B92),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(25),bottomRight: Radius.circular(25),),
                    ),
                    child: const Text(
                        '2023',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                        'Quarterly Payroll Report',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // Name of Employee
              Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Full Name: ',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${user['name']}',
                      style: TextStyle(
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
                height: 300,
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
                  height: 330,
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
                    rows: [
                      // First Quarter
                      const DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'January - March',
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
                              '90h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '570h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '15500 SAR',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Second Quarter
                      const DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'April - June',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '420h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '102h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '522h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '14800 SAR',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Third Quarter
                      const DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'July - September',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '440h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '110h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '550h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '15200 SAR',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Fourth Quarter
                      const DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'October - December',
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
                              '85h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '565h',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '15300 SAR',
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
