import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';
import 'new_personal_entry.dart';
import 'new_relationship_entry.dart';
import 'utils/emotion_colors.dart';
import 'package:intl/intl.dart';

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
      String table;
      String selectFields;

      // Tabelle & Select-Query je nach Tab definieren
      switch (selectedIndex) {
        case 0:
          table = 'journal_entries';
          selectFields =
              'id, content, content_grateful, content_proud, emotion_color, created_at, profiles(username)';
          break;
        case 1:
          table = 'relationship_check';
          selectFields = 'id, question, answer, created_at, profiles(username)';
          break;
        default:
          table = 'journal_entries';
          selectFields = '*';
      }

      final response = await supabase
          .from(table)
          .select(selectFields)
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _entries = List<Map<String, dynamic>>.from(response);
      });
    }
  }

Future<void> _deleteEntry(Map<String, dynamic> entry) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('journal_entries') // deine Tabelle
      .delete()
      .eq('id', entry['id']);

 if (response != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Deleted Entry!")));
      _fetchEntries();
    }
}

Future<void> _deleteRelEntry(Map<String, dynamic> entry) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('relationship_check') // deine Tabelle
      .delete()
      .eq('id', entry['id']);

 if (response != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Deleted Entry!")));
      _fetchEntries();
    }
}


  Future<void> _updateEntry(
    int entryId,
    String newContent,
    String newGrateful,
    String newProud,
    String emotion,
  ) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('journal_entries')
        .update({
          'content': newContent,
          'content_grateful': newGrateful,
          'content_proud': newProud,
          'emotion_color': emotion,
        })
        .eq('id', entryId); // Eintrag nach ID aktualisieren

    if (response != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Updated Entry!")));
      _fetchEntries();
    }
  }

  Future<void> _updateRelEntry(int entryId, String newContent) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('relationship_check')
        .update({
          'answer': newContent, // Neuen Antwort speichern
        })
        .eq('id', entryId); // Eintrag nach ID aktualisieren

    if (response != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
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

    TextEditingController gratefulController = TextEditingController(
      text: entry['content_grateful'],
    );

    TextEditingController proudController = TextEditingController(
      text: entry['content_proud'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Write your day today...",
                ),
                maxLines: 5,
              ),
              SizedBox(height: 10),
              TextField(
                controller: gratefulController,
                decoration: InputDecoration(
                  labelText: "What are you grateful for today?",
                ),
                maxLines: 2,
              ),
              SizedBox(height: 10),
              TextField(
                controller: proudController,
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
                  gratefulController.text,
                  proudController.text,
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

  void _editRelEntry(BuildContext context, Map<String, dynamic> entry) {
    TextEditingController controller = TextEditingController(
      text: entry['answer'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry['question']),
              SizedBox(height: 10),
              // Textfeld für den Inhalt des Eintrags
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: "Update your answer"),
              ),
              SizedBox(height: 20),
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
                await _updateRelEntry(entry['id'], controller.text);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Journal"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          _fetchEntries(); // Filter bei Wechsel neu laden
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Personal'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Relationship',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      selectedIndex == 0
                          ? NewEntryPage() // Wenn "journal_entries" aktiv
                          : NewRelationshipEntryPage(), // Wenn "relationship_check" aktiv
            ),
          );
          _fetchEntries(); // Reload der Einträge
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_entries.isEmpty) {
      return Center(child: Text('No entries yet.'));
    }

    return ListView(
      padding: EdgeInsets.all(10),
      children:
          _entries.map((entry) {
            // Farben nur bei personal
            final backgroundColor =
                selectedIndex == 0
                    ? emotionColors[entry['emotion_color']] ?? Colors.white
                    : Colors.grey[200];

            // Titel + Zusatzinfos
            final title =
                selectedIndex == 0
                    ? entry['content'] ?? ''
                    : entry['question'] ?? 'Kein Status';

            // Zusätzliche Daten je nach Tab:
            final additionalContent =
                selectedIndex == 0
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry['content_grateful'] != null &&
                            entry['content_grateful'].toString().isNotEmpty)
                          Text("Grateful: ${entry['content_grateful']}"),
                        if (entry['content_proud'] != null &&
                            entry['content_proud'].toString().isNotEmpty)
                          Text("Proud: ${entry['content_proud']}"),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry['answer'] != null) Text("${entry['answer']}"),
                      ],
                    );

            final subtitleWidgets = <Widget>[
              //Text(entry['profiles']['username'] ?? ''),
              Text(
                DateFormat(
                  'dd.MM.yyyy',
                ).format(DateTime.parse(entry['created_at'])),
              ),
            ];

            return Card(
              color: backgroundColor,
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    additionalContent,
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: subtitleWidgets,
                    ),
                  ],
                ),
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Wrap(
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Bearbeiten'),
                            onTap: () {
                              Navigator.pop(context); // Modal schließen
                              if (selectedIndex == 0) {
                                _editEntry(context, entry);
                              } else {
                                _editRelEntry(context, entry);
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Löschen'),
                            onTap: () {
                              if (selectedIndex == 0) {
                                _deleteEntry(entry);
                              } else {
                                _deleteRelEntry(entry);
                              }
                              
                             
                              Navigator.pop(context); // Modal schließen
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          }).toList(),
    );
  }
}
