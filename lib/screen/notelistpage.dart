import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import '../models/notemodels.dart';
import '../sharedperfernces.dart';
import 'noteeditor.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final dbRef = FirebaseDatabase.instance.ref().child('notes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F6),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: FutureBuilder<String?>(
          future: getUsername(),
          builder: (context, snapshot) {
            return Text(
              snapshot.data != null
                  ? "Welcome, ${snapshot.data}"
                  : "My Notes",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            );
          },
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: dbRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

              final notes = data.entries.map((entry) {
                final noteData = Map<String, dynamic>.from(entry.value);
                return Note.fromSnapshot(entry.key, noteData);
              }).toList();

              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
                        .format(DateTime.fromMillisecondsSinceEpoch(note.timestamp));


                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                note.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.content,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NoteEditor(note: note),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () {
                                  FirebaseDatabase.instance
                                      .ref()
                                      .child('notes')
                                      .child(note.id)
                                      .remove();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            return const Center(child: Text('No notes yet'));
          }

      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteEditor(note: null),
          ),
        ),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
