import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/notes_controller.dart';
import 'note_edit_page.dart';

/// The main page displaying a list of notes.
/// Allows users to view, edit, delete, and create new notes.
class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late Future<void> _fetchNotesFuture; // Future to handle the asynchronous fetch operation.

  @override
  void initState() {
    super.initState();
    // Fetch notes when the widget is first initialized.
    // Using listen: false as this fetch does not require immediate UI rebuild.
    _fetchNotesFuture = Provider.of<NotesController>(context, listen: false).fetchNotes();
  }

  /// Refreshes the notes by re-fetching them from the database.
  /// Updates the `_fetchNotesFuture` to ensure the `FutureBuilder` reflects the latest state.
  void refreshNotes() {
    setState(() {
      _fetchNotesFuture = Provider.of<NotesController>(context, listen: false).fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the NotesController to interact with the state and notes list.
    final controller = Provider.of<NotesController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Simple Note App',
          style: TextStyle(color: Colors.white), // Consistent white text color.
        ),
        centerTitle: true, // Center the title for a clean look.
        backgroundColor: Colors.deepPurple, // Updated header background color.
      ),
      body: FutureBuilder<void>(
        // Pass the `_fetchNotesFuture` to handle asynchronous state.
        future: _fetchNotesFuture,
        builder: (context, snapshot) {
          // While waiting for the future to complete, show a loading indicator.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If there is an error, display an error message.
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}', // Show the error message.
                style: TextStyle(color: Colors.red), // Use red text for errors.
              ),
            );
          }

          // If there are no notes, display a placeholder message and icon.
          if (controller.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes, size: 100, color: Colors.deepPurple), // Placeholder icon.
                  const SizedBox(height: 10),
                  const Text(
                    'No notes found.\nTap "+" to create a new note!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey), // Placeholder message style.
                  ),
                ],
              ),
            );
          }

          // If notes are available, display them in a ListView.
          return ListView.builder(
            itemCount: controller.notes.length, // Total number of notes to display.
            itemBuilder: (context, index) {
              final note = controller.notes[index]; // Get the note at the current index.
              return Card(
                elevation: 3, // Slight elevation for a shadow effect.
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add spacing around cards.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners for the card.
                ),
                child: ListTile(
                  title: Text(
                    note.title, // Display the note's title.
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // Highlight the title with bold text.
                    ),
                  ),
                  subtitle: Text(
                    note.content, // Display the note's content.
                    maxLines: 2, // Limit to two lines to avoid overflow.
                    overflow: TextOverflow.ellipsis, // Add "..." if the content exceeds two lines.
                  ),
                  onTap: () async {
                    // Navigate to the NoteEditPage when tapping on a note.
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteEditPage(note: note), // Pass the note to the edit page.
                      ),
                    );
                    refreshNotes(); // Refresh the notes after returning from the edit page.
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // Delete button.
                    onPressed: () async {
                      // Delete the note and refresh the notes list.
                      await controller.delete(note.id!);
                      refreshNotes();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add), // "+" icon for creating a new note.
        onPressed: () async {
          // Navigate to the NoteEditPage for creating a new note.
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NoteEditPage(), // No note passed for a new note.
            ),
          );
          refreshNotes(); // Refresh the notes after creating a new one.
        },
      ),
    );
  }
}
