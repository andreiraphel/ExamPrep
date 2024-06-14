import 'dart:math';

class SM2 {
  static void updateFlashcard(Map<String, dynamic> flashcard, int quality) {
    int repetition = flashcard['repetition'];
    int interval = flashcard['interval'];
    double easeFactor = flashcard['easeFactor'];

    if (quality < 3) {
      repetition = 0;
      interval = 1;
    } else {
      if (repetition == 0) {
        interval = 1;
      } else if (repetition == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetition += 1;
      easeFactor += 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
      if (easeFactor < 1.3) {
        easeFactor = 1.3;
      }
    }

    int nextReviewDate =
        DateTime.now().millisecondsSinceEpoch + interval * 24 * 60 * 60 * 1000;

    flashcard['repetition'] = repetition;
    flashcard['interval'] = interval;
    flashcard['easeFactor'] = easeFactor;
    flashcard['nextReviewDate'] = nextReviewDate;
  }
}
