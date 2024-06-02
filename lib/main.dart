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
        title: const Text('ExamPrep'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
              onPressed: () {
                topicsKey.currentState?.toggleDelete();
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: Topics(key: topicsKey),
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

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void toggleDelete() {
    setState(() {
      deleteBool = !deleteBool;
    });
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
                      Icon(Icons.add),
                      const SizedBox(width: 10),
                      Icon(Icons.play_arrow),
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
      child: Icon(Icons.add),
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
        title: const Text('New topic'),
        backgroundColor: Colors.blueGrey,
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
