import 'package:flutter/material.dart';

import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import 'labourers_screen/labourers_screen.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    List<String> employeesPosition = [
      'Management',
      'Designers',
      'Engineers',
      'Labourers',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KPrimaryColor,
        title: const Text('Employees'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            //SizedBox(height: height * 0.13,),
            Wrap(
              alignment: WrapAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Finance Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[0]),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  title: employeesPosition[0],
                ),
                SizedBox(width: height * 0.03,),

                // Projects Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[1]),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  title: employeesPosition[1],
                ),
                SizedBox(width: height * 0.03,),

                // Vat Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[2]),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  title: employeesPosition[2],
                ),
                SizedBox(width: height * 0.03,),

                // Employees Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[3]),
                        backgroundColor: Colors.black,
                      ),
                    );
                    navigateTo(context, const LabourersScreen());
                  },
                  title: employeesPosition[3],
                ),


              ],
            ),
          ],
        ),
      ),
    );
  }
}
