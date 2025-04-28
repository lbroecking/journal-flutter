import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'utils/emotion_colors.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final supabase = Supabase.instance.client;
  final _contentController = TextEditingController();
  final _gratefulController = TextEditingController();
  final _proudController = TextEditingController();

  String _selectedEmotion = 'neutral';
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedDateGer = DateFormat(
      'dd.MM.yyyy',
    ).format(DateTime.now()); 

  Future<void> _addEntry() async {
    final user = supabase.auth.currentUser;

    if (user != null && _proudController.text.isNotEmpty) {
      await supabase.from('journal_entries').insert({
        'user_id': user.id,
        'content': _contentController.text,
        'content_grateful': _gratefulController.text,
        'content_proud': _proudController.text,
        'created_at': formattedDate,
        'emotion_color': _selectedEmotion,
      });
      _proudController.clear();
      Navigator.pop(context, _proudController.text.trim());
      //_fetchEntries(); // Aktualisiert die Liste der Einträge
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Entry - $formattedDateGer")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: "Write about your day today...",
              ),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _gratefulController,
              decoration: InputDecoration(
                labelText: "What are you grateful for today?",
              ),
              maxLines: 2,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _proudController,
              decoration: InputDecoration(
                labelText: "What are you proud about today?",
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('How do you feel?'),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedEmotion,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEmotion = newValue!;
                    });
                  },
                  items:
                      emotionColors.keys.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color:
                                    emotionColors[value], // Farbe der Emotion
                              ),
                              SizedBox(width: 10),
                              Text(value), // Name der Emotion
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),

            SizedBox(height: 10),

            FloatingActionButton(
              onPressed: _addEntry,
              tooltip: "Save your reflections",
              child: Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }
}
