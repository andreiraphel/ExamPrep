import 'package:flutter/material.dart';
import '../widgets/topics.dart';

class NewTopic extends StatelessWidget {
  final GlobalKey<TopicsState> topicsKey;
  const NewTopic({required this.topicsKey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _textController = TextEditingController();

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
