
import 'package:flutter/material.dart';

import '../../home_layout/home_screen.dart';
import '../../models/users_model.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import 'employees.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    final managementEmployeesList = managementEmployees;
    final designersEmployeesList = designingEmployees;
    final engineersEmployeesList = engineeringEmployees;
    final supervisorsEmployeesList = supervisorsEmployees;
    final laboursEmployeesList = laboursEmployees;

    List<String> employeesPosition = [
      'Management',
      'Designers',
      'Engineers',
      'Supervisors',
      'Labourers',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KPrimaryColor,
        leading: IconButton(
          onPressed: () {
            navigateTo(context, const MyHomePage());
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 20.0,
          ),
        ),
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

                // Management Employees Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[0]),
                        backgroundColor: Colors.green,
                      ),
                    );
                    navigateTo(context, AllEmployees(user: managementEmployeesList,));
                  },
                  title: employeesPosition[0],
                ),
                SizedBox(width: height * 0.03,),

                // Designers Employees  Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[1]),
                        backgroundColor: Colors.red,
                      ),
                    );
                    navigateTo(context, AllEmployees(user: designersEmployeesList,));
                  },
                  title: employeesPosition[1],
                ),
                SizedBox(width: height * 0.03,),

                // Engineers Employees Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[2]),
                        backgroundColor: Colors.blue,
                      ),
                    );
                    navigateTo(context, AllEmployees(user: engineersEmployeesList,));
                  },
                  title: employeesPosition[2],
                ),
                SizedBox(width: height * 0.03,),

                // Supervisors Employees Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[3]),
                        backgroundColor: Colors.black,
                      ),
                    );
                    navigateTo(context, AllEmployees(user: supervisorsEmployeesList,));
                   // navigateTo(context, EmployeeDetailsScreen());
                  },
                  title: employeesPosition[3],
                ),

                // Labours Employees Card
                customCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(employeesPosition[4]),
                        backgroundColor: Colors.black,
                      ),
                    );
                    navigateTo(context, AllEmployees(user: laboursEmployeesList,));
                    // navigateTo(context, EmployeeDetailsScreen());
                  },
                  title: employeesPosition[4],
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
