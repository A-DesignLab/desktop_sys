import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:file_picker/file_picker.dart';

import '../../../shared/components/components.dart';
import '../../../shared/components/constants.dart';
import 'salaries_payroll/payroll_all_month_screen.dart';
import 'salaries_payroll/payslip_screen.dart';

// This is the type used by the popup menu below.
enum SampleItem { itemOne, itemTwo, itemThree }

class EmployeeDetailsScreen extends StatefulWidget {
  final String employeeID;
  final Map<String, Object> user;

  const EmployeeDetailsScreen(
      {super.key, required this.employeeID, required this.user});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  double hoursFromAPI = KHoursWorked;

  late double totalHours = 0.0;
  late double percentValue = 0.0;

  late TabController _tabController;

  SampleItem? selectedMenu;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Image Picker Function

  PlatformFile? selectImage;
  File? imageFile;
  void _pickFile() async
  {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      dialogTitle: 'Select an Employee Picture!',
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'gif', 'png']
    );
    if(result == null) return;
    selectImage = result.files.single;
    setState(() {
      imageFile = File(selectImage!.path!);
      imageFile = File(widget.user['image'].toString());
    });

    print(selectImage?.path);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: Text('${widget.user['name']}'),
        centerTitle: true,
        actions: [
          customElevatedButton(
            onPressed: () {
              navigateTo(
                  context,
                  PayslipScreen(
                    user: widget.user,
                  ));
            },
            text: 'Payslip',
            foregroundColor: const Color(0xFF311B92),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 10.0,
            ),
            child: customElevatedButton(
              onPressed: () {
                navigateTo(
                    context,
                    PayrollAllMonthsScreen(
                      user: widget.user,
                    ));
              },
              text: 'Payroll',
              foregroundColor: const Color(0xFF311B92),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: PopupMenuButton<SampleItem>(
              initialValue: selectedMenu,
              // Callback that sets the selected popup menu item.
              onSelected: (SampleItem item) {
                setState(() {
                  selectedMenu = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                const PopupMenuItem<SampleItem>(
                  value: SampleItem.itemOne,
                  child: Text('Add Employee'),
                ),
                const PopupMenuItem<SampleItem>(
                  value: SampleItem.itemTwo,
                  child: Text('Edit Employee'),
                ),
                const PopupMenuItem<SampleItem>(
                  value: SampleItem.itemThree,
                  child: Text('Delete Employee'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        strokeWidth: 4.0,
        onRefresh: () async {
          // Replace this delay with the code to be executed during refresh
          // and return a Future when code finishes execution.
          return Future<void>.delayed(const Duration(seconds: 3));
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageFile == null ? Image.network(
                            '${widget.user['image']}',
                            width: 300,
                            height: 200,
                            fit: BoxFit.cover,
                          ) : Image.file(
                            imageFile!, width: 300,
                            height: 200,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Tooltip(
                            message: 'Edit',
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              color: const Color(0xFF311B92),
                              style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                              ),
                              onPressed: ()
                              {
                                _pickFile();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${widget.user['name']}',
                            style: const TextStyle(fontSize: 26),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 8, 0, 8),
                            child: Text(
                              'Job Title: ${widget.user['job_title']}',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          Text(
                            'Department: ${widget.user['department']}',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(150, 0, 0, 0),
                      child: CircularPercentIndicator(
                        percent: percentValue,
                        radius: 60,
                        lineWidth: 13.0,
                        animation: true,
                        animateFromLastPercent: true,
                        animationDuration: 3000,
                        onAnimationEnd: () {
                          print('Animation Finished');
                        },
                        progressColor: Colors.green,
                        backgroundColor: Colors.grey,
                        circularStrokeCap: CircularStrokeCap.round,
                        header: const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            "Monthly Progress",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        center: Text(
                          '${totalHours.toStringAsFixed(2)} %',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: const Color(0xFF311B92),
                          unselectedLabelColor: Colors.black45,
                          labelStyle: const TextStyle(fontSize: 16),
                          unselectedLabelStyle: const TextStyle(),
                          indicatorColor: const Color(0xFF311B92),
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(4, 20, 4, 4),
                          tabs: const [
                            Tab(
                              text: ' Basic Info',
                              icon: Icon(
                                Icons.person_sharp,
                                size: 30,
                                color: Colors.amber,
                              ),
                            ),
                            Tab(
                              text: '  Contract Info',
                              icon: Icon(
                                Icons.content_paste,
                                color: Color(0xFF311B92),
                                size: 30,
                              ),
                            ),
                            Tab(
                              text: 'Salary Info',
                              icon: Icon(
                                Icons.attach_money_rounded,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                          controller: _tabController,
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Employee Information Tab
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 700,
                                    child: customTabBarView(
                                      context: context,
                                      mainTitle: 'Employee Information\n',
                                      title1: 'Name: ',
                                      text1: "${widget.user['name']}",
                                      title2: "Nationality: ",
                                      text2: "${widget.user['nationality']}",
                                      title3: "Phone Number: ",
                                      text3: "${widget.user['phone']}",
                                      title4: "ID Number: ",
                                      text4: "${widget.user['id_number']}",
                                      title5: "Six: ",
                                      text5: "${widget.user['six']}",
                                      title6: "Date Of Birth: ",
                                      text6: "${widget.user['date_of_birth']}",
                                      title7: "Education: ",
                                      text7: "${widget.user['education']}",
                                      title8: "Status: ",
                                      text8: "${widget.user['status']}",
                                      title9: "Address: ",
                                      text9: "${widget.user['address']}",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 700,
                                    child: customTabBarView(
                                      context: context,
                                      mainTitle: 'Employee Information\n',
                                      title1: 'Name: ',
                                      text1: "${widget.user['name']}",
                                      title2: "Nationality: ",
                                      text2: "${widget.user['nationality']}",
                                      title3: "Phone Number: ",
                                      text3: "${widget.user['phone']}",
                                      title4: "ID Number: ",
                                      text4: "${widget.user['id_number']}",
                                      title5: "Six: ",
                                      text5: "${widget.user['six']}",
                                      title6: "Date Of Birth: ",
                                      text6: "${widget.user['date_of_birth']}",
                                      title7: "Education: ",
                                      text7: "${widget.user['education']}",
                                      title8: "Status: ",
                                      text8: "${widget.user['status']}",
                                      title9: "Address: ",
                                      text9: "${widget.user['address']}",
                                    ),
                                  ),
                                ],
                              ),

                              // Contract Information Tab
                              customTabBarView(
                                context: context,
                                mainTitle: 'Contract Information\n',
                                title1: 'About: ',
                                text1: '${widget.user['contract_about']}',
                                title2: 'Period:',
                                text2:
                                    ' From ${widget.user['contract_start']} to ${widget.user['contract_end']}',
                                title3: 'Basic Salary: ',
                                text3: '${widget.user['basic_salary']} SR',
                                title4: 'Transportation: ',
                                text4: '${widget.user['transportation']} SR',
                                title5: 'Housing: ',
                                text5: '${widget.user['housing']} SR',
                                title6: 'Substance: ',
                                text6: '${widget.user['substance']} SR',
                                title7: 'Insurance: ',
                                text7: '${widget.user['insurance']} SR',
                                title8: 'Gov Fees: ',
                                text8: '${widget.user['gov_fees']} SR',
                                title9: 'Days per weak: ',
                                text9: '${widget.user['days_per_weak']} Days',
                                title10: 'Start day of weak: ',
                                text10: '${widget.user['start_day_of_weak']}',
                                title11: 'End day of weak: ',
                                text11: '${widget.user['end_day_of_weak']}',
                                title12: 'Hours per day: ',
                                text12: '${widget.user['hours_per_day']} Hours',
                                title13: 'Attendance: ',
                                text13: '${widget.user['attendance']}',
                              ),

                              // Salary Information Tab
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 700,
                                    child: customTabBarView(
                                      context: context,
                                      mainTitle: 'Employee Information\n',
                                      title1: 'Basic Salary: ',
                                      text1:
                                          '${widget.user['basic_salary']} SR',
                                      title2: 'Transportation: ',
                                      text2:
                                          '${widget.user['transportation']} SR',
                                      title3: 'Housing: ',
                                      text3: '${widget.user['housing']} SR',
                                      title4: 'Substance: ',
                                      text4: '${widget.user['substance']} SR',
                                      title5: 'Insurance: ',
                                      text5: '${widget.user['insurance']} SR',
                                      title6: 'Gov Fees: ',
                                      text6: '${widget.user['gov_fees']} SR',
                                      title7: 'Days per weak: ',
                                      text7:
                                          '${widget.user['days_per_weak']} Days',
                                      title8: 'Start day of weak: ',
                                      text8:
                                          '${widget.user['start_day_of_weak']}',
                                      title9: 'End day of weak: ',
                                      text9:
                                          '${widget.user['end_day_of_weak']}',
                                      title10: 'Hours per day: ',
                                      text10:
                                          '${widget.user['hours_per_day']} Hours',
                                      title11: 'Attendance: ',
                                      text11: '${widget.user['attendance']}',
                                    ),
                                  ),
                                  SizedBox(
                                    width: 700,
                                    child: customTabBarView(
                                      context: context,
                                      mainTitle: 'Employee Information\n',
                                      title1: 'Basic Salary: ',
                                      text1:
                                          '${widget.user['basic_salary']} SR',
                                      title2: 'Transportation: ',
                                      text2:
                                          '${widget.user['transportation']} SR',
                                      title3: 'Housing: ',
                                      text3: '${widget.user['housing']} SR',
                                      title4: 'Substance: ',
                                      text4: '${widget.user['substance']} SR',
                                      title5: 'Insurance: ',
                                      text5: '${widget.user['insurance']} SR',
                                      title6: 'Gov Fees: ',
                                      text6: '${widget.user['gov_fees']} SR',
                                      title7: 'Days per weak: ',
                                      text7:
                                          '${widget.user['days_per_weak']} Days',
                                      title8: 'Start day of weak: ',
                                      text8:
                                          '${widget.user['start_day_of_weak']}',
                                      title9: 'End day of weak: ',
                                      text9:
                                          '${widget.user['end_day_of_weak']}',
                                      title10: 'Hours per day: ',
                                      text10:
                                          '${widget.user['hours_per_day']} Hours',
                                      title11: 'Attendance: ',
                                      text11: '${widget.user['attendance']}',
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
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            hoursFromAPI = KHoursWorked;
            totalHours = (hoursFromAPI * 100) / 240;
            percentValue = totalHours / 100;
          });
          // Show refresh indicator programmatically on button tap.
          _refreshIndicatorKey.currentState?.show();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }
}

Widget customTabBarView({
  required context,
  String? mainTitle,
  String title1 = '',
  text1 = '',
  title2 = '',
  text2 = '',
  title3 = '',
  text3 = '',
  title4 = '',
  text4 = '',
  title5 = '',
  text5 = '',
  title6 = '',
  text6 = '',
  title7 = '',
  text7 = '',
  title8 = '',
  text8 = '',
  title9 = '',
  text9 = '',
  title10 = '',
  text10 = '',
  title11 = '',
  text11 = '',
  title12 = '',
  text12 = '',
  title13 = '',
  text13 = '',
  title14 = '',
  text14 = '',
  title15 = '',
  text15 = '',
  title16 = '',
  text16 = '',
  title17 = '',
  text17 = '',
  title18 = '',
  text18 = '',
  title19 = '',
  text19 = '',
  title20 = '',
  text20 = '',
}) =>
    Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30, 20, 20, 0),
      child: ListView(
        children: [
          Text(
            mainTitle!,
            style: const TextStyle(fontSize: 32),
          ),
          customRichText(context: context, title: title1, text: text1),
          customRichText(context: context, title: title2, text: text2),
          customRichText(context: context, title: title3, text: text3),
          customRichText(context: context, title: title4, text: text4),
          customRichText(context: context, title: title5, text: text5),
          customRichText(context: context, title: title6, text: text6),
          customRichText(context: context, title: title7, text: text7),
          customRichText(context: context, title: title8, text: text8),
          customRichText(context: context, title: title9, text: text9),
          customRichText(context: context, title: title10, text: text10),
          customRichText(context: context, title: title11, text: text11),
          customRichText(context: context, title: title12, text: text12),
          customRichText(context: context, title: title13, text: text13),
          customRichText(context: context, title: title14, text: text14),
          customRichText(context: context, title: title15, text: text15),
          customRichText(context: context, title: title16, text: text16),
          customRichText(context: context, title: title17, text: text17),
          customRichText(context: context, title: title18, text: text18),
          customRichText(context: context, title: title19, text: text19),
          customRichText(context: context, title: title20, text: text20),
        ],
      ),
    );

Widget customRichText({
  required context,
  String? title,
  required String text,
}) =>
    Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF311B92),
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: text,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )
          ],
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );

Widget customElevatedButton({
  required VoidCallback onPressed,
  required String text,
  Color? backgroundColor,
  Color? foregroundColor,
  Color? fontColor,
  double? fontSize,
  String? fontFamily,
  EdgeInsetsGeometry? padding,
}) =>
    ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        textStyle: TextStyle(
          color: fontColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
      child: Text(
        text,
      ),
    );
