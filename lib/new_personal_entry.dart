import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'utils/emotion_colors.dart';
import 'package:http/http.dart' as http;

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  _NewEntryPageState createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _contentController = TextEditingController();
  final _gratefulController = TextEditingController();
  final _proudController = TextEditingController();

  String _selectedEmotion = 'neutral';
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedDateGer = DateFormat('dd.MM.yyyy').format(DateTime.now());

  Future<void> _addEntry() async {
    final serverUrl = dotenv.env['SERVER_URL_ENTRY'];
    final uri = Uri.parse(serverUrl!); // check, that serverUrl not null

    final Map<String, dynamic> body = {
      'content': _contentController.text,
      'content_grateful': _gratefulController.text,
      'content_proud': _proudController.text,
      'created_at': formattedDate,
      'emotion_color': _selectedEmotion,
    };

    if (_proudController.text.isNotEmpty) {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        jsonDecode(response.body);
        _proudController.clear();
        Navigator.pop(context, _proudController.text.trim());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Entry insert successful")));
      } else {
        Navigator.pop(context, _proudController.text.trim());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to insert entry")));
      }
    } else {
      _proudController.clear();
      Navigator.pop(context, _proudController.text.trim());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to insert entry")));
    }

    //_fetchEntries(); // Aktualisiert die Liste der Einträge
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
