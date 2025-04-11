import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_page.dart';
import '../new_personal_entry.dart';
import '../utils/emotion_colors.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final supabase = Supabase.instance.client;
  String _selectedEmotion = 'neutral';
  
  List<Map<String, dynamic>> _entries = [];

  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _logout(BuildContext context) async {
    await supabase.auth.signOut(); // Supabase Logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthPage(),
      ), // Zur AuthPage navigieren
    );
  }

  Future<void> _fetchEntries() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('journal_entries')
          .select('*, profiles(username)') // Join mit profiles-Tabelle
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      setState(() {
        _entries = List<Map<String, dynamic>>.from(response);
      });
    }
  }

  Future<void> _updateEntry(
    int entryId,
    String newContent,
    String emotion,
  ) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('journal_entries')
        .update({
          'content': newContent, // Neuen Inhalt speichern
          'emotion_color': emotion, // Neue Emotion speichern
        })
        .eq('id', entryId); // Eintrag nach ID aktualisieren

    if (response != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fehler")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Updated Entry!")));
      _fetchEntries();
    }
  }

  void _editEntry(BuildContext context, Map<String, dynamic> entry) {
    TextEditingController controller = TextEditingController(
      text: entry['content'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Textfeld für den Inhalt des Eintrags
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: "Update your entry"),
              ),
              SizedBox(height: 20),
              // Dropdown für die Auswahl der Emotion
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
                              color: emotionColors[value], // Farbe der Emotion
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
          actions: [
            // "Cancel"-Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            // "Save"-Button
            TextButton(
              onPressed: () async {
                // Update in Supabase mit neuem Inhalt und Emotion
                await _updateEntry(
                  entry['id'],
                  controller.text,
                  _selectedEmotion,
                );
                Navigator.pop(context); // Dialog schließen
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) {
      return Scaffold(
        body: Text('No favorites yet.'),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final newEntry = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewEntryPage()),
            );
            _fetchEntries();
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Journal"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Logout-Button
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children:
            _entries.map((entry) {
              return Card(
                color: emotionColors[entry['emotion_color']] ?? Colors.white,
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    entry['content']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween, // Verteilt die Elemente links & rechts
                    children: [
                      Text(entry['profiles']['username']),
                      Text(entry['created_at']),
                    ],
                  ),
                  onLongPress: AboutListTile.new,
                  //onTap: () => _editEntry(context, entry), // Bearbeiten
                ),
              );
            }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newEntry = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewEntryPage()),
          );
          _fetchEntries();
        },
      ),
    );
  }
}
