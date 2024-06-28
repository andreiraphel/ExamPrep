import 'package:flutter/material.dart';
import '../screens/new_topic.dart';
import 'topics.dart';

class AddItem extends StatelessWidget {
  final GlobalKey<TopicsState> topicsKey;

  const AddItem({required this.topicsKey, super.key});

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
      backgroundColor: const Color(0xFF222831),
      child: const Icon(Icons.add, color: Color(0xFF76ABAE)),
    );
  }
}
