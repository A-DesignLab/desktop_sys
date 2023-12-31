import 'package:desk_test/shared/components/constants.dart';
import 'package:flutter/material.dart';

import 'shared/network/local/cache_helper.dart';
import 'splash_screen.dart';

void main() async {
  await CacheHelper.init();
  employeesList = CacheHelper.getData(key: 'employees');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ADL Desktop System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


