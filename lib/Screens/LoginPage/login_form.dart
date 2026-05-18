import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/ForgotPasswordPage/forgot_password.dart';
import 'package:fitness/Screens/HomePage/home_page.dart';
import 'package:fitness/Screens/InitialSetup/initial_setup.dart';
import 'package:fitness/Screens/SignupPage/signup_page.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Map<String, String> requiredField = {
  'Email Address': 'Text',
  'Password': 'Password',
};

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    for (var key in requiredField.keys) {
      _controllers[key] = TextEditingController();
    }
    _login();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  //to fetch email if an old user
  Future<void> _login() async {
    String? email = await storage.read(key: 'email');
    if (email != null) {
      setState(() {
        _controllers['Email Address']!.text = email;
      });
    }
  }

  //to authenticate user
  Future<void> _authenticate() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    final email = _controllers['Email Address']!.text;
    final password = _controllers['Password']!.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await storage.write(key: "email", value: email);

      final id = FirebaseAuth.instance.currentUser?.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .get();
      bool alreadySetup = userDoc.data()?['alreadySetup'];
      Navigator.pop(context);
      if (!alreadySetup) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InitialSetup()),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      Navigator.pop(context);
      StandardData.normalSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 30,
          children: [
            ...requiredField.entries.map((item) {
              bool isPassword = item.value == 'Password';
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: _controllers[item.key],
                  obscureText: isPassword ? _isObscured : false,
                  decoration: InputDecoration(
                    prefixIcon: isPassword
                        ? Icon(Icons.lock)
                        : Icon(Icons.email),
                    suffixIcon: isPassword
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          )
                        : null,
                    hint: Text(item.key),
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        width: 1,
                        color: StandardData.primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
            Column(
              spacing: 20,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPassword()),
                    );
                  },
                  child: Text("Forgot Password?"),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _authenticate();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StandardData.primaryColor,
                    ),
                    child: Text("Log in"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: Text(
                        "Signup",
                        style: TextStyle(color: StandardData.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
