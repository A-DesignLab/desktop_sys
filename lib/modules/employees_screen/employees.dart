import 'dart:convert';

import 'package:flutter/material.dart';

import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/local/cache_helper.dart';
import 'employee_details/contract/contract_screen.dart';
import 'employee_details/employee_details_screen.dart';

class AllEmployees extends StatelessWidget {
  final List<Map<String, Object>> user;
  const AllEmployees({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    employeesList = CacheHelper.getData(key: 'employees');

    final scaffoldKey = GlobalKey<ScaffoldState>();
    final users = user;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Employees'),
        centerTitle: true,
        actions:
        [
          TextButton(
              onPressed: ()
              {
                navigateTo(context, ContractScreen(user: users,));
              },
              child: const Text(
                'Add Employee',
              ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          scrollDirection: Axis.vertical,
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) => InkWell(
            splashColor: Colors.red,
            focusColor: Colors.red,
            hoverColor: Colors.amber,
            highlightColor: Colors.green,
            onTap: () async {
              var user = users[index];
              navigateTo(context, EmployeeDetailsScreen(employeeID: '${users[index]['id']}', user: user,));
            },
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              //color: FlutterFlowTheme.of(context).secondaryBackground,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${users[index]['image']}',
                      width: double.maxFinite,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  customCardDetails(title: 'Name: ', employeeTitle: '${users[index]['name']}'),
                  customCardDetails(title: 'Email: ', employeeTitle: '${users[index]['email']}'),
                  customCardDetails(title: 'Job: ', employeeTitle: '${users[index]['job_title']}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget customCardDetails({required String title, employeeTitle}) => Padding(
  padding:
  const EdgeInsetsDirectional.fromSTEB(20, 10, 0, 0),
  child: Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      Expanded(
        child: Text(
          employeeTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  ),
);
