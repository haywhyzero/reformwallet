import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

@override
State<SignUp> createState() => _SignUpState();

}


class _SignUpState extends State<SignUp> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Image goes here'),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
             label: Text('Email Address'), 
            ),
          ),
          SizedBox(),
          TextField(
            controller: _passController,
            decoration: InputDecoration(
             label: Text('password'), 
             suffixIcon: Icon(Icons.visibility),
            ),
          ),
          SizedBox(),
          TextField(
            controller: _passController,
            decoration: InputDecoration(
             label: Text('confirm password'), 
             suffixIcon: Icon(Icons.visibility_off),
            ),
            
          ),
          SizedBox(),
         
         Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Already have an account? '),
            SizedBox(width: 5,),
            Text('Sign-In'),
          ],
         )

        ],
      ),
    );
  }
}