import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/components/components.dart';
import '../../../../shared/network/local/cache_helper.dart';
import '../../employees.dart';


// List of Six items in dropdown menu
const List<String> sixItems = [
  'Select',
  'Male',
  'Female',
  'Other',
];

// List of Status items in dropdown menu
const List<String> statusItems = [
  'Select',
  'Single',
  'Married',
  'Divorced',
  'Other',
];


class ContractScreen extends StatefulWidget {
  final List<Map<String, Object>> user;
  const ContractScreen({super.key, required this.user});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {

  // Initial Selected Value
  String sixDropDownValue = sixItems.first;
  String statusDropDownValue = statusItems.first;
  String
      name = '', image = 'http://anastomosisdesignlab.com/static/media/aboutImg.ca6be5f62633267f4b00.png',
      email = '', phone = '', jobTitle = '', address = '', department = '', nationality = '', idNumber = '',
      six = '', dateOfBirth = '', education = '', status = '', contractAbout = '', contractStartDate = '',
      contractEndDate = '', basicSalary = '', substance = '', transportation = '', housing = '', insurance = '',
      govFee = '', daysPerWeak = '', startDayOfWeak = '', endDayOfWeak = '', hoursPerDay = '', attendance = '',
      totalHours = '', overtime = '', deduction = '', bonus = '';

      TimeOfDay? picked;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idNumberController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _jobTitleController;
  late TextEditingController _addressController;
  late TextEditingController _nationalityController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _educationController;
  late TextEditingController _passportController;
  late TextEditingController _contractAboutController;
  late TextEditingController _contractStartController;
  late TextEditingController _contractEndController;
  late TextEditingController _basicSalaryController;
  late TextEditingController _substanceController;
  late TextEditingController _housingController;
  late TextEditingController _transportationController;
  late TextEditingController _insuranceController;
  late TextEditingController _govFeesController;
  late TextEditingController _daysPerWeakController;
  late TextEditingController _hoursPerDayController;
  late TextEditingController _startDayOfWeakController;
  late TextEditingController _endDayOfWeakController;
  late TextEditingController _attendanceController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _idNumberController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _departmentController = TextEditingController();
    _jobTitleController = TextEditingController();
    _addressController = TextEditingController();
    _nationalityController = TextEditingController();
    _passportController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _educationController = TextEditingController();
    _contractAboutController = TextEditingController();
    _contractStartController = TextEditingController();
    _contractEndController = TextEditingController();
    _basicSalaryController = TextEditingController();
    _substanceController = TextEditingController();
    _housingController = TextEditingController();
    _transportationController = TextEditingController();
    _insuranceController = TextEditingController();
    _govFeesController = TextEditingController();
    _daysPerWeakController = TextEditingController();
    _hoursPerDayController = TextEditingController();
    _startDayOfWeakController = TextEditingController();
    _endDayOfWeakController = TextEditingController();
    _attendanceController = TextEditingController();
    _imageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _jobTitleController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _passportController.dispose();
    _dateOfBirthController.dispose();
    _educationController.dispose();
    _contractAboutController.dispose();
    _contractStartController.dispose();
    _contractEndController.dispose();
    _basicSalaryController.dispose();
    _substanceController.dispose();
    _housingController.dispose();
    _transportationController.dispose();
    _insuranceController.dispose();
    _govFeesController.dispose();
    _daysPerWeakController.dispose();
    _hoursPerDayController.dispose();
    _startDayOfWeakController.dispose();
    _endDayOfWeakController.dispose();
    _attendanceController.dispose();
    _imageController.dispose();
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
      //imageFile = File(widget.user['image'].toString());
    });

    print(imageFile);
  }

  @override
  Widget build(BuildContext context) {

    List<Map<String, Object>> users = widget.user;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Contracts'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.start,
              children:
              [
                const Text(
                  'Employee Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Name And ID Number Row
                customInputRow(
                  title1: "Employee Name:",
                  hintText1: "Name",
                  controller1: _nameController,
                  keyboardType1: TextInputType.text,
                  labelText1: 'Name',
                  validator1: (String? value) {
                    if (value!.isEmpty) {
                      return 'Name must mot be empty';
                    }
                    return null;
                  },
                  title2: "Employee ID:",
                  hintText2: "ID",
                  controller2: _idNumberController,
                  keyboardType2: TextInputType.number,
                  labelText2: 'ID',
                  validator2: (String? value) {
                    if (value!.isEmpty) {
                      return 'ID must mot be empty';
                    }
                    return null;
                  },
                ),

                // Address And Email Row
                customInputRow(
                  title1: "Employee Address:",
                  hintText1: "Address",
                  controller1: _addressController,
                  keyboardType1: TextInputType.text,
                  labelText1: 'Address',
                  validator1: (String? value) {
                    if (value!.isEmpty) {
                      return 'Address must mot be empty';
                    }
                    return null;
                  },
                  title2: "Employee Email:",
                  hintText2: "Email",
                  controller2: _emailController,
                  keyboardType2: TextInputType.emailAddress,
                  labelText2: 'Email',
                  validator2: (String? value) {
                    if (value!.isEmpty) {
                      return 'Email must mot be empty';
                    }
                    return null;
                  },
                ),

                // Phone And Department And Job Title Row
                customDetailsRow(
                  title1: "Phone:",
                  hintText1: "Phone",
                  controller1: _phoneController,
                  keyboardType1: TextInputType.number,
                  labelText1: 'Phone',
                  validator1: (String? value) {
                    if (value!.isEmpty) {
                      return 'Phone Number must mot be empty';
                    }
                    return null;
                  },
                  title2: "Department:",
                  hintText2: "Department",
                  controller2: _departmentController,
                  keyboardType2: TextInputType.text,
                  labelText2: 'Department',
                  validator2: (String? value) {
                    if (value!.isEmpty) {
                      return 'Department must mot be empty';
                    }
                    return null;
                  },
                  title3: "Job Title:",
                  hintText3: "Job Title",
                  controller3: _jobTitleController,
                  keyboardType3: TextInputType.text,
                  labelText3: 'Job Title',
                  validator3: (String? value) {
                    if (value!.isEmpty) {
                      return 'Job Title must mot be empty';
                    }
                    return null;
                  },
                ),

                // Nationality And Passport And Education Row
                customDetailsRow(
                  title1: "Nationality:",
                  hintText1: "Nationality",
                  controller1: _nationalityController,
                  keyboardType1: TextInputType.number,
                  labelText1: 'Nationality',
                  validator1: (String? value) {
                    if (value!.isEmpty) {
                      return 'Nationality must mot be empty';
                    }
                    return null;
                  },
                  title2: "Passport:",
                  hintText2: "Passport",
                  controller2: _passportController,
                  keyboardType2: TextInputType.text,
                  labelText2: 'Passport',
                  validator2: (String? value) {
                    if (value!.isEmpty) {
                      return 'Passport must mot be empty';
                    }
                    return null;
                  },
                  title3: "Education:",
                  hintText3: "Education",
                  controller3: _educationController,
                  keyboardType3: TextInputType.text,
                  labelText3: 'Education',
                  validator3: (String? value) {
                    if (value!.isEmpty) {
                      return 'Education must mot be empty';
                    }
                    return null;
                  },
                ),


                // Date of Birth And Six And Status Row
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 10,),
                  child: Row(
                    children:
                    [
                      // Date of Birth
                      Expanded(
                        child: Row(
                          children: [
                            const Text('Date Of Birth: '),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _dateOfBirthController,
                                onTap: (){
                                  dialogBuilder(
                                    context: context,
                                    title: 'Pick the Employee Date of Birth',
                                    contentWidget: SizedBox(
                                      height: 200,
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        initialDateTime: DateTime(1998, 2, 21),
                                        onDateTimeChanged: (DateTime pickedDate) {
                                          // Do something
                                          //String dateOfBirth = "${newDateTime.day}-${newDateTime.month}-${newDateTime.year}";
                                          String dateOfBirth = DateFormat('yyyy-MM-dd').format(pickedDate);
                                          _dateOfBirthController.text = dateOfBirth;
                                        },
                                      ),
                                    ),
                                    disableTitle: 'Disable',
                                    disableOnTap: ()
                                    {
                                      Navigator.of(context).pop();
                                    },
                                    enableTitle: 'Pick',
                                    enableOnTap: ()
                                    {
                                      Navigator.of(context).pop();
                                    },
                                  );

                                },
                                keyboardType: TextInputType.datetime,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Date of Birth",
                                  hintText: "Date of Birth",
                                ),
                                onSubmitted: (String value){},
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 80,
                      ),

                      // Six
                      Expanded(
                        child: Row(
                          children: [
                            const Text('Six: ',),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: sixDropDownValue,
                                icon: const Icon(Icons.arrow_downward),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                    //filled: true,
                                    hintStyle: TextStyle(color: Colors.grey[800]),
                                    hintText: "Six",
                                    //fillColor: Colors.blue[200],

                                ),
                                elevation: 16,
                                alignment: Alignment.center,
                                style: const TextStyle(color: Colors.deepPurple),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    sixDropDownValue = value!;
                                    six = sixDropDownValue;
                                  });
                                },
                                items: sixItems.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 80,
                      ),

                      // Status
                      Expanded(
                        child: Row(
                          children: [
                            const Text('Status: '),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: statusDropDownValue,
                                icon: const Icon(Icons.arrow_downward),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  //filled: true,
                                  hintStyle: TextStyle(color: Colors.grey[800]),
                                  hintText: "Six",
                                  //fillColor: Colors.blue[200],

                                ),
                                elevation: 16,
                                alignment: Alignment.center,
                                style: const TextStyle(color: Colors.deepPurple),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    statusDropDownValue = value!;
                                    status = statusDropDownValue;
                                  });
                                },
                                items: statusItems.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Text(
                    'Contract Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // About Contract
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 10,),
                  child: Row(
                    children: [
                      const Text(
                        'About Contract',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 20.0,),
                      Expanded(
                        child: TextFormField(
                          controller: _contractAboutController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'About Contract',
                            hintText: "All About",
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'About Contract must mot be empty';
                            }
                            return null;
                          },
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),


                // Start Date And End Date of Basic Salary Row
                customDetailsRow(
                  title1: "Start Date:",
                  hintText1: "Start Date",
                  controller1: _contractStartController,
                  onTap1: (){
                    dialogBuilder(
                      context: context,
                      title: 'Pick the Start Date of Contract',
                      contentWidget: SizedBox(
                        height: 200,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime(1998, 2, 21),
                          onDateTimeChanged: (DateTime pickedDate) {
                            // Do something
                           // String contractStartDate = "${newDateTime.day}-${newDateTime.month}-${newDateTime.year}";
                            String contractStartDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            _contractStartController.text = contractStartDate;
                          },
                        ),
                      ),
                      disableTitle: 'Disable',
                      disableOnTap: ()
                      {
                        Navigator.of(context).pop();
                      },
                      enableTitle: 'Enable',
                      enableOnTap: ()
                      {
                        Navigator.of(context).pop();
                      },
                    );

                  },
                  keyboardType1: TextInputType.datetime,
                  labelText1: 'Start Date',
                  validator1: (String? value) {
                    if (value!.isEmpty) {
                      return 'Start Date must mot be empty';
                    }
                    return null;
                  },
                  title2: "End Date:",
                  hintText2: "End Date",
                  controller2: _contractEndController,
                  onTap2: (){
                    dialogBuilder(
                      context: context,
                      title: 'Pick the Start Date of Contract',
                      contentWidget: SizedBox(
                        height: 200,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime(1998, 2, 21),
                          onDateTimeChanged: (DateTime pickedDate) {
                            // Do something
                            //String contractEndDate = "${newDateTime.day}-${newDateTime.month}-${newDateTime.year}";
                            String contractEndDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            _contractEndController.text = contractEndDate;
                          },
                        ),
                      ),
                      disableTitle: 'Disable',
                      disableOnTap: ()
                      {
                        Navigator.of(context).pop();
                      },
                      enableTitle: 'Enable',
                      enableOnTap: ()
                      {
                        Navigator.of(context).pop();
                      },
                    );

                  },
                  keyboardType2: TextInputType.text,
                  labelText2: 'End Date',
                  validator2: (String? value) {
                    if (value!.isEmpty) {
                      return 'End Date must mot be empty';
                    }
                    return null;
                  },
                  title3: "Basic Salary:",
                  hintText3: "Basic Salary",
                  controller3: _basicSalaryController,
                  keyboardType3: TextInputType.number,
                  labelText3: 'Basic Salary',
                  validator3: (String? value) {
                    if (value!.isEmpty) {
                      return 'Basic Salary must mot be empty';
                    }
                    return null;
                  },
                ),

                // Substance And Transportation And Housing Row
                customDetailsRow(
                  title1: "Substance:",
                  hintText1: "Substance",
                  controller1: _substanceController,
                  keyboardType1: TextInputType.number,
                  labelText1: 'Substance',
                  validator1: (String? value) {
                    if (value!.isEmpty) {
                      return 'Substance must mot be empty';
                    }
                    return null;
                  },
                  title2: "Transportation:",
                  hintText2: "Transportation",
                  controller2: _transportationController,
                  keyboardType2: TextInputType.number,
                  labelText2: 'Transportation',
                  validator2: (String? value) {
                    if (value!.isEmpty) {
                      return 'Transportation must mot be empty';
                    }
                    return null;
                  },
                  title3: "Housing:",
                  hintText3: "Housing",
                  controller3: _housingController,
                  keyboardType3: TextInputType.number,
                  labelText3: 'Housing',
                  validator3: (String? value) {
                    if (value!.isEmpty) {
                      return 'Housing must mot be empty';
                    }
                    return null;
                  },
                ),

                // Insurance And GovFees And Days per Weak Row
                customDetailsRow(
                  title1: "Insurance:",
                  hintText1: "Insurance",
                  controller1: _insuranceController,
                  keyboardType1: TextInputType.number,
                  labelText1: 'Insurance',
                  validator1: (String? value) {
                    if (value!.isEmpty) {
                      return 'Insurance must mot be empty';
                    }
                    return null;
                  },
                  title2: "GovFees:",
                  hintText2: "GovFees",
                  controller2: _govFeesController,
                  keyboardType2: TextInputType.number,
                  labelText2: 'GovFees',
                  validator2: (String? value) {
                    if (value!.isEmpty) {
                      return 'GovFees must mot be empty';
                    }
                    return null;
                  },
                  title3: "Days per Weak:",
                  hintText3: "Days per Weak",
                  controller3: _daysPerWeakController,
                  keyboardType3: TextInputType.number,
                  labelText3: 'Days per Weak',
                  validator3: (String? value) {
                    if (value!.isEmpty) {
                      return 'Days must mot be empty';
                    }
                    return null;
                  },
                ),
                /// TODO:: Create image picker and camera picker to store image
                // hours per Day And Attendance And Image Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                    [
                      Expanded(
                        child: customInputRow(
                          title1: "Hours per Day:",
                          hintText1: "Hours per Day",
                          controller1: _hoursPerDayController,
                          keyboardType1: TextInputType.number,
                          labelText1: 'Hours per Day',
                          validator1: (String? value) {
                            if (value!.isEmpty) {
                              return 'Hours must mot be empty';
                            }
                            return null;
                          },
                          title2: "Attendance:",
                          hintText2: "Attendance",
                          controller2: _attendanceController,
                          keyboardType2: TextInputType.number,
                          labelText2: 'Attendance',
                          validator2: (String? value) {
                            if (value!.isEmpty) {
                              return 'Attendance must mot be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 400,),
                      Padding(
                        padding: const EdgeInsets.only(right: 150.0,),
                        child: Row(
                          children: [
                            const Text(
                              'Image: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageFile == null ? Image.network(
                                      'http://anastomosisdesignlab.com/static/media/aboutImg.ca6be5f62633267f4b00.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ) : Image.file(
                                      imageFile!,
                                      width: 100,
                                      height: 100,
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
                            ),
                          ],
                        ),
                      ),
                    ],
                ),

              ],
            ),
          ),
        ),
      ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()
        async {
          if (formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All Done!'),
                  backgroundColor: Colors.green,
                ),
              );
              name = _nameController.text;
              image = _imageController.text;
              email = _emailController.text;
              phone = _phoneController.text;
              jobTitle = _jobTitleController.text;
              address = _addressController.text;
              department = _departmentController.text;
              nationality = _nationalityController.text;
              idNumber = _idNumberController.text;
              six = sixDropDownValue;
              dateOfBirth = _dateOfBirthController.text;
              education = _educationController.text;
              status = statusDropDownValue;
              contractAbout = _contractAboutController.text;
              contractStartDate = _contractStartController.text;
              contractEndDate = _contractEndController.text;
              basicSalary = _basicSalaryController.text;
              transportation = _transportationController.text;
              housing = _housingController.text;
              substance = _substanceController.text;
              insurance = _insuranceController.text;
              govFee = _govFeesController.text;
              daysPerWeak = _daysPerWeakController.text;
              startDayOfWeak = _startDayOfWeakController.text;
              endDayOfWeak = _endDayOfWeakController.text;
              hoursPerDay = _hoursPerDayController.text;
              attendance = _attendanceController.text;
              totalHours = '0';
              overtime = '0';
              deduction = '0';
              bonus = '0';
              var uuid = Uuid();
              String id = uuid.v1();


              users.add({
                'name': name,
                'id': id,
                'image': 'http://anastomosisdesignlab.com/static/media/aboutImg.ca6be5f62633267f4b00.png',
                'email': email,
                'phone': phone,
                'job_title': jobTitle,
                'address': address,
                'department': department,
                'nationality': nationality,
                'id_number': idNumber,
                'six': six,
                'date_of_birth': dateOfBirth,
                'education': education,
                'status': status,
                'contract_about': contractAbout,
                'contract_start': contractStartDate,
                'contract_end': contractEndDate,
                'basic_salary': basicSalary,
                'transportation': transportation,
                'housing': housing,
                'substance': substance,
                'insurance': insurance,
                'gov_fees': govFee,
                'days_per_weak': daysPerWeak,
                'start_day_of_weak': startDayOfWeak,
                'end_day_of_weak': endDayOfWeak,
                'hours_per_day': hoursPerDay,
                'attendance': 'From 8 AM to 4 PM',
                'total_hours': totalHours,
                'overtime': overtime,
                'deduction': deduction,
                'bonus': bonus,
              });

              /// TODO:: Save the new employee to list in SharedPreferences

              SharedPreferences prefs = await SharedPreferences.getInstance();
              String jsonData = json.encode(users);
              prefs.setString("employees", jsonData);
              CacheHelper.saveData(
                  key: 'employees',
                  value: jsonData,
              ).then((value)
              {
                navigateTo(context, AllEmployees(user: users));
              });


          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Contract'),
      ),
    );
  }
}

Widget customInputRow({
  required String title1,
  required String title2,
  required TextEditingController controller1,
  required TextEditingController controller2,
  void Function()? onTap1,
  void Function()? onTap2,
  String? Function(String?)? validator1,
  String? Function(String?)? validator2,
  required String labelText1,
  required String labelText2,
  String? hintText1,
  String? hintText2,
  TextInputType? keyboardType1,
  TextInputType? keyboardType2,
}) =>
    Padding(
      padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  title1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: TextFormField(
                    controller: controller1,
                    onTap: onTap1,
                    keyboardType: keyboardType1,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: labelText1,
                      hintText: hintText1,
                    ),
                    validator: validator1,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          const Spacer(),
          Expanded(
            child: Row(
              children: [
                Text(
                  title2,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: TextFormField(
                    controller: controller2,
                    onTap: onTap2,
                    keyboardType: keyboardType2,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: labelText2,
                      hintText: hintText2,
                    ),
                    validator: validator2,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );


Widget customDetailsRow(
{
  required String title1,
  required String title2,
  required String title3,
  required TextEditingController controller1,
  required TextEditingController controller2,
  required TextEditingController controller3,
  String? Function(String?)? validator1,
  String? Function(String?)? validator2,
  String? Function(String?)? validator3,
  void Function()? onTap1,
  void Function()? onTap2,
  void Function()? onTap3,
  required String labelText1,
  required String labelText2,
  required String labelText3,
  String? hintText1,
  String? hintText2,
  String? hintText3,
  TextInputType? keyboardType1,
  TextInputType? keyboardType2,
  TextInputType? keyboardType3,
}) => Padding(
  padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Row(
          children: [
            Text(
              title1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: TextFormField(
                controller: controller1,
                onTap: onTap1,
                keyboardType: keyboardType1,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: labelText1,
                  hintText: hintText1,
                ),
                validator: validator1,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      const Spacer(),
      Expanded(
        child: Row(
          children: [
            Text(
              title2,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: TextFormField(
                controller: controller2,
                onTap: onTap2,
                keyboardType: keyboardType2,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: labelText2,
                  hintText: hintText2,
                ),
                validator: validator2,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      const Spacer(),
      Expanded(
        child: Row(
          children: [
            Text(
              title3,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: TextFormField(
                controller: controller3,
                onTap: onTap3,
                keyboardType: keyboardType3,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: labelText3,
                  hintText: hintText3,
                ),
                validator: validator3,
                //onSubmitted: va,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    ],
  ),
);


