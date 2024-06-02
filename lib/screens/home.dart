import 'package:flutter/material.dart';
import '../widgets/topics.dart';
import '../widgets/add_item.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
