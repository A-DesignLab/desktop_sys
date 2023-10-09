import 'package:desk_test/shared/components/components.dart';
import 'package:desk_test/shared/components/constants.dart';
import 'package:flutter/material.dart';


class EmployeeProfileScreen extends StatefulWidget {
  final String employeeName;

  const EmployeeProfileScreen({
    super.key,
    required this.employeeName,
  });

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  @override
  Widget build(BuildContext context) {
    String? dropdownValue;
    List itemsOfTitle = [
      'Engineer',
      'Designer',
      'Management',
      'Developer',
      'IT',
      'Labor',
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 30,
            ),
            const CircleAvatar(
              radius: 30,
              child: Image(
                image: AssetImage(
                  'assets/images/logo.png',
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(widget.employeeName),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: customElevatedButton(
              onTap: () {},
              label: 'Delete',
              icon: Icons.delete_outline,
            ),
          ),
        ],
        //leading: ,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Divider(
              thickness: 0.6,
            ),
            Stack(
              //alignment: Alignment.center,
              children: [
                const Image(
                  width: double.maxFinite,
                    fit: BoxFit.cover,
                    height: 250,
                    image: AssetImage(
                        'assets/images/cover.png',
                    ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.all(5.0),
                      height: 150.0,
                      width: 150.0,
                      child: Card(
                        elevation: 15.0,
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    customTextButtonIcon(
                      onTap: () {},
                      label: 'Change profile',
                      fontSize: 15,
                      icon: Icons.image_outlined,
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF26a0f8),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.all(5.0),
                      height: 150.0,
                      width: double.maxFinite,

                      child: Card(
                        color: Colors.white,
                        elevation: 15.0,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  widget.employeeName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children:
                                [
                                  customDetailsColumn(
                                    firstTitle: 'Developer',
                                    secondTitle: 'Cairo, Egypt',
                                  ),

                                  customDetailsColumn(
                                    firstTitle: 'Developer',
                                    secondTitle: 'Cairo, Egypt',
                                  ),

                                  customDetailsColumn(
                                    firstTitle: 'Developer',
                                    secondTitle: 'Cairo, Egypt',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      ),
                    ),

                    const SizedBox(height: 30,),


                  ],
                ),
              ],
            ),
            SizedBox(
              height: 300,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    margin: const EdgeInsets.all(5.0),
                    height: 300.0,
                    width: 300.0,
                    child: Card(
                      elevation: 15.0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    margin: const EdgeInsets.all(5.0),
                    height: 300.0,
                    width: 300.0,
                    child: Card(
                      elevation: 15.0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    margin: const EdgeInsets.all(5.0),
                    height: 300.0,
                    width: 300.0,
                    child: Card(
                      elevation: 15.0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Widget customDropDownDetail(
{
  required String titleText,
  required List<DropdownMenuItem<dynamic>>? itemsOfTitle,
  required void Function(dynamic)? onChange,
  required String hintText,
  String? dropdownValue,
})=> Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      titleText,
      style: const TextStyle(
        fontSize: 20,
      ),
    ),
    const SizedBox(height: 10,),
    DropdownButtonFormField(
      focusColor: Colors.white,
      padding: const EdgeInsets.only(right: 100.0),
      hint:  Text(hintText),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: KPrimaryColor,
      ),
      dropdownColor: KPrimaryColor,
      value: dropdownValue,
      onChanged: onChange,
      items: itemsOfTitle,

    ),
  ],
);

Widget customDetailsColumn(
{
  required firstTitle,
  required secondTitle,

})=> Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children:
  [
    Text(
      firstTitle,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.grey,
      ),
    ),

    Text(
      secondTitle,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.grey,
      ),
    ),
  ],
);
/*Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 10,),

                      // DropDown List Of ROLE
                      customDropDownDetail(
                        hintText: 'Choose Role',
                        titleText: 'ROLE',
                        onChange: (newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      }, itemsOfTitle: itemsOfTitle
                          .map<DropdownMenuItem>((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),

                      ),
                      // End of DropDown List

                    ],
                  ),
                ),*/