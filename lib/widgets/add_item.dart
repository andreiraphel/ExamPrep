import 'package:flutter/material.dart';
import '../screens/new_topic.dart';
import 'topics.dart';

class AddItem extends StatelessWidget {
  final GlobalKey<TopicsState> topicsKey;

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
      child: Icon(Icons.add, color: Color(0xFF76ABAE)),
      backgroundColor: Color(0xFF222831),
    );
  }
}
