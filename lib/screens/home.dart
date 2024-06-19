import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/topics.dart';
import '../widgets/add_item.dart';
import '../screens/settings_screen.dart';
import '../database_helper.dart';

enum MenuItem { Delete, Settings, Feedback, Import }

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showCancelButton = false;

  final GlobalKey<TopicsState> topicsKey = GlobalKey<TopicsState>();
  final dbHelper = DatabaseHelper();

  void handleMenuItemSelected(MenuItem item) async {
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
        _showImportExportDialog();
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

  void _showImportExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import/Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _exportData,
              child: Text('Export Data'),
            ),
            ElevatedButton(
              onPressed: _importData,
              child: Text('Import Data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/Download';
      final directoryExists = await Directory(path).exists();
      if (!directoryExists) {
        await Directory(path).create(recursive: true);
      }

      final data = await _getTopicsAndFlashcards();
      final file = File('$path/flashcards.json');
      await file.writeAsString(jsonEncode(data));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to $path/flashcards.json')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }

  Future<void> _importData() async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/Download/flashcards.json';
      final file = File(path);
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        await _saveTopicsAndFlashcards(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data imported from $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data file found to import')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import data: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> _getTopicsAndFlashcards() async {
    List<Map<String, dynamic>> topics = await dbHelper.getTopics();
    List<Map<String, dynamic>> allFlashcards = [];
    for (var topic in topics) {
      List<Map<String, dynamic>> flashcards =
          await dbHelper.getFlashcards(topic['id']);
      allFlashcards.addAll(flashcards);
    }
    return {
      'topics': topics,
      'flashcards': allFlashcards,
    };
  }

  Future<void> _saveTopicsAndFlashcards(Map<String, dynamic> data) async {
    List<dynamic> topics = data['topics'];
    List<dynamic> flashcards = data['flashcards'];

    for (var topic in topics) {
      await dbHelper.insertTopic(topic['name']);
    }

    for (var flashcard in flashcards) {
      await dbHelper.insertFlashcard(
          flashcard['topicId'], flashcard['question'], flashcard['answer']);
    }

    final topicState = topicsKey.currentState;
    if (topicState != null) {
      topicState.loadTopics();
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
