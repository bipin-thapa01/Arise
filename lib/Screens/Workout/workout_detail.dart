import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/Workout/image_slider.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class WorkoutDetail extends StatefulWidget {
  final Map<String, dynamic> workout;
  const WorkoutDetail({super.key, required this.workout});

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    checkFavourite();
  }

  Future<void> checkFavourite() async {
    String name = widget.workout['name'];
    try {
      final favWorkout = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("favWorkouts")
          .where("name", isEqualTo: name)
          .get();
      if (favWorkout.docs.isNotEmpty) {
        setState(() {
          isFavourite = true;
        });
      }
    } catch (e) {
      StandardData.normalSnackbar(context, "Error checking fav workout");
    }
  }

  Future<void> addFavourite() async {
    if (widget.workout["name"] == null || widget.workout["name"] == "") {
      StandardData.normalSnackbar(
        context,
        "Workout without name cannot be set as fav",
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("favWorkouts")
          .add({"name": widget.workout["name"], "date": DateTime.now()});
      setState(() {
        isFavourite = true;
      });
    } catch (e) {
      StandardData.normalSnackbar(context, "Error setting fav workout");
    }
  }

  Future<void> removeFavourite() async {
    try {
      final workout = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("favWorkouts")
          .where("name", isEqualTo: widget.workout["name"])
          .get();
      workout.docs.first.reference.delete();
      setState(() {
        isFavourite = false;
      });
    } catch (e) {
      StandardData.normalSnackbar(context, "Error removing fav workout");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> instructions = widget.workout['instructions'] ?? [];
    final List<dynamic> images = widget.workout['images'] ?? [];
    final accentColor = StandardData.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new),
            ),
            actions: [
              isFavourite
                  ? IconButton(
                      onPressed: () {
                        removeFavourite();
                      },
                      icon: Icon(Icons.favorite_outlined),
                    )
                  : IconButton(
                      onPressed: () {
                        addFavourite();
                      },
                      icon: Icon(Icons.favorite_border),
                    ),
              const SizedBox(width: 10),
            ],
          ),
          SliverToBoxAdapter(child: ImageSlider(images: images)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workout['name']?.toUpperCase() ?? "WORKOUT",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGlassInfoBar(accentColor),

                  const SizedBox(height: 30),
                  const Text(
                    "MUSCLE GROUPS",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMuscleSection(),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "EXECUTION",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${instructions.length} Steps",
                        style: TextStyle(color: accentColor, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...instructions.asMap().entries.map((entry) {
                    return _buildInstructionCard(
                      entry.key + 1,
                      entry.value,
                      accentColor,
                    );
                  }).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInfoBar(Color accent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          color: Colors.white.withOpacity(0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoColumn("Level", widget.workout['level'], accent),
              _verticalDivider(),
              _infoColumn(
                "Equipment",
                widget.workout['equipment'] ?? "None",
                accent,
              ),
              _verticalDivider(),
              _infoColumn("Force", widget.workout['force'] ?? "Static", accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value, Color accent) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value.toUpperCase(),
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() =>
      Container(height: 20, width: 1, color: Colors.white10);

  Widget _buildMuscleSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var m in widget.workout['primaryMuscles'] ?? [])
          _muscleChip(m, true),
        for (var m in widget.workout['secondaryMuscles'] ?? [])
          _muscleChip(m, false),
      ],
    );
  }

  Widget _muscleChip(String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: StandardData.primaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StandardData.primaryColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInstructionCard(int step, String text, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$step",
            style: TextStyle(
              color: accent,
              fontSize: 24,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
