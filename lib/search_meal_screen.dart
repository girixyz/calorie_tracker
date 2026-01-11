import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchMealScreen extends StatefulWidget {
  final String mealType;

  const SearchMealScreen({super.key, required this.mealType});

  @override
  State<SearchMealScreen> createState() => _SearchMealScreenState();
}

class _SearchMealScreenState extends State<SearchMealScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allMeals = [];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = _allMeals;
      });
    } else {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _searchResults = _allMeals.where((meal) {
          return meal['name'].toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> _loadMeals() async {
    final String jsonString = await rootBundle.loadString('assets/meals.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      _allMeals = jsonResponse.map((meal) => meal as Map<String, dynamic>).toList();
      _searchResults = _allMeals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add ${widget.mealType}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search for a meal',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final meal = _searchResults[index];
                  return ListTile(
                    title: Text(meal['name']!),
                    subtitle: Text("${meal['cals']} kcal"),
                    onTap: () {
                      // TODO: Navigate to quantity selection page
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
