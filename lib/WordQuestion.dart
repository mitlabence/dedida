import 'Linguistics/Word.dart';

class WordQuestion{
  final Word word;
  final List<String> answers;
  final int correctAnswerIndex;
  WordQuestion({required this.word, required this.answers, required this.correctAnswerIndex});
}