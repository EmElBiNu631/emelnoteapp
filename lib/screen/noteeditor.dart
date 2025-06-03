import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziyaproject2/models/notemodels.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;
  const NoteEditor({super.key, required this.note});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.ref().child('notes');

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  void saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (widget.note == null) {
      final newRef = dbRef.push();
      newRef.set({
        'title': title,
        'content': content,
        'timestamp': currentTimestamp,
      }).then((_) {
        print("Note saved successfully");
      }).catchError((error) {
        print("Failed to save note: $error");
      });
    } else {
      dbRef.child(widget.note!.id).update({
        'title': title,
        'content': content,
        'timestamp': currentTimestamp,
      }).then((_) {
        print("Note updated successfully");
      }).catchError((error) {
        print("Failed to update note: $error");
      });
    }

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.poppins(fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: contentController,
                      style: GoogleFonts.poppins(fontSize: 16),
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveNote,
                        icon: const Icon(Icons.save_alt_rounded),
                        label: Text(
                          'Save Note',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
