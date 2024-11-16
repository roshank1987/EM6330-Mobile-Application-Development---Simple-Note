import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../controllers/notes_controller.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note; // The note to be edited, or null if creating a new note.

  NoteEditPage({this.note});

  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _formKey = GlobalKey<FormState>(); // Key to manage the form state.
  late TextEditingController _titleController; // Controller for the title input field.
  late TextEditingController _contentController; // Controller for the content input field.

  bool _isEdited = false; // Tracks if changes have been made to the note.

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with existing note data or default to empty strings.
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');

    // Add listeners to track if the user has made any edits.
    _titleController.addListener(() => _setEdited());
    _contentController.addListener(() => _setEdited());
  }

  void _setEdited() {
    // Set the _isEdited flag to true whenever a change is detected in the input fields.
    setState(() {
      _isEdited = true;
    });
  }

  @override
  void dispose() {
    // Clean up the text controllers when the widget is disposed.
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // If no edits were made, allow the user to leave without any confirmation.
    if (!_isEdited) return true;

    // Show a confirmation dialog if edits were made but not saved.
    final shouldDiscard = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            child: const Text('Cancel'), // Option to cancel and stay on the page.
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('Discard'), // Option to discard changes and leave the page.
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false; // Return true if the user chooses to discard changes.
  }

  void _saveNote() {
    // Validate the form inputs before saving.
    if (_formKey.currentState!.validate()) {
      // Create or update the note object with the entered title and content.
      final note = Note(
        id: widget.note?.id, // Use existing ID if editing, null if creating a new note.
        title: _titleController.text,
        content: _contentController.text,
      );

      // Access the NotesController to save or update the note.
      final controller = Provider.of<NotesController>(context, listen: false);
      controller.addOrUpdate(note); // Add new note or update existing one.

      // Show a SnackBar to indicate that the note has been saved.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note saved successfully!')),
      );

      // Navigate back to the previous page.
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Intercept the back button to check for unsaved changes.
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null ? 'Add Note' : 'Edit Note', // Dynamic title based on action.
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple, // Consistent app bar styling.
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Associate the form key with this form widget.
            child: Column(
              children: [
                // Input field for the title.
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter your note title here',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Ensure the title is not empty.
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Input field for the content.
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your note content here',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // Multiline input for the note content.
                  validator: (value) {
                    // Ensure the content is not empty.
                    if (value == null || value.isEmpty) {
                      return 'Content is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Save button.
                ElevatedButton(
                  onPressed: _saveNote, // Trigger the save operation.
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full-width button.
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
