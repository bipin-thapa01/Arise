import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();

  Future<void> forgotPassword() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email.text.trim())
          .get();
      if (query.docs.isEmpty) {
        StandardData.normalSnackbar(context, "No user found with this email");
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.text.trim(),
      );
      StandardData.normalSnackbar(context, "Password reset email sent");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        StandardData.normalSnackbar(context, "Invalid Email");
      } else if (e.code == 'too-many-requests') {
        StandardData.normalSnackbar(context, "Too many requests");
      } else {
        StandardData.normalSnackbar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: Column(
                children: [
                  Text(
                    "Forgot Password",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                  ),
                  Text("Enter your email to reset your password"),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 30,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hint: Text("Email Address"),
                          filled: true,
                          fillColor: StandardData.backgroundColor1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          forgotPassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StandardData.primaryColor,
                        ),
                        child: Text("Continue"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
