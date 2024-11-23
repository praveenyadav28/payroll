// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                          onTap: () {
                            if (_emailController.text.isEmpty) {
                              showCustomSnackbar(
                                  context, "Please enter Email Id");
                            } else if (_passwordController.text.isEmpty ||
                                _passwordController.text.length < 6) {
                              showCustomSnackbar(
                                  context, "Please enter valid Password");
                            } else {
                              loginPostApi();
                            }
                          },
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

  Future loginPostApi() async {
    var response =
        await ApiService.postData("TransactionsPayroll/PayrollLOGINValid", {
      "MailId": _emailController.text.toString(),
      "Password": _passwordController.text.toString(),
    });

    if (response["result"] == true) {
      Preference.setBool(PrefKeys.userstatus, response['result']);
      Preference.setString(PrefKeys.locationId, response['locationId']);
      Preference.setString(PrefKeys.userType, response['userType']);

      Navigator.pushReplacementNamed(context, '/dashboard');

      showCustomSnackbarSuccess(context, response['message']);
    } else {
      showCustomSnackbar(context, response['message']);
    }
  }
}
