import 'package:flutter/material.dart';
import 'package:chat_app/core/theme/app_colors.dart';

class MyButton extends StatelessWidget{
  final VoidCallback? onTab;
  final String buttonText;


  const MyButton ({
    super.key,
    required this.onTab,
    required this.buttonText,
  });


  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
          onPressed: onTab,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.grey.shade600,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        child: Text(
          buttonText,
          style:  TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}