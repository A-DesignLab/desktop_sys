import 'dart:convert';

import 'package:flutter/material.dart';

import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/local/cache_helper.dart';
import 'employee_details/contract/contract_screen.dart';
import 'employee_details/employee_details_screen.dart';
import 'employees_screen.dart';

class AllEmployees extends StatelessWidget {
  final List<Map<String, Object>> user;

  const AllEmployees({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    employeesList = CacheHelper.getData(key: 'employees');
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    final scaffoldKey = GlobalKey<ScaffoldState>();
    final users = user;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              navigateTo(context, const EmployeesScreen());
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              size: 20.0,
            ),
        ),
        title: const Text('Employees'),
        centerTitle: true,
        /*actions: [
          TextButton(
            onPressed: () {
              navigateTo(
                  context,
                  ContractScreen(
                    user: users,
                  ));
            },
            child: const Text(
              'Add Employee',
            ),
          ),
        ],*/
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.pink,
              ),
              currentAccountPicture: const CircleAvatar(
                radius: 40.0,
                backgroundImage: NetworkImage(
                  'https://www.kindpng.com/picc/m/21-214439_free-high-quality-person-icon-default-profile-picture.png',
                ),
              ),
              accountName: const Text(''),
              accountEmail: Container(
                width: width * 0.5,
                padding: const EdgeInsets.only(bottom: 15,left: 5,right: 60),
                child: defaultButton(
                  onPressed: ()
                  {
                    //navigateAndFinish(context, LoginScreen());
                  },
                  text: 'Login Now',
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ),
            customListTile(
              context: context,
              listTileOnTap: ()
              {
              },
              title: 'Add Employee',
              subTitle: 'Create a new contract to add new employee in company with all details',
              trailingIcon: Icons.arrow_forward_ios_rounded,
            ),
            ListTile(
              title: const Text('Add Employee',),
              subtitle: const Text('Create a new contract to add new employee in company with all details',),
              trailing: IconButton(
                onPressed: () {
                  navigateTo(context, ContractScreen(
                    user: users,
                  ));
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 20.0,
                ),
              ),
            ),
            const Divider(
              thickness: 1.5,
            ),
            ListTile(),
          ],
        ),
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
              navigateTo(
                  context,
                  EmployeeDetailsScreen(
                    employeeID: '${users[index]['id']}',
                    user: user,
                  ));
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
                  customCardDetails(
                      title: 'Name: ',
                      employeeTitle: '${users[index]['name']}'),
                  customCardDetails(
                      title: 'Email: ',
                      employeeTitle: '${users[index]['email']}'),
                  customCardDetails(
                      title: 'Job: ',
                      employeeTitle: '${users[index]['job_title']}'),
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
      padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 0, 0),
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
