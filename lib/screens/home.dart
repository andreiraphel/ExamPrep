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
  const Home({super.key});

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
            builder: (context) => const SettingsScreen(),
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
        title: const Text('Import/Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _showExportDialog,
              child: const Text('Export Data'),
            ),
            ElevatedButton(
              onPressed: _importData,
              child: const Text('Import Data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportDialog() async {
    final topics = await dbHelper.getTopics();
    showDialog(
      context: context,
      builder: (context) {
        int? selectedTopicId;
        return AlertDialog(
          title: const Text('Select Topic to Export'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<int>(
                value: selectedTopicId,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedTopicId = newValue;
                  });
                },
                items: topics.map<DropdownMenuItem<int>>((topic) {
                  return DropdownMenuItem<int>(
                    value: topic['id'],
                    child: Text(topic['name']),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedTopicId != null) {
                  _exportTopicData(selectedTopicId!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Export'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportTopicData(int topicId) async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/Download';
      final directoryExists = await Directory(path).exists();
      if (!directoryExists) {
        await Directory(path).create(recursive: true);
      }

      final topic = await dbHelper.getTopicById(topicId);
      final flashcards = await dbHelper.getFlashcards(topicId);
      final data = {
        'topics': [topic],
        'flashcards': flashcards,
      };
      final fileName = '${topicId}_${topic['name']}.json';
      final file = File('$path/$fileName');
      await file.writeAsString(jsonEncode(data));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to $path/$fileName')),
      );

      // Verify the contents of the exported file
      await _readExportedFile(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }

  Future<void> _readExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        print('Exported File Contents: $contents');
      } else {
        print('File does not exist');
      }
    } catch (e) {
      print('Failed to read file: $e');
    }
  }

  Future<void> _importData() async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/Download';
      final directoryExists = await Directory(path).exists();
      if (!directoryExists) {
        await Directory(path).create(recursive: true);
      }

      final files = Directory(path)
          .listSync()
          .where((file) => file.path.endsWith('.json'))
          .toList();
      showDialog(
        context: context,
        builder: (context) {
          String? selectedFile;
          return AlertDialog(
            title: const Text('Select File to Import'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return DropdownButton<String>(
                  value: selectedFile,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFile = newValue;
                    });
                  },
                  items: files.map<DropdownMenuItem<String>>((file) {
                    return DropdownMenuItem<String>(
                      value: file.path,
                      child: Text(file.path.split('/').last),
                    );
                  }).toList(),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedFile != null) {
                    await _importTopicData(selectedFile!);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Import'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import data: $e')),
      );
    }
  }

  Future<void> _importTopicData(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());

        List<dynamic> topics = data['topics'] ?? [];
        List<dynamic> flashcards = data['flashcards'] ?? [];

        Map<int, int> topicIdMap = {}; // Original ID -> New ID map

        for (var topic in topics) {
          String name = topic['name'] ?? 'Untitled';
          int originalTopicId = topic['id'] ?? -1;

          await dbHelper.insertTopic(name);
          final newTopic = (await dbHelper.getTopicByName(name)).first;
          int newTopicId = newTopic['id'];

          topicIdMap[originalTopicId] = newTopicId;
          print('Imported Topic: $name with new ID: $newTopicId');
        }

        for (var flashcard in flashcards) {
          int originalTopicId = flashcard['topic_id'] ?? -1;
          int newTopicId = topicIdMap[originalTopicId] ?? -1;
          String question = flashcard['question'] ?? 'No question';
          String answer = flashcard['answer'] ?? 'No answer';
          int repetition = flashcard['repetition'] ?? 0;
          int interval = flashcard['interval'] ?? 1;
          double easeFactor = flashcard['easeFactor'] ?? 2.5;
          int nextReviewDate = flashcard['nextReviewDate'] ?? 0;

          if (newTopicId != -1) {
            await dbHelper.insertFlashcard(
              newTopicId,
              question,
              answer,
              repetition: repetition,
              interval: interval,
              easeFactor: easeFactor,
              nextReviewDate: nextReviewDate,
            );
            print(
                'Imported Flashcard: $question - $answer for Topic ID: $newTopicId');
          } else {
            print(
                'Failed to import Flashcard: $question - $answer due to missing Topic ID');
          }
        }

        final topicState = topicsKey.currentState;
        if (topicState != null) {
          topicState.loadTopics();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data imported from $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data file found to import')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import data: $e')),
      );
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
        backgroundColor: const Color(0xFF31363F),
        actions: [
          if (showCancelButton)
            IconButton(
              onPressed: handleCancel,
              icon: const Icon(Icons.cancel),
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
      backgroundColor: const Color(0xFFEEEEEE),
      floatingActionButton: AddItem(topicsKey: topicsKey),
    );
  }
}
