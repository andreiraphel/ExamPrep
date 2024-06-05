import 'package:flutter/material.dart';
import '../database_helper.dart';

class TopicDetails extends StatelessWidget {
  final int topicId;
  final String topicName;

  const TopicDetails(
      {super.key, required this.topicId, required this.topicName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          topicName,
          style: TextStyle(color: Color(0xFFEEEEEE)),
        ),
        backgroundColor: Color(0xFF31363F),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getFlashcards(topicId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No flashcards available'));
          } else {
            final flashcards = snapshot.data!;
            return ListView.builder(
              itemCount: flashcards.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(flashcards[index]['question']),
                  subtitle: Text(flashcards[index]['answer']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
