import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/notes_controller.dart';
import 'views/note_list_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: NoteListPage(),
    );
  }
}
