import 'dart:convert';

import 'package:calorie_tracker/search_meal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; // The new charting engine

void main() {
  runApp(const DesiCalorieTrackerApp());
}

class DesiCalorieTrackerApp extends StatelessWidget {
  const DesiCalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desi Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- MOCK DATA ---
  final int totalCalories = 1250;
  final double carbPercent = 40;
  final double proteinPercent = 30;
  final double fatPercent = 20;
  final double fiberPercent = 10;

  List<Map<String, dynamic>> todaysMeals = [];

  @override
  void initState() {
    super.initState();
    _loadTodaysMeals();
  }

  Future<void> _loadTodaysMeals() async {
    final String jsonString = await rootBundle.loadString('assets/meals.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      todaysMeals = jsonResponse.map((meal) => meal as Map<String, dynamic>).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      HomeScreen(
          totalCalories: totalCalories,
          carbPercent: carbPercent,
          proteinPercent: proteinPercent,
          fatPercent: fatPercent,
          fiberPercent: fiberPercent,
          todaysMeals: todaysMeals),
      MacrosScreen(todaysMeals: todaysMeals),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Macros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final int totalCalories;
  final double carbPercent;
  final double proteinPercent;
  final double fatPercent;
  final double fiberPercent;
  final List<Map<String, dynamic>> todaysMeals;

  const HomeScreen(
      {super.key,
      required this.totalCalories,
      required this.carbPercent,
      required this.proteinPercent,
      required this.fatPercent,
      required this.fiberPercent,
      required this.todaysMeals});

  Future<void> _showMealTypePopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Track a Meal'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _mealTypeOption(context, 'Breakfast'),
                _mealTypeOption(context, 'Lunch'),
                _mealTypeOption(context, 'Dinner'),
                _mealTypeOption(context, 'Snacks'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mealTypeOption(BuildContext context, String mealType) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // Close the dialog
        _navigateToSearchScreen(context, mealType);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(mealType, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  void _navigateToSearchScreen(BuildContext context, String mealType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchMealScreen(mealType: mealType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. WELCOME TEXT
              Text(
                "Hello, User",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                "Keep up the good work!",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // 2. TOP COMPONENT (Chart + Add Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // The Macro Donut Chart
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4, // Gap between sections
                            centerSpaceRadius: 65, // Makes it "Hollow"
                            startDegreeOffset: -90,
                            sections: _buildChartSections(),
                          ),
                        ),
                        // Text inside the hollow part
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$totalCalories",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const Text(
                                "Kcal",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // The "Add Meal" Plus Button
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => _showMealTypePopup(context),
                          icon: const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        "Track Meals",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      )
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // Legend for the user to understand the colors
              _buildLegend(),

              const SizedBox(height: 40),

              // 3. BOTTOM COMPONENT (Summary List)
              const Text(
                "Today's Meals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  itemCount: todaysMeals.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final meal = todaysMeals[index];
                    return _buildMealTile(meal);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  List<PieChartSectionData> _buildChartSections() {
    return [
      // Protein (Orange)
      PieChartSectionData(
        value: proteinPercent,
        color: Colors.orangeAccent,
        radius: 12, // Thickness of the border
        showTitle: false,
      ),
      // Carbs (Green)
      PieChartSectionData(
        value: carbPercent,
        color: Colors.greenAccent.shade700,
        radius: 12,
        showTitle: false,
      ),
      // Fats (Yellow)
      PieChartSectionData(
        value: fatPercent,
        color: Colors.amber,
        radius: 12,
        showTitle: false,
      ),
      // Fiber (Blue)
      PieChartSectionData(
        value: fiberPercent,
        color: Colors.blueAccent,
        radius: 12,
        showTitle: false,
      ),
    ];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.greenAccent.shade700, "Carbs"),
        const SizedBox(width: 15),
        _legendItem(Colors.orangeAccent, "Protein"),
        const SizedBox(width: 15),
        _legendItem(Colors.amber, "Fat"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMealTile(Map<String, dynamic> meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Very subtle background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meal['qty']!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          Text(
            "${meal['cals']} kcal",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class MacrosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> todaysMeals;

  const MacrosScreen({super.key, required this.todaysMeals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Macros Breakdown",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: todaysMeals.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final meal = todaysMeals[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal['name'],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _macroItem(Colors.greenAccent.shade700, "Carbs", meal['carbs']),
                              _macroItem(Colors.orangeAccent, "Protein", meal['protein']),
                              _macroItem(Colors.amber, "Fat", meal['fat']),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _macroItem(Color color, String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          "${value}g",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        )
      ],
    );
  }
}


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Profile",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text("This is where your profile information will be."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
