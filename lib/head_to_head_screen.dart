import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:axistella/final_cut_screen.dart';

class HeadToHeadScreen extends StatefulWidget {
  final List<String> initialValues;

  const HeadToHeadScreen({super.key, required this.initialValues});

  @override
  State<HeadToHeadScreen> createState() => _HeadToHeadScreenState();
}

class _HeadToHeadScreenState extends State<HeadToHeadScreen> {
  late List<List<String>> _comparisonQueue;
  late Map<String, int> _scores;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeComparisons();
  }

  void _initializeComparisons() {
    _scores = {for (var v in widget.initialValues) v: 0};
    _comparisonQueue = [];
    final values = widget.initialValues;
    
    // Generate pairs
    for (int i = 0; i < values.length; i++) {
      for (int j = i + 1; j < values.length; j++) {
        _comparisonQueue.add([values[i], values[j]]);
      }
    }
    _comparisonQueue.shuffle();
  }

  void _handleSelection(String winner) {
    HapticFeedback.lightImpact();
    setState(() {
      _scores[winner] = (_scores[winner] ?? 0) + 1;
      if (_currentIndex < _comparisonQueue.length - 1) {
        _currentIndex++;
      } else {
        _finish();
      }
    });
  }

  void _finish() {
    final sortedList = widget.initialValues.toList()
      ..sort((a, b) => (_scores[b] ?? 0).compareTo(_scores[a] ?? 0));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FinalCutScreen(rankedValues: sortedList)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_comparisonQueue.isEmpty) return const Scaffold();

    final currentPair = _comparisonQueue[_currentIndex];
    final progress = (_currentIndex + 1) / _comparisonQueue.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prioritize"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            const Text("Which is more important to you?", style: TextStyle(fontSize: 20)),
            const Spacer(),
            _buildCard(currentPair[0]),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("VS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildCard(currentPair[1]),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text) {
    return Expanded(
      flex: 4,
      child: GestureDetector(
        onTap: () => _handleSelection(text),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}