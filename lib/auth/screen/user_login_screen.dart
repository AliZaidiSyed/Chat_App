
import 'package:flutter/material.dart';
import 'package:chat_app/auth/screen/google_login_screen.dart';
import 'package:chat_app/auth/screen/signup_screen.dart';
import 'package:chat_app/services/auth_provider.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/chat/screens/app_home_screen.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:chat_app/my_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
class UserLoginScreen extends ConsumerWidget {
  const UserLoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    final formState = ref.watch(authFormProvider);
    final formNotifer = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);
    void login() async {
      formNotifer.setLoading(true);
      final res = await authMethod.loginUser(
        email: formState.email,
        password: formState.password,
      );
      formNotifer.setLoading(false);
      if (res == "success" && context.mounted) {


        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Successful Login",
        );
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>MainHomeScreen()));
      } else {
        if(context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.error,
            description: "Error Unsuccessful Login",
          );
        }
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height / 2.1,
              width: double.maxFinite,
              child: Image.asset("assets/images/logo.png"),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    autocorrect: false,
                    onChanged: (value) => formNotifer.updateEmail(value),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: "Enter your email",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(15),
                      errorText: formState.emailError,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    autocorrect: false,
                    onChanged: (value) => formNotifer.updatePassword(value),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: formState.isPasswordHidden,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: "Enter your password",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(15),
                      errorText: formState.passwordError,
                      suffixIcon: IconButton(
                        onPressed: () => formNotifer.togglePasswordVisibility(),
                        icon: Icon(
                          formState.isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  formState.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : MyButton(
                    onTab: formState.isFormValid ? login : null,
                    buttonText: "Login",
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.black26),
                      ),
                      Text(" or "),
                      Expanded(
                        child: Container(height: 1, color: Colors.black26),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // for google auth
                  GoogleLoginScreen(),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Spacer(),
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>SignupScreen()));
                        },
                        child: Text(
                          "SignUp",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}