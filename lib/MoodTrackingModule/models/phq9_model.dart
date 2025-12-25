class PHQ9Question {
  final String questionText;
  int? score; // Nullable to indicate no selection

  PHQ9Question({required this.questionText, this.score}); // score is optional and nullable
}

class PHQ9Result {
  final DateTime date;
  final int score;

  PHQ9Result({required this.date, required this.score});
}

