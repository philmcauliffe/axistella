import 'package:flutter/material.dart';

class FinalCutScreen extends StatefulWidget {
  final List<String> rankedValues;

  const FinalCutScreen({super.key, required this.rankedValues});

  @override
  State<FinalCutScreen> createState() => _FinalCutScreenState();
}

class _FinalCutScreenState extends State<FinalCutScreen> {
  late List<String> _values;

  @override
  void initState() {
    super.initState();
    _values = List.from(widget.rankedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Final Cut"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Save top 5 to Supabase 'user_values' table
              // TODO: Navigate to Purpose Statement Generation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Values saved! Generating purpose...")),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Drag to reorder. Items above the line are your Primal Five.",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _values.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _values.removeAt(oldIndex);
                  _values.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final isPrimal = index < 5;
                return Column(
                  key: ValueKey(_values[index]),
                  children: [
                    ListTile(
                      tileColor: isPrimal ? Colors.deepPurple.shade50 : Colors.white,
                      title: Text(
                        "${index + 1}. ${_values[index]}",
                        style: TextStyle(
                          fontWeight: isPrimal ? FontWeight.bold : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                    if (index == 4) ...[
                      const Divider(
                        thickness: 3,
                        color: Colors.deepPurpleAccent,
                        height: 0,
                      ),
                      Container(
                        width: double.infinity,
                        color: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Text("PRIMAL FIVE", 
                          textAlign: TextAlign.center, 
                          style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 2)),
                      )
                    ] else const Divider(height: 0),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}