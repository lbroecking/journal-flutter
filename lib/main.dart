import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bopabjxclatablmbnwia.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvcGFianhjbGF0YWJsbWJud2lhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMxNjk1ODksImV4cCI6MjA1ODc0NTU4OX0.Idkx_4ehN72Y34NtMv0BUR9ZP3vYOekLd46LgRWGwoA',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journal Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}