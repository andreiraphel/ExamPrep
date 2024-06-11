import 'package:flutter/material.dart';
import '../widgets/topics.dart';
import '../widgets/add_item.dart';
import '../screens/settings_screen.dart';

enum MenuItem { Delete, Settings, Feedback, Import }

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
      case MenuItem.Settings:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(),
          ),
        );
        break;
      case MenuItem.Feedback:
        // Handle feedback
        break;
      case MenuItem.Import:
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
          style: TextStyle(
            color: Color(0xFFEEEEEE),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            fontFamily: 'Roboto',
          ),
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
                  value: MenuItem.Settings,
                  child: Text('Settings'),
                ),
                const PopupMenuItem<MenuItem>(
                  value: MenuItem.Feedback,
                  child: Text('Feedback/Report'),
                ),
                const PopupMenuItem<MenuItem>(
                  value: MenuItem.Import,
                  child: Text('Import/Export'),
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
