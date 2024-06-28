import 'package:flutter/material.dart';
import '../database_helper.dart';

class NewCard extends StatelessWidget {
  final String topicName;
  final int topicId;
  final Function() onFlashcardAdded;

  const NewCard({
    super.key,
    required this.topicName,
    required this.topicId,
    required this.onFlashcardAdded,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();

    final dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          topicName,
          style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20),
            child: TextField(
              controller: questionController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Question'),
              minLines: 1,
              maxLines: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20),
            child: TextField(
              controller: answerController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Answer'),
              minLines: 1,
              maxLines: null,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              String question = questionController.text;
              String answer = answerController.text;

              if (question.isNotEmpty && answer.isNotEmpty) {
                await dbHelper.insertFlashcard(topicId, question, answer);
                questionController.clear();
                answerController.clear();
                onFlashcardAdded();
                Navigator.pop(context);
              }
            },
            child: const Text('Add Flashcard'),
          ),
        ],
      ),
    );
  }
}
