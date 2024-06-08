import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../screens/new_card.dart';

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
            final itemCount = flashcards.length;

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  width: 500,
                  alignment: Alignment.center,
                  color: Color.fromARGB(255, 143, 143, 143),
                  child: Text(
                    'Flashcards: $itemCount',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // NEW FLASHCARD FUNCTION
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewCard(
                                      topicName: topicName,
                                      topicId: topicId,
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
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(flashcards[index]['question']),
                      subtitle: Text(flashcards[index]['answer']),
                    );
                  },
                )),
              ],
            );
          }
        },
      ),
    );
  }
}
