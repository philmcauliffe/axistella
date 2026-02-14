import 'package:flutter/material.dart';
import 'package:axistella/head_to_head_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  // Mock Data: In real app, fetch from Supabase 'core_values' table
  final List<String> _allValues = [
    "Integrity", "Freedom", "Creativity", "Family", "Wealth", 
    "Adventure", "Compassion", "Leadership", "Knowledge", "Peace",
    "Loyalty", "Growth", "Balance", "Justice", "Recognition"
  ];

  final Set<String> _selectedValues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover Values"),
        actions: [
          TextButton(
            onPressed: _selectedValues.length >= 3 
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HeadToHeadScreen(
                        initialValues: _selectedValues.toList(),
                      ),
                    ),
                  );
                }
              : null,
            child: const Text("Next"),
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select values that resonate with you. Don't overthink it; just pick what feels right.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _allValues.length,
              itemBuilder: (context, index) {
                final value = _allValues[index];
                final isSelected = _selectedValues.contains(value);
                return FilterChip(
                  label: Center(child: Text(value)),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedValues.add(value);
                      } else {
                        _selectedValues.remove(value);
                      }
                    });
                  },
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}