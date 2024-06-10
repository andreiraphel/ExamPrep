import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../screens/new_card.dart';
import '../widgets/flashcards.dart';

enum MenuItem { Delete, Import }

class TopicDetails extends StatefulWidget {
  final int topicId;
  final String topicName;

  const TopicDetails({
    Key? key,
    required this.topicId,
    required this.topicName,
  }) : super(key: key);

  @override
  _TopicDetailsState createState() => _TopicDetailsState();
}

class _TopicDetailsState extends State<TopicDetails> {
  bool showCancelButton = false;
  final GlobalKey<FlashcardsState> flashcardsKey = GlobalKey<FlashcardsState>();

  void handleMenuItemSelected(MenuItem item) {
    switch (item) {
      case MenuItem.Delete:
        final topicState = flashcardsKey.currentState;
        if (topicState != null) {
          topicState.toggleDelete();
          setState(() {
            showCancelButton = true;
          });
        }
        break;
      case MenuItem.Import:
        // Handle import/export
        break;
    }
  }

  void handleCancel() {
    final topicState = flashcardsKey.currentState;
    if (topicState != null) {
      topicState.toggleDelete();
      setState(() {
        showCancelButton = false;
      });
    }
  }

  void _refreshFlashcards() {
    final topicState = flashcardsKey.currentState;
    if (topicState != null) {
      topicState.loadFlashcards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topicName,
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
                Icons.menu_rounded,
                color: Colors.white,
              ),
              onSelected: handleMenuItemSelected,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                const PopupMenuItem<MenuItem>(
                  value: MenuItem.Delete,
                  child: Text("Delete Topic"),
                ),
                const PopupMenuItem<MenuItem>(
                  value: MenuItem.Import,
                  child: Text('Import/Export'),
                ),
              ],
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getFlashcards(widget.topicId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewCard(
                            topicName: widget.topicName,
                            topicId: widget.topicId,
                            onFlashcardAdded: _refreshFlashcards,
                          ),
                        ),
                      );
                      _refreshFlashcards();
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
                child: Flashcards(
                  key: flashcardsKey,
                  topicId: widget.topicId,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
