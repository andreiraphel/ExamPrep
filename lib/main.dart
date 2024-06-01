import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'ExamPrep',
      home: const Home(),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<_TopicsState> topicsKey = GlobalKey<_TopicsState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamPrep'),
        backgroundColor: Colors.blueGrey,
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

  void addItem(String newItem) {
    setState(() {
      items.add(newItem);
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
            padding: const EdgeInsets.all(8.0),
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
