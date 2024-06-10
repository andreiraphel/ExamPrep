import 'package:flutter/material.dart';
import '../database_helper.dart';

class Flashcards extends StatefulWidget {
  final int topicId;

  const Flashcards({Key? key, required this.topicId}) : super(key: key);

  @override
  FlashcardsState createState() => FlashcardsState();
}

class FlashcardsState extends State<Flashcards> {
  List<Map<String, dynamic>> items = [];
  bool deleteBool = false;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  void loadFlashcards() async {
    List<Map<String, dynamic>> flashcards =
        await dbHelper.getFlashcards(widget.topicId);
    setState(() {
      items = flashcards;
    });
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
      loadFlashcards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(
            child: Text("Add flashcards"),
          )
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]['question']),
                subtitle: Text(items[index]['answer']),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (deleteBool)
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        deleteItem(items[index]['id']);
                      },
                    )
                ]),
              );
            },
          );
  }
}
