import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'utils/rel_questions.dart';

class NewRelationshipEntryPage extends StatefulWidget {
  const NewRelationshipEntryPage({super.key});

  @override
  State<NewRelationshipEntryPage> createState() => _NewRelationshipEntryPageState();
}

class _NewRelationshipEntryPageState extends State<NewRelationshipEntryPage> {
  final supabase = Supabase.instance.client;

  final Map<String, bool> selected = {};
  final Map<String, TextEditingController> controllers = {};

 

  @override
  void initState() {
    super.initState();
    for (var question in questions) {
      selected[question] = false;
      controllers[question] = TextEditingController();
    }
  }

  Future<void> _saveAnswers() async {
    final user = supabase.auth.currentUser;
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (user != null) {
      for (var q in questions) {
        if (selected[q]! && controllers[q]!.text.trim().isNotEmpty) {
          await supabase.from('relationship_check').insert({
            'user_id': user.id,
            'question': q,
            'answer': controllers[q]!.text.trim(),
            'created_at': now,
          });
        }
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Relationship Reflection")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: questions.map((q) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(q),
                  value: selected[q],
                  onChanged: (val) {
                    setState(() {
                      selected[q] = val!;
                    });
                  },
                ),
                if (selected[q]!)
                  TextField(
                    controller: controllers[q],
                    decoration: InputDecoration(
                      hintText: "Enter your answer...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAnswers,
        tooltip: "Save your reflections",
        child: Icon(Icons.save),
      ),
    );
  }
}