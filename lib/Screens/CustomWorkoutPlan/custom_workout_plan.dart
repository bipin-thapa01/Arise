import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class CustomWorkoutPlan extends StatefulWidget {
  const CustomWorkoutPlan({super.key});

  @override
  State<CustomWorkoutPlan> createState() => _CustomWorkoutPlanState();
}

class _CustomWorkoutPlanState extends State<CustomWorkoutPlan> {
  final List<Map<String, dynamic>> content = [
    {"name": "Workout Plan Name", "type": "text"},
    {"name": "Frequency (eg. 6 days / week )", "type": "number"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Custom Workout Plan"),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Text(
                "Create your own custom workout plan!",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Form(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ...content.map((data) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.only(bottom: 15),
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: StandardData.buttonColor1,
                          labelText: data["name"],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: StandardData.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
