import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:mychat/services/auth.dart';
import '../dashborad/homepgae.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();

  signupUser() async {
    try {
      User? user = await AuthService().signUp(
        email.text.trim(),
        password.text.trim(),
        name.text.trim(),
        context,
      );
      if (user != null) {
        showToast("Signup Successful", context: context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        showToast("Signup failed", context: context);
      }
    } catch (e) {
      print('Error during sign-up: $e');
      showToast("Error: $e", context: context);
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
            TextField(controller: name, decoration: const InputDecoration(hintText: 'Name')),
            const SizedBox(height: 10),
            TextField(controller: email, decoration: const InputDecoration(hintText: 'Email')),
            const SizedBox(height: 10),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signupUser, child: const Text('Signup')),
          ],
        ),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';
// import 'package:mychat/services/auth.dart';
// import '../dashborad/homepgae.dart';
// import 'login.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final email = TextEditingController();
//   final password = TextEditingController();
//   final Name = TextEditingController();
//
//   signupUser() async {
//     try {
//       User? user = await AuthService().signUp(
//           email.text, password.text, Name.text, context);
//       if (user != null) {
//         // Show success message, navigate, etc.
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => HomeScreen()),
//         );
//       } else {
//       showToast("failed");
//       }
//     } catch (e) {
//       // Display error if there's an issue
//       print('Error during sign-up: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(controller: Name, decoration: const InputDecoration(hintText: 'Name')),
//             const SizedBox(height: 10),
//             TextField(controller: email, decoration: const InputDecoration(hintText: 'Email')),
//             const SizedBox(height: 10),
//             TextField(controller: password, decoration: const InputDecoration(hintText: 'Password')),
//             const SizedBox(height: 20),
//             ElevatedButton(onPressed: signupUser, child: const Text('Signup')),
//           ],
//         ),
//       ),
//     );
//   }
// }
