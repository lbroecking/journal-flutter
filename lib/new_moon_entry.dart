import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'utils/signs.dart';

class NewMoonPage extends StatefulWidget {
  const NewMoonPage({super.key});

  @override
  _NewMoonPageState createState() => _NewMoonPageState();
}

class _NewMoonPageState extends State<NewMoonPage> {
  final supabase = Supabase.instance.client;
  final List<TextEditingController> _letGoControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _wantControllers = [
    TextEditingController(),
  ];

  String _selectedSign = 'Aries';

  void _addLetGoField() {
    setState(() {
      _letGoControllers.add(TextEditingController());
    });
  }

  void _addWantField() {
    setState(() {
      _wantControllers.add(TextEditingController());
    });
  }

  Future<void> _addEntry() async {
    final user = supabase.auth.currentUser;
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Alle Texte sammeln und leere entfernen
    final letGoList =
        _letGoControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
    final wantList =
        _wantControllers
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    // Nur speichern, wenn mindestens ein Wunsch vorhanden ist
    if (user != null && wantList.isNotEmpty) {
      await supabase.from('moon_entries').insert({
        'user_id': user.id,
        'let_go':
            letGoList, // Wenn deine Datenbank JSON unterstützt, kannst du die Listen direkt speichern
        'want': wantList,
        'moon_sign': _selectedSign,
        'created_at': formattedDate,
      });

      // Felder leeren
      for (var controller in _letGoControllers) {
        controller.clear();
      }
      for (var controller in _wantControllers) {
        controller.clear();
      }

      Navigator.pop(context);
      // _fetchEntries(); // Wenn du die Einträge nachladen willst
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Fullmoon Entry")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Moon Sign',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  DropdownButton<String>(
                    value: _selectedSign,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSign = newValue!;
                      });
                    },
                    items:
                        astroSigns.keys.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                astroSigns[value]!, // direkt als Widget einsetzen
                                SizedBox(width: 10),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "What do you want to let go?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._letGoControllers.map(
                (controller) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: "Let go of..."),
                  ),
                ),
              ),
              TextButton(
                onPressed: _addLetGoField,
                child: Text("Add another 'let go'"),
              ),

              SizedBox(height: 20),

              Text(
                "What do you want?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._wantControllers.map(
                (controller) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: "I want..."),
                  ),
                ),
              ),
              TextButton(
                onPressed: _addWantField,
                child: Text("Add another 'want'"),
              ),

              SizedBox(height: 20),

              Center(
                child: FloatingActionButton(
                  onPressed: _addEntry,
                  tooltip: "Save your fullmoon-session",
                  child: Icon(Icons.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
