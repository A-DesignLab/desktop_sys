import 'package:flutter/material.dart';

import '../modules/employees_screen/employees_screen.dart';
import '../shared/components/components.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    List<String> adminTitles = [
      'Finance',
      'Projects',
      'Vat',
      'Employees',
    ];
    final icons = [Icons.ac_unit, Icons.access_alarm, Icons.access_time, Icons.hearing];

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Home'),
      ),
      body: ListView(
//mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.13,),
          Wrap(
            alignment: WrapAlignment.center,
//mainAxisAlignment: MainAxisAlignment.center,
            children: [

// Finance Card
              customCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(adminTitles[0]),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                title: adminTitles[0],
              ),
              SizedBox(width: height * 0.03,),

// Projects Card
              customCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(adminTitles[1]),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                title: adminTitles[1],
              ),
              SizedBox(width: height * 0.03,),

// Vat Card
              customCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(adminTitles[2]),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                title: adminTitles[2],
              ),
              SizedBox(width: height * 0.03,),

// Employees Card
              customCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(adminTitles[3]),
                      backgroundColor: Colors.black,
                    ),
                  );
                  navigateTo(context, const EmployeesScreen());
                },
                title: adminTitles[3],
              ),


            ],
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/*
ListView(
//mainAxisAlignment: MainAxisAlignment.center,
children: [
SizedBox(height: height * 0.13,),
Wrap(
alignment: WrapAlignment.center,
//mainAxisAlignment: MainAxisAlignment.center,
children: [

// Finance Card
customCard(
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(adminTitles[0]),
backgroundColor: Colors.green,
),
);
},
title: adminTitles[0],
),
SizedBox(width: height * 0.03,),

// Projects Card
customCard(
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(adminTitles[1]),
backgroundColor: Colors.red,
),
);
},
title: adminTitles[1],
),
SizedBox(width: height * 0.03,),

// Vat Card
customCard(
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(adminTitles[2]),
backgroundColor: Colors.blue,
),
);
},
title: adminTitles[2],
),
SizedBox(width: height * 0.03,),

// Employees Card
customCard(
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(adminTitles[3]),
backgroundColor: Colors.black,
),
);
navigateTo(context, const EmployeesScreen());
},
title: adminTitles[3],
),


],
),
],
)
*/
