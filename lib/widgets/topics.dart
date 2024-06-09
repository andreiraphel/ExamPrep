import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../screens/new_card.dart';
import '../screens/topic_details.dart';

class Topics extends StatefulWidget {
  const Topics({Key? key}) : super(key: key);

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
    _loadTopics();
  }

  void _loadTopics() async {
    List<Map<String, dynamic>> topics = await dbHelper.getTopics();
    setState(() {
      items = topics;
    });
  }

  void addItem(String newItem) async {
    await dbHelper.insertTopic(newItem);
    _loadTopics();
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
      await dbHelper.deleteTopic(id);
      _loadTopics();
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
              return ListTile(
                title: Text(items[index]['name']),
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
                        icon: Icon(Icons.delete),
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
                                          setState(
                                              () {}); // Rebuild when flashcard added
                                        },
                                      )));
                        },
                        icon: Icon(Icons.add),
                        color: Color(0xFF76ABAE),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          // IMPLEMENT START FUNCTION
                        },
                        icon: Icon(Icons.play_arrow),
                        color: Color(0xFF76ABAE),
                      ),
                    ]
                  ],
                ),
              );
            }),
          );
  }
}
