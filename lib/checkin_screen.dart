import 'package:flutter/material.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _livedValues = false;
  double _mood = 3.0;
  final TextEditingController _journalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Check-in")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Did you live in accordance with your values today?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text("Yes"), icon: Icon(Icons.check)),
              ButtonSegment(value: false, label: Text("No"), icon: Icon(Icons.close)),
            ],
            selected: {_livedValues},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _livedValues = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            "How are you feeling?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _mood,
            min: 1,
            max: 5,
            divisions: 4,
            label: _mood.round().toString(),
            onChanged: (value) => setState(() => _mood = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text("Drained"), Text("Energized")],
          ),
          const SizedBox(height: 32),
          const Text(
            "Journal (Optional)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _journalController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "What went well? What could be better?",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              // TODO: Submit to Supabase 'daily_logs' table
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Check-in saved!")),
              );
            },
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: const Text("Complete Check-in"),
          ),
        ],
      ),
    );
  }
}