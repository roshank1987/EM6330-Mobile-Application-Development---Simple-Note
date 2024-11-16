import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/notes_database.dart';
import 'dart:developer'; // Used for logging debug information.

class NotesController extends ChangeNotifier {
  final NotesDatabase _database = NotesDatabase.instance; // Singleton instance of the database.
  List<Note> _notes = []; // Internal list to hold the fetched notes.

  /// Getter to provide the list of notes to listeners (e.g., UI components).
  List<Note> get notes => _notes;

  /// Fetches all notes from the database and updates the `_notes` list.
  /// Notifies listeners of changes to trigger UI updates.
  Future<void> fetchNotes() async {
    log("Fetching notes..."); // Log the fetch operation.
    try {
      _notes = await _database.readAllNotes(); // Fetch notes from the database.
      log("Fetched notes: ${_notes.length}"); // Log the number of notes fetched.
      notifyListeners(); // Notify UI components to refresh.
    } catch (e) {
      log("Error fetching notes: $e"); // Log errors if the fetch operation fails.
    }
  }

  /// Adds a new note or updates an existing note in the database.
  /// - [note]: The `Note` object to be created or updated.
  Future<void> addOrUpdate(Note note) async {
    if (note.id == null) {
      log("Creating notes..."); // Log the creation operation.
      await _database.create(note); // Insert the new note into the database.
    } else {
      log("Editing notes..."); // Log the update operation.
      await _database.update(note); // Update the existing note in the database.
    }
    await fetchNotes(); // Refresh the list of notes.
    log("Note Executed..."); // Log completion of the add or update operation.
  }

  /// Deletes a note from the database by its ID.
  /// - [id]: The ID of the note to be deleted.
  Future<void> delete(int id) async {
    log("Deleting notes..."); // Log the delete operation.
    await _database.delete(id); // Remove the note from the database.
    await fetchNotes(); // Refresh the list of notes.
    log("Note Deleted..."); // Log completion of the delete operation.
  }
}
