/*
import 'package:flutter/material.dart';
import '../database_helper.dart';

class Flashcards extends StatefulWidget {
  final int topicId;

  const Flashcards({super.key, required this.topicId});

  @override
  State<Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<Flashcards> {
  List<Map<String, dynamic>> items = [];
  bool deleteBool = false;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  void _loadFlashcards() async {
    List<Map<String, dynamic>> flashcards =
        await dbHelper.getFlashcards(widget.topicId);
    setState(() {
      items = flashcards;
    });
  }

  void addItem(String newQuestion, String newAnswer) async {
    await dbHelper.insertFlashcard(widget.topicId, newQuestion, newAnswer);
    _loadFlashcards();
  }

  void toggleDelete() {
    setState(() {
      deleteBool = !deleteBool;
    });
  }

  Future<void> deleteItem(int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await dbHelper.deleteFlashcard(id);
      _loadFlashcards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = items.length;

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]['question']),
          subtitle: Text(items[index]['answer']),
        );
      },
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../database_helper.dart';

class Flashcards extends StatefulWidget {
  final int topicId;

  const Flashcards({Key? key, required this.topicId});

  @override
  State<Flashcards> createState() => _FlashcardsState();
}

class _FlashcardsState extends State<Flashcards> {
  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getFlashcards(widget.topicId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No flashcards available'));
        } else {
          final flashcards = snapshot.data!;
          final itemCount = flashcards.length;

          return ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(flashcards[index]['question']),
                subtitle: Text(flashcards[index]['answer']),
              );
            },
          );
        }
      },
    );
  }
}
