import 'package:flutter/material.dart';
import '../database_helper.dart';

class AddTopicScreen extends StatefulWidget {
  const AddTopicScreen({super.key});

  @override
  _AddTopicScreenState createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final dbHelper = DatabaseHelper();

  void _addTopic() async {
    if (_formKey.currentState!.validate()) {
      String newTopic = _topicController.text;
      await dbHelper.insertTopic(newTopic);
      Navigator.pop(
          context, true); // Return to the previous screen with a success flag
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Topic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Topic Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a topic name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTopic,
                child: const Text('Add Topic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
