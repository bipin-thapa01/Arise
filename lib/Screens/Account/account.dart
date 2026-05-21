import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      setState(() {
        user = userDoc.data() ?? {};
      });
    } catch (e) {
      StandardData.normalSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                width: 100,
                height: 100,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Image.asset("assets/user.png", fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                user["displayName"] ?? "",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined, size: 20, color: Colors.grey),
                SizedBox(width: 5),
                Text(user["email"] ?? "", style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 5),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: StandardData.purpleTint,
                  border: Border.all(
                    width: 1,
                    color: StandardData.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Goal: ${user["targetBody"] ?? ""}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: StandardData.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: StandardData.borderStrong),
                borderRadius: BorderRadius.circular(10),
                color: StandardData.backgroundColor1,
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: StandardData.purpleTint,
                            ),
                            child: Icon(
                              Icons.monitor_weight_outlined,
                              color: StandardData.primaryColor,
                              size: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: user["weight"] ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: ' kg',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Current",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Colors.white12,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: StandardData.amberTint,
                            ),
                            child: Icon(
                              Icons.straighten,
                              color: StandardData.amberColor,
                              size: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: user["height"] ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: ' cm',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Height",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Colors.white12,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: StandardData.tealTint,
                            ),
                            child: Icon(
                              Icons.track_changes,
                              color: StandardData.tealColor,
                              size: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: user["goalWeight"] ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: ' kg',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Goal",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text(
            //   "Details",
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: StandardData.primaryColor,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // SizedBox(height: 25),
            // Text("Age: ${user["age"] ?? ""}"),
            // SizedBox(height: 25),
            // Text("Gender: ${user["gender"] ?? ""}"),
            // SizedBox(height: 25),
            // Text("Weight: ${user["weight"] + " kg" ?? ""}"),
            // SizedBox(height: 25),
            // Text("Goal Weight: ${user["goalWeight"] + " kg" ?? ""}"),
            // SizedBox(height: 25),
            // Text("Height: ${user["height"] + " cm" ?? ""}"),
            // SizedBox(height: 25),
            // Text("Email: ${user["email"] ?? ""}"),
            // SizedBox(height: 25),
            // Text("Preferred Body Type: ${user["targetBody"] ?? ""}"),
          ],
        ),
      ),
    );
  }
}
