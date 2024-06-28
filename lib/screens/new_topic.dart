import 'package:flutter/material.dart';
import '../widgets/topics.dart';

class NewTopic extends StatelessWidget {
  final GlobalKey<TopicsState> topicsKey;
  const NewTopic({required this.topicsKey, super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Topic',
          style: TextStyle(
            color: Color(0xFFEEEEEE),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color(0xFF31363F),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String topic = textController.text;
              if (topic.isNotEmpty) {
                topicsKey.currentState?.addItem(topic);
                textController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add Topic'),
          ),
        ],
      ),
    );
  }
}
