import 'package:flutter/material.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/textformfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // Placeholder for actual login logic
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email == 'admin@gmail.com' &&
        password == "password" /* Preference.getString(PrefKeys.password)*/) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Show an error message for incorrect login details
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Incorrect email or password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return OutsideContainer(
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600
                      ? 400
                      : constraints.maxWidth * 0.8,
                ),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColor.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CommonTextFormField(
                          controller: _emailController,
                          textInputType: TextInputType.emailAddress,
                          hintText: "admin@gmail.com",
                        ),
                        const SizedBox(height: 20),
                        CommonTextFormField(
                          controller: _passwordController,
                          hintText: "Password",
                        ),
                        const SizedBox(height: 20),
                        DefaultButton(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _login,
                          hight: 50,
                          width: double.infinity,
                          boxShadow: const [BoxShadow()],
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColor.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
