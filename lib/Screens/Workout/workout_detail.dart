import 'dart:ui';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class WorkoutDetail extends StatefulWidget {
  final Map<String, dynamic> workout;
  const WorkoutDetail({super.key, required this.workout});

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  final PageController _pageController = PageController();
  final String url =
      "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/";

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
            expandedHeight: 400,
            backgroundColor: Colors.black,
            leading: _buildCircularButton(
              Icons.arrow_back_ios_new,
              () => Navigator.pop(context),
            ),
            actions: [
              _buildCircularButton(Icons.favorite_border, () {}),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.isEmpty ? 1 : images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        "$url${widget.workout["images"][0]}",
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1C1C1E),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 50,
                                color: accentColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Preview Unavailable",
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: accentColor,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF121212)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildCircularButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.black38,
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 20),
          onPressed: onTap,
        ),
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
