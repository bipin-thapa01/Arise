import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/HomePage/home_page.dart';
import 'package:fitness/standardData.dart';
import 'package:fitness/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

List<Map<String, dynamic>> requiredFields = [
  {'name': 'Age', 'type': 'Input', 'unit': 'years'},
  {
    'name': 'Gender',
    'type': 'Option',
    'options': ['Male', 'Female'],
  },
  {'name': 'Height', 'type': 'Input', 'unit': 'cm'},
  {'name': 'Weight', 'type': 'Input', 'unit': 'kg'},
  {'name': 'Target Weight', 'type': 'Input', 'unit': 'kg'},
  {
    'name': 'Target Body Type',
    'type': 'Option',
    'options': ['Slim', 'Normal', 'Athletic', 'Bulky'],
  },
];
final storage = FlutterSecureStorage();

class InitialSetupForm extends StatefulWidget {
  const InitialSetupForm({super.key});

  @override
  State<InitialSetupForm> createState() => _InitialSetupFormState();
}

class _InitialSetupFormState extends State<InitialSetupForm> {
  final _key = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    for (var item in requiredFields) {
      final String name = item["name"] as String;
      if (item['type'] == 'Input') {
        _controllers[name] = TextEditingController();
      } else {
        _selectedOptions[name] = null;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> submitData() async {
    if (_key.currentState!.validate()) {
      String age = _controllers['Age']!.text;
      String? gender = _selectedOptions['Gender'];
      String height = _controllers['Height']!.text;
      String weight = _controllers['Weight']!.text;
      String targetWeight = _controllers['Target Weight']!.text;
      String? targetBodyType = _selectedOptions['Target Body Type'];

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      final id = FirebaseAuth.instance.currentUser?.uid;

      if (gender == null || targetBodyType == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Select both gender and body type!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection("users").doc(id).update({
          'alreadySetup': true,
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'goalWeight': targetWeight,
          'targetBody': targetBodyType,
        });

        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false,
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
      child: Form(
        key: _key,
        child: Column(
          spacing: 30,
          children: [
            ...requiredFields.map((item) {
              if (item['type'] == 'Input') {
                return TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your ${item['name']}";
                    }
                    return null;
                  },
                  controller: _controllers[item['name']],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    labelText: item['name'],
                    suffixText: item['unit'],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: StandardData.primaryColor),
                    ),
                  ),
                );
              } else {
                final List<String> options = (item['options'] as List)
                    .cast<String>();
                return DropdownMenu(
                  onSelected: (value) {
                    setState(() {
                      _selectedOptions[item['name']] = value;
                    });
                  },
                  label: Text(item['name']),
                  width: MediaQuery.of(context).size.width * 0.9,
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: StandardData.primaryColor),
                    ),
                  ),
                  dropdownMenuEntries: options.map((option) {
                    return DropdownMenuEntry(value: option, label: option);
                  }).toList(),
                  menuStyle: MenuStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              }
            }),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  submitData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: StandardData.primaryColor,
                ),
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
