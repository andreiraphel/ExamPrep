import 'package:flutter/material.dart';
import '../widgets/topics.dart';
import '../widgets/add_item.dart';

enum MenuItem { Delete, Feedback, Report }

class Home extends StatelessWidget {
  const Home({Key? key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TopicsState> topicsKey = GlobalKey<TopicsState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ExamPrep',
          style: TextStyle(color: Color(0xFFEEEEEE)),
        ),
        backgroundColor: Color(0xFF31363F),
        actions: [
          PopupMenuButton<MenuItem>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (MenuItem item) {
              // Handle menu item selection here
              switch (item) {
                case MenuItem.Delete:
                  final topicState = topicsKey.currentState;
                  if (topicState != null) {
                    topicState.toggleDelete();
                  }
                  break;
                case MenuItem.Feedback:
                  // Handle feedback
                  break;
                case MenuItem.Report:
                  // Handle report
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
              const PopupMenuItem<MenuItem>(
                value: MenuItem.Delete,
                child: Text("Delete Topic"),
              ),
              const PopupMenuItem<MenuItem>(
                value: MenuItem.Feedback,
                child: Text('Feedback'),
              ),
              const PopupMenuItem<MenuItem>(
                value: MenuItem.Report,
                child: Text('Report'),
              ),
            ],
          ),
        ],
      ),
      body: Topics(key: topicsKey),
      backgroundColor: Color(0xFFEEEEEE),
      floatingActionButton: AddItem(topicsKey: topicsKey),
    );
  }
}
