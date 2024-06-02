import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'ExamPrep',
      home: Home(),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<_TopicsState> topicsKey = GlobalKey<_TopicsState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ExamPrep',
          style: TextStyle(color: Color(0xFFEEEEEE)),
        ),
        backgroundColor: Color(0xFF31363F),
        actions: [
          IconButton(
            onPressed: () {
              topicsKey.currentState?.toggleDelete();
            },
            icon: Icon(Icons.delete),
            color: Color(0xFF76ABAE),
          ),
        ],
      ),
      body: Topics(key: topicsKey),
      backgroundColor: Color(0xFFEEEEEE),
      floatingActionButton: AddItem(topicsKey: topicsKey),
    );
  }
}

class Topics extends StatefulWidget {
  const Topics({Key? key}) : super(key: key);

  @override
  State<Topics> createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  List<String> items = [];
  bool deleteBool = false;

  void addItem(String newItem) {
    setState(() {
      items.add(newItem);
    });
  }

  void toggleDelete() {
    setState(() {
      deleteBool = !deleteBool;
    });
  }

  Future<void> deleteItem(int index) async {
    bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
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
                  child: Text('Cancel')),
            ],
          );
        });
    if (confirmDelete == true) {
      setState(() {
        items.removeAt(index);
      });
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
                title: Text(items[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (deleteBool)
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          deleteItem(index);
                        },
                      )
                    else ...[
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add),
                        color: Color(0xFF76ABAE),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {},
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

class AddItem extends StatelessWidget {
  final GlobalKey<_TopicsState> topicsKey;

  const AddItem({required this.topicsKey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewTopic(topicsKey: topicsKey),
          ),
        );
      },
      tooltip: 'Add Item',
      child: Icon(Icons.add, color: Color(0xFF76ABAE)),
      backgroundColor: Color(0xFF222831),
    );
  }
}

class NewTopic extends StatelessWidget {
  final GlobalKey<_TopicsState> topicsKey;
  const NewTopic({required this.topicsKey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Topic',
          style: TextStyle(color: Color(0xFFEEEEEE)),
        ),
        backgroundColor: Color(0xFF31363F),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: TextField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Topic'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String topic = _textController.text;
              if (topic.isNotEmpty) {
                topicsKey.currentState?.addItem(topic);
                _textController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Add Topic'),
          ),
        ],
      ),
    );
  }
}
