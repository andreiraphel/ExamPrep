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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamPrep'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Topics(),
      floatingActionButton: AddItem(),
    );
  }
}

class Topics extends StatefulWidget {
  const Topics({super.key});

  @override
  State<Topics> createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  List<String> items = [];

  @override
  Widget build(BuildContext context) {
    return items.isEmpty
        ? const Center(
            child: Text('Please add a topic'),
          )
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: ((context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            }));
  }
}

class AddItem extends StatelessWidget {
  const AddItem({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      tooltip: 'Add Item',
      child: Icon(Icons.add),
    );
  }
}
