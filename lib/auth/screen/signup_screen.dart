import 'package:chat_app/auth/screen/user_login_screen.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/services/auth_provider.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:chat_app/my_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


class SignupScreen extends ConsumerWidget{
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final formState=ref.watch(authFormProvider);
    final formNotifier=ref.read(authFormProvider.notifier);
    final authMethod=ref.read(authMethodProvider);


    void signup() async{
      formNotifier.setLoading(true);
      final res=await authMethod.signUpUser(
        email:formState.email,
        password:formState.password,
        name:formState.name,
      );
      formNotifier.setLoading(false);
      if(res=="success" && context.mounted){
        
        showAppSnackbar(
          context:context,
          type:SnackbarType.success,
          description:"Sign Up Successfully"
        );

        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>UserLoginScreen()));
      }else{
        if(context.mounted){
          showAppSnackbar(
            context:context,
            type:SnackbarType.error,
            description:"Error Unsuccessful SignUp",

          );
        }

      }
    }


    double height=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: ListView(
            children: [
              Container(
                height: height/2.4,
                width: double.maxFinite,
                decoration: BoxDecoration(),
                child: Image.asset("assets/images/logo.png"),

              ),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    TextField(
                      autocorrect: false,
                      onChanged: (value)=>formNotifier.updateName(value),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Enter your Name",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formState.nameError,
                      ),
                    ),
                    SizedBox(height: 15,),

                    TextField(
                      autocorrect: false,
                      onChanged: (value)=>formNotifier.updateEmail(value),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "Enter your Email",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formState.emailError,
                      ),
                    ),
                    SizedBox(height:15),


                    TextField(
                      autocorrect: false,
                      obscureText: formState.isPasswordHidden,
                      onChanged: (value)=>formNotifier.updatePassword(value),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Enter your password",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formState.passwordError,
                        suffixIcon: IconButton(
                            onPressed: ()=>formNotifier.togglePasswordVisibility(),
                            icon: Icon(formState.isPasswordHidden?
                            Icons.visibility_off:Icons.visibility
                            ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    formState.isLoading?Center(
                        child: CircularProgressIndicator()):
                        MyButton(
                          onTab:formState.isFormValid?signup:null,
                          buttonText:"Sign Up",
                        ),
                    SizedBox(height:20),
                    Row(
                      children: [
                        Spacer(),
                        Text("Already have an account?"),
                        GestureDetector(
                          onTap:(){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>UserLoginScreen()));
                          },
                          child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold,),
                        ),
                        ),
                      ],
                    )



                  ],
                ),
              )

            ],

      ),
      ),
    );
  }


}