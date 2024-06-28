import 'package:flutter/material.dart';
import '../database_helper.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final int topicId;
  final List<Map<String, dynamic>> flashcards;

  const FlashcardStudyScreen({
    super.key,
    required this.topicId,
    required this.flashcards,
  });

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int currentIndex = 0;
  bool showAnswer = false;
  final TextEditingController _answerController = TextEditingController();
  bool _isCorrect = false;
  final DatabaseHelper dbHelper = DatabaseHelper();

  void nextFlashcard() {
    setState(() {
      if (currentIndex < widget.flashcards.length - 1) {
        currentIndex++;
        showAnswer = false;
        _answerController.clear();
        _isCorrect = false;
      } else {
        Navigator.pop(context);
      }
    });
  }

  void toggleAnswer() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  Future<void> checkAnswer() async {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isCorrect = _answerController.text.trim().toLowerCase() ==
          widget.flashcards[currentIndex]['answer'].trim().toLowerCase();
      showAnswer = true;
    });

    // SM-2 algorithm
    int quality = _isCorrect ? 5 : 0;
    await dbHelper.applySM2(widget.flashcards[currentIndex]['id'], quality);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Study Flashcards',
            style: TextStyle(
              color: Color(0xFFEEEEEE),
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
          backgroundColor: const Color(0xFF31363F),
        ),
        body: const Center(
          child: Text(
            'No flashcards available for this topic.',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final flashcard = widget.flashcards[currentIndex];
    print(flashcard);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Flashcards',
          style: TextStyle(
            color: Color(0xFFEEEEEE),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color(0xFF31363F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: toggleAnswer,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24.0),
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 172, 172, 172),
                        Color(0xFF31363F)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Stack(
                    children: [
                      showAnswer
                          ? const Positioned(
                              top: 8.0,
                              left: 8.0,
                              child: Text(
                                'Answer:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Positioned(
                              top: 8.0,
                              left: 8.0,
                              child: Text(
                                'Question:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      Center(
                        child: SingleChildScrollView(
                          child: Text(
                            showAnswer
                                ? flashcard['answer']
                                : flashcard['question'],
                            style: const TextStyle(
                              fontSize: 28.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Enter your answer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: checkAnswer,
              icon: const Icon(Icons.check),
              label: const Text('Check Answer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (showAnswer)
              Text(
                _isCorrect ? 'Correct!' : 'Incorrect. Try again!',
                style: TextStyle(
                  fontSize: 18.0,
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),
            if (_isCorrect || showAnswer)
              ElevatedButton.icon(
                onPressed: nextFlashcard,
                icon: const Icon(Icons.arrow_forward),
                label: Text(currentIndex < widget.flashcards.length - 1
                    ? 'Next'
                    : 'Finish'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
