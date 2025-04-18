import 'package:flutter/material.dart';

import 'package:mychat/auth/signup.dart';
import 'package:mychat/dashborad/homepgae.dart';

import '../services/auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  loginUser() async {
    try {
      await AuthService().signIn(email.text, password.text);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
    } catch (e) {
      // Get.snackbar('Error', e.toString(),
      //     backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: email, decoration: const InputDecoration(hintText: 'Email')),
            const SizedBox(height: 10),
            TextField(controller: password, decoration: const InputDecoration(hintText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loginUser, child: const Text('Login')),
            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>SignupScreen()));

              },
              child: const Text('Don\'t have an account? Signup'),
            )
          ],
        ),
      ),
    );
  }
}
