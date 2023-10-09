import 'package:desk_test/home_layout/home_screen.dart';
import 'package:desk_test/modules/employees_screen/employee_profile_screen/employee_profile_screen.dart';
import 'package:desk_test/shared/components/components.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';

import '../../../shared/components/constants.dart';

class LabourersScreen extends StatefulWidget {
  const LabourersScreen({super.key});

  @override
  State<LabourersScreen> createState() => _LabourersScreenState();
}

class _LabourersScreenState extends State<LabourersScreen> {
  String searchValue = '';
  String employeesValue = '';
  final List<String> _employees = [
    'Mohamed Wagdi',
    'Doaa',
    'Sophi',
    'Raghda',
    'Heba',
    'Rasha',
    'Bahabib',
    'Yousef',
    'Mohamed Yousef',
    'Ruba',

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
          title: const Text('Example'),
          backgroundColor: KPrimaryColor,
          elevation: 2,
          onSearch: (value) => setState(() => searchValue = value),
          onSuggestionTap: (value)
          {
            employeesValue = value;
            print('Employee Value is : $employeesValue');
            navigateTo(context, EmployeeProfileScreen(employeeName: employeesValue,));
          },
          suggestions: _employees,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
                title: const Text('Item 1'),
                onTap: () => Navigator.pop(context),
            ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: ListView.separated(
          itemCount: _employees.length,
          itemBuilder: (context, index)
          {
            return ListTile(
              title: Text(_employees[index]),
              onTap: () {
                employeesValue = _employees[index];
                print(_employees[index]);
                print('Employee Value is : $employeesValue');
                navigateTo(context, EmployeeProfileScreen(employeeName: employeesValue,));
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(),

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: ()
        {
          navigateAndFinish(context, const MyHomePage(),);
        },
        child: const Icon(
          Icons.home,
          size: 30,
        ),
      ),
    );
  }
}
