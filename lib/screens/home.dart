import 'package:flutter/material.dart';
import '../widgets/topics.dart';
import '../widgets/add_item.dart';

enum MenuItem { Delete, Feedback, Report }

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showCancelButton = false;

  final GlobalKey<TopicsState> topicsKey = GlobalKey<TopicsState>();

  void handleMenuItemSelected(MenuItem item) {
    switch (item) {
      case MenuItem.Delete:
        final topicState = topicsKey.currentState;
        if (topicState != null) {
          topicState.toggleDelete();
          setState(() {
            showCancelButton = true;
          });
        }
        break;
      case MenuItem.Feedback:
        // Handle feedback
        break;
      case MenuItem.Report:
        // Handle report
        break;
    }
  }

  void handleCancel() {
    final topicState = topicsKey.currentState;
    if (topicState != null) {
      topicState.toggleDelete();
      setState(() {
        showCancelButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ExamPrep',
          style: TextStyle(color: Color(0xFFEEEEEE)),
        ),
        backgroundColor: Color(0xFF31363F),
        actions: [
          if (showCancelButton)
            IconButton(
              onPressed: handleCancel,
              icon: Icon(Icons.cancel),
              color: Colors.red,
            )
          else
            PopupMenuButton<MenuItem>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: handleMenuItemSelected,
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
