import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../screens/new_card.dart';
import '../screens/topic_details.dart';
import '../screens/flashcard_study_screen.dart';

class Topics extends StatefulWidget {
  const Topics({super.key});

  @override
  TopicsState createState() => TopicsState();
}

class TopicsState extends State<Topics> {
  List<Map<String, dynamic>> items = [];
  bool deleteBool = false;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadTopics();
  }

  void loadTopics() async {
    List<Map<String, dynamic>> topics = await dbHelper.getTopics();
    setState(() {
      items = topics;
    });
  }

  void addItem(String newItem) async {
    await dbHelper.insertTopic(newItem);
    loadTopics();
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
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await dbHelper.deleteTopic(id);
      loadTopics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(
            child: Text('Add a topic'),
          )
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: ((context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    title: Text(
                      items[index]['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TopicDetails(
                                  topicId: items[index]['id'],
                                  topicName: items[index]['name'],
                                )),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (deleteBool)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              deleteItem(items[index]['id']);
                            },
                          )
                        else ...[
                          IconButton(
                            onPressed: () {
                              // NEW FLASHCARD FUNCTION
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewCard(
                                            topicName: items[index]['name'],
                                            topicId: items[index]['id'],
                                            onFlashcardAdded: () {
                                              setState(() {});
                                            },
                                          )));
                            },
                            icon: const Icon(Icons.add),
                            color: const Color(0xFF76ABAE),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              // START FLASHCARDS FUNCTION
                              List<Map<String, dynamic>> flashcards =
                                  await dbHelper
                                      .getFlashcards(items[index]['id']);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FlashcardStudyScreen(
                                            topicId: items[index]['id'],
                                            flashcards: flashcards,
                                          )));
                            },
                            icon: const Icon(Icons.play_arrow),
                            color: const Color(0xFF76ABAE),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
  }
}
