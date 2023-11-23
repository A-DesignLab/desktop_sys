import 'package:flutter/material.dart';

import '../../home_layout/home_screen.dart';
import '../../shared/components/components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  IconData suffix = Icons.visibility_off_outlined;
  bool isPasswordShown = true;

  void changePasswordVisibility() {
    isPasswordShown = !isPasswordShown;
    suffix = isPasswordShown
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changePasswordVisibility();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: height * 0.20,
                  height: height * 0.20,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'ADL',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              Text(
                'Login',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 35.0,
                    ),
              ),
              //SizedBox between Login Text and Login to Start Text
              SizedBox(
                height: height * 0.02,
              ),
              // subtitle login in the screen
              Text(
                'Login to start connect with your company',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey),
              ),
              SizedBox(
                height: height * 0.05,
              ),

              // TextFormField of Email Address
              defaultTextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                label: 'Email Address',
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp("^[a-zA-Z0-9_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                      .hasMatch(value)) {
                    return 'Please Enter a Valid Email';
                  }
                  return null;
                },
                prefix: Icons.email_outlined,
                prefixColor: Colors.red,
              ),

              //SizedBox between Email and Password TextFormField
              SizedBox(
                height: height * 0.02,
              ),

              // TextFormField of Password
              defaultTextFormField(
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                label: 'Password',
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                    ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your Password';
                  }
                  if (value.length < 6) {
                    return 'Password is less than 6 characters!';
                  }
                  return null;
                },
                secure: !isPasswordShown,
                prefix: Icons.password,
                prefixColor: Colors.green,
                suffix: !isPasswordShown
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                suffixColor: Colors.grey,
                suffixPressed: () {
                  setState(() {
                    changePasswordVisibility();
                  });
                },
              ),
              //SizedBox between Password and Login Button
              SizedBox(
                height: height * 0.035,
              ),

              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      if(emailController.text == 'admin@gmail.com' && passwordController.text == 'Admin2030')
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All Done!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const MyHomePage()));
                      }else
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account is not Registered!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

