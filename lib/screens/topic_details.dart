import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../screens/new_card.dart';
import '../widgets/flashcards.dart';
import 'package:percent_indicator/percent_indicator.dart';

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

  Future<void> _refreshFlashcards() async {
    final topicState = flashcardsKey.currentState;
    if (topicState != null) {
      topicState.loadFlashcards();
    }
    setState(() {}); // Refresh the state to update the FutureBuilder
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
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF76ABAE), Color(0xFF31363F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                width: double.infinity,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Flashcards: $itemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
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
                      _refreshFlashcards(); // Refresh after returning
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
