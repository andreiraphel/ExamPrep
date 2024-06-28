import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../database_helper.dart';
import '../screens/new_card.dart';
import '../widgets/flashcards.dart';
import '../screens/flashcard_study_screen.dart';

enum MenuItem { Delete, Import }

class TopicDetails extends StatefulWidget {
  final int topicId;
  final String topicName;

  const TopicDetails({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  _TopicDetailsState createState() => _TopicDetailsState();
}

class _TopicDetailsState extends State<TopicDetails> {
  bool showCancelButton = false;
  final GlobalKey<FlashcardsState> flashcardsKey = GlobalKey<FlashcardsState>();

  void handleMenuItemSelected(MenuItem item) {
    switch (item) {
      case MenuItem.Delete:
        final flashcardState = flashcardsKey.currentState;
        if (flashcardState != null) {
          flashcardState.toggleDelete();
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
    final flashcardState = flashcardsKey.currentState;
    if (flashcardState != null) {
      flashcardState.toggleDelete();
      setState(() {
        showCancelButton = false;
      });
    }
  }

  Future<void> _refreshFlashcards() async {
    final flashcardState = flashcardsKey.currentState;
    if (flashcardState != null) {
      flashcardState.loadFlashcards();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topicName,
          style: const TextStyle(
            color: Color(0xFFEEEEEE),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
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
            return const Center(child: CircularProgressIndicator());
          }

          final flashcards = snapshot.data!;
          final itemCount = flashcards.length;

          // Calculate progress
          final reviewedCount =
              flashcards.where((fc) => fc['repetition'] > 0).length;
          final progress = itemCount > 0 ? reviewedCount / itemCount : 0.0;

          // Calculate next review date
          final currentDate = DateTime.now().millisecondsSinceEpoch;
          final nextReviewDates = flashcards
              .map((fc) => fc['nextReviewDate'] as int)
              .where((date) => date > currentDate)
              .toList();
          final nextReviewDate = nextReviewDates.isNotEmpty
              ? DateTime.fromMillisecondsSinceEpoch(
                  nextReviewDates.reduce((a, b) => a < b ? a : b))
              : null;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                width: double.infinity,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Flashcards: $itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearPercentIndicator(
                          width: 100.0,
                          lineHeight: 14.0,
                          percent: progress,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Next Review: ${nextReviewDate != null ? "${nextReviewDate.day}/${nextReviewDate.month}/${nextReviewDate.year}" : "None"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
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
                      icon: const Icon(Icons.add),
                      label: const Text('Add Flashcard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashcardStudyScreen(
                              topicId: widget.topicId,
                              flashcards: flashcards,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
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
