import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/Screens/Workout/workout_detail.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class Workout extends StatefulWidget {
  const Workout({super.key});

  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  int limit = 20;

  int currentPage = 0;
  int totalPages = 1;

  bool isSearching = false;
  String searchQuery = "";

  List<Map<String, dynamic>> visibleWorkouts = [];
  List<Map<String, dynamic>> searchResults = [];

  Future<void> findLength() async {
    final result = await FirebaseFirestore.instance
        .collection("exercises")
        .count()
        .get();

    setState(() {
      totalPages = ((result.count ?? 0) / limit).ceil();
    });
  }

  Future<void> fetchPage(int page) async {
    Query query = FirebaseFirestore.instance
        .collection("exercises")
        .orderBy("name")
        .limit(limit);

    DocumentSnapshot? last;

    for (int i = 0; i < page; i++) {
      final snap = await query.get();

      if (snap.docs.isEmpty) break;

      last = snap.docs.last;

      query = FirebaseFirestore.instance
          .collection("exercises")
          .orderBy("name")
          .startAfterDocument(last)
          .limit(limit);
    }

    final snapshot = await query.get();

    setState(() {
      visibleWorkouts = snapshot.docs
          .map((e) => e.data() as Map<String, dynamic>)
          .toList();

      currentPage = page;
    });
  }

  Future<void> searchWorkout(String value) async {
    searchQuery = value.toLowerCase();

    if (searchQuery.isEmpty) {
      isSearching = false;
      currentPage = 0;
      await fetchPage(0);
      return;
    }

    isSearching = true;

    final snapshot = await FirebaseFirestore.instance
        .collection("exercises")
        .get();

    searchResults = snapshot.docs
        .map((e) => e.data())
        .where(
          (data) => data["name"].toString().toLowerCase().contains(searchQuery),
        )
        .toList();

    setState(() {
      currentPage = 0;
      totalPages = (searchResults.length / limit).ceil();
    });
  }

  List<Map<String, dynamic>> get displayedWorkouts {
    if (isSearching) {
      final start = currentPage * limit;
      final end = (start + limit) > searchResults.length
          ? searchResults.length
          : start + limit;

      if (start >= searchResults.length) return [];

      return searchResults.sublist(start, end);
    }

    return visibleWorkouts;
  }

  void nextPage() {
    if (currentPage + 1 >= totalPages) return;

    setState(() {
      currentPage++;
    });

    if (!isSearching) {
      fetchPage(currentPage);
    }
  }

  void prevPage() {
    if (currentPage == 0) return;

    setState(() {
      currentPage--;
    });

    if (!isSearching) {
      fetchPage(currentPage);
    }
  }

  @override
  void initState() {
    super.initState();
    findLength();
    fetchPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            pinned: true,
            title: const Text(
              "Workout",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: StandardData.backgroundColor1,
                  hintText: "Search an Exercise",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    isSearching = false;
                    currentPage = 0;
                    findLength();
                    fetchPage(0);
                  }
                },
                onFieldSubmitted: (value) {
                  searchWorkout(value);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Available Workouts",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: displayedWorkouts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No workouts found")),
                  )
                : Column(
                    children: [
                      ListView.builder(
                        padding: EdgeInsets.all(0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedWorkouts.length,
                        itemBuilder: (context, index) {
                          final workout = displayedWorkouts[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WorkoutDetail(workout: workout),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                                left: 10,
                                right: 10,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: StandardData.backgroundColor1,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}. ${workout["name"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("Category: ${workout["category"]}"),
                                  Text(
                                    "Equipment: ${workout["equipment"] ?? "none"}",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // PAGINATION
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: prevPage,
                              icon: const Icon(Icons.arrow_back),
                            ),

                            Text(
                              "Page ${currentPage + 1} / $totalPages",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              onPressed: nextPage,
                              icon: const Icon(Icons.arrow_forward),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
