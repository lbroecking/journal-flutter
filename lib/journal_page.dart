import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_page.dart';
import 'new_personal_entry.dart';
import 'new_relationship_entry.dart';
import 'utils/emotion_colors.dart';
import 'package:intl/intl.dart';
import 'new_moon_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  //final supabase = Supabase.instance.client;
  String _selectedEmotion = 'neutral';

  List<Map<String, dynamic>> _entries = [];

  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _logout(BuildContext context) async {
    final serverUrl = dotenv.env['SERVER_URL_LOGOUT'];
    final uri = Uri.parse(serverUrl!); // check, that serverUrl not null
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthPage(),
        ), // Zur AuthPage navigieren
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to logout.")));
    }
  }

  Future<void> _fetchEntries() async {
    final serverUrl = dotenv.env['SERVER_URL_ENTRY'];
    final uri = Uri.parse(
      '${serverUrl!}/?selected_index=$selectedIndex',
    ); // check, that serverUrl not null
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _entries = List<Map<String, dynamic>>.from(data);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load entries")));
    }
  }

  Future<void> _deleteEntry(Map<String, dynamic> entry) async {
    //TODO insert delete server request

    String table = '';
    switch (selectedIndex) {
      case 0:
        table = 'journal_entries';
        break;
      case 1:
        table = 'moon_entries';
        break;
      case 2:
        table = 'relationship_check';
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occured while deleting process.")),
        );
    }

    final serverUrl = dotenv.env['SERVER_URL_DELETE'];
    final uri = Uri.parse(serverUrl!); // check, that serverUrl not null

    var entryId = entry['id'];

    final Map<String, dynamic> body = {
      'table': table,
      'id': entryId
    };

  
    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      jsonDecode(response.body);
      _fetchEntries();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Deleted entry")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete entry")));
    }
  }

  /*
  Future<void> _updateEntry(
    //todo updatet entry

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


  Future<void> _updateMoonEntry(
    int entryId,
    String newLetGo,
    String newWantList,
    String newSign,
  ) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('moon_entries')
        .update({'let_go': newLetGo, 'want': newWantList, 'moon_sign': newSign})
        .eq('id', entryId);

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

  Future<void> _updateRelEntry(int entryId, String newAnswer) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('relationship_check')
        .update({
          'answer': newAnswer, // Neuen Antwort speichern
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
  */

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
                  labelText: "Write about your day today...",
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
                /*await _updateEntry(
                  entry['id'],
                  controller.text,
                  gratefulController.text,
                  proudController.text,
                  _selectedEmotion,
                );*/
                Navigator.pop(context); // Dialog schließen
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    // DateTime aus dem String erstellen
    DateTime date = DateTime.parse(dateStr);

    // Monat und Jahr formatieren
    String formattedDate = DateFormat(
      'MMMM yyyy',
    ).format(date); // Beispiel: "April 2025"

    return formattedDate;
  }

  String _formatDateGer(String dateStr) {
    // DateTime aus dem String erstellen
    DateTime date = DateTime.parse(dateStr);

    // Monat und Jahr formatieren
    String formattedDate = DateFormat(
      'dd.MM.yyyy',
    ).format(date); // Beispiel: "April 2025"

    return formattedDate;
  }

  void _editMoonEntry(BuildContext context, Map<String, dynamic> entry) {
    List<dynamic> jsonList =
        entry['want'].map((item) => item.toString()).toList();

    TextEditingController wantController = TextEditingController(
      text: jsonList.join('\n'),
      //entry['want'].map<Widget>((item) => Text("- ${item.toString()}")),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry['moon_sign']),
              SizedBox(height: 10),
              // Textfeld für den Inhalt des Eintrags
              TextField(
                controller: wantController,
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
                //await _updateRelEntry(entry['id'], wantController.text);
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
                //await _updateRelEntry(entry['id'], controller.text);
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
          BottomNavigationBarItem(icon: Icon(Icons.mode_night), label: 'Moon'),
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
              builder: (context) {
                switch (selectedIndex) {
                  case 0:
                    return NewEntryPage();
                  case 1:
                    return NewMoonPage();
                  case 2:
                    return NewRelationshipEntryPage();
                  default:
                    return Scaffold(
                      body: Center(
                        child: Text('Unknown Index: $selectedIndex'),
                      ),
                    );
                }
              },
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
                    ? Column(
                      children: [
                        if (entry['created_at'] != null)
                          Text(
                            _formatDateGer(entry['created_at']),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    )
                    : selectedIndex == 1
                    ? Column(
                      children: [
                        if (entry['moon_sign'] != null)
                          Row(
                            children: [
                              Text(
                                "${entry['moon_sign']} - ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                entry['created_at'] != null
                                    ? _formatDate(entry['created_at'])
                                    : "No date", // Falls kein Datum vorhanden ist
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ],
                    )
                    : selectedIndex == 2
                    ? Column(
                      children: [
                        if (entry['question'] != null)
                          Text(
                            "${entry['question']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    )
                    : Container(); // Fallback für unerwartete `selectedIndex` Werte

            // Zusätzliche Daten je nach Tab:
            final additionalContent =
                selectedIndex == 0
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry['content'] != null &&
                            entry['content'].toString().isNotEmpty)
                          Text(
                            "${entry['content']}",
                            style: TextStyle(fontSize: 18),
                          ),
                        SizedBox(height: 10),
                        if (entry['content_grateful'] != null &&
                            entry['content_grateful'].toString().isNotEmpty)
                          Text(
                            "Grateful: ${entry['content_grateful']}",
                            style: TextStyle(fontSize: 18),
                          ),
                        if (entry['content_proud'] != null &&
                            entry['content_proud'].toString().isNotEmpty)
                          Text(
                            "Proud: ${entry['content_proud']}",
                            style: TextStyle(fontSize: 18),
                          ),
                      ],
                    )
                    : selectedIndex == 1
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Let Go List als JSON-Liste anzeigen
                        if (entry['let_go'] != null &&
                            entry['let_go'] is List &&
                            entry['let_go'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Let Go List:",
                                style: TextStyle(fontSize: 19),
                              ),
                              SizedBox(height: 5),
                              ...List<Widget>.from(
                                entry['let_go'].map<Widget>(
                                  (item) => Text(
                                    "- ${item.toString()}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 10),

                        // Want List als JSON-Liste anzeigen
                        if (entry['want'] != null &&
                            entry['want'] is List &&
                            entry['want'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Want List:",
                                style: TextStyle(fontSize: 19),
                              ),
                              SizedBox(height: 5),
                              ...List<Widget>.from(
                                entry['want'].map<Widget>(
                                  (item) => Text(
                                    "- ${item.toString()}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    )
                    : selectedIndex == 2
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry['answer'] != null)
                          Text(
                            "${entry['answer']}",
                            style: TextStyle(fontSize: 18),
                          ),
                        SizedBox(height: 8),
                        if (entry['created_at'] != null)
                          Text(
                            DateFormat(
                              'dd.MM.yyyy',
                            ).format(DateTime.parse(entry['created_at'])),
                          ),
                      ],
                    )
                    : Container(); // Fallback für unerwartete `selectedIndex` Werte

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
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    additionalContent,
                    //SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //children: subtitleWidgets,
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
                              } else if (selectedIndex == 1) {
                                _editMoonEntry(context, entry);
                              } else {
                                _editRelEntry(context, entry);
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Löschen'),
                            onTap: () {
                              _deleteEntry(entry);
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
