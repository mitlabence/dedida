// This should load user settings (modified in the settings tab, stored in databases)
// and set up quiz based on the settings and user progress
//  1. interact with QuizView by setting up list of words
//  2. interact with SettingsView by overtaking changes made there
import 'dart:async';
import 'dart:collection';

import 'package:dedida/Linguistics/Word.dart';
import 'package:dedida/WordQuestion.dart';
import 'package:sqflite/sqflite.dart';
import 'DBHelper.dart';

const List<String> buttonGenders = ["m", "f", "n"];
const Map<String, String> genderArticlesMap = {
  "m": "der",
  "f": "die",
  "n": "das"
};

class SessionOrchestrator {
  static final SessionOrchestrator _instance = SessionOrchestrator._();
  SessionOrchestrator._();

  factory SessionOrchestrator() {
    return _instance;
  }
  final StreamController<WordQuestion> _wordQuestionStreamController =StreamController<WordQuestion>.broadcast();
  final Queue<Word> _wordQueue = Queue<Word>();
  Stream<WordQuestion> get wordQuestionStream => _wordQuestionStreamController.stream;

  void streamNextWordQuestion() async {
    if (_wordQueue.isEmpty){
      await enqueueNextWord();
    }
    if (_wordQueue.isEmpty){
      throw Exception("Queue is empty despite just adding to it");
    }
    Word nextWord = _wordQueue.removeFirst();
    const answers = ["m", "f", "n"]; // TODO: make this generic!
    int correctAnswerIndex = answers.indexOf(nextWord.gender);
    if (correctAnswerIndex < 0) {
      // TODO: handle this
      throw IndexError.withLength(correctAnswerIndex, answers.length);
    }
    WordQuestion wordQuestion = WordQuestion(word: nextWord, answers: answers, correctAnswerIndex: correctAnswerIndex);
    _wordQuestionStreamController.add(wordQuestion); // Emit the question to the stream
  }

  Future<void> enqueueNextWord() async {
    // Put another word in the queue
    Word nextWord = await getNextWord();
    _wordQueue.add(nextWord); // Add to the queue
  }
  // TODO: add getNextWords()
  Future<Word> getNextWord() async {
    Database db = await DatabaseHelper.getDatabase();
    List<Map<String, dynamic>> result = await db.query("A1",
        columns: ["pk", "Lemma", "Genus"],
        where: "Artikel IS NOT NULL", orderBy: "RANDOM()", limit: 1);
    return result.isNotEmpty
        ? Word(
            id: result.first['pk'] as int,
            root: result.first['Lemma'] as String,
            gender: (result.first['Genus'] as String)[0],
          )
        : throw Exception('No results found');
  }

  Future<List<Word>> fetchData() async {
    Database db = await DatabaseHelper.getDatabase();
    List<Map<String, dynamic>> result = await db.query("A1",
        columns: ["pk", "Lemma", "Genus"], where: "Artikel IS NOT NULL");
    return [
      for (final {
            'pk': pk as int,
            'Lemma': Lemma as String,
            'Genus': Genus as String
          } in result)
        // TODO: fem., mask., neut. are the possible Genus entries (possibly multiple, separated by comma). Make Word able to handle multiple genders!
        Word(id: pk, root: Lemma, gender: Genus[0]),
    ];
  }
  void dispose() {
    _wordQuestionStreamController.close();
  }
}
