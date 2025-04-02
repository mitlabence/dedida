// This should load user settings (modified in the settings tab, stored in databases)
// and set up quiz based on the settings and user progress
//  1. interact with QuizView by setting up list of words
//  2. interact with QuizView by taking answers and forwards it to update user
//      statistics database
//  3. interact with SettingsView by overtaking changes made there

import 'dart:async';
import 'dart:collection';

import 'package:dedida/Linguistics/Word.dart';
import 'package:dedida/WordQuestion.dart';
import 'package:dedida/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'DBHelper.dart';
import 'Linguistics/EncounteredWord.dart';

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

  final StreamController<WordQuestion> _wordQuestionStreamController =
      StreamController<WordQuestion>.broadcast();
  final Queue<Word> _wordQueue = Queue<Word>();

  Stream<WordQuestion> get wordQuestionStream =>
      _wordQuestionStreamController.stream;

  void streamNextWordQuestion() async {
    if (_wordQueue.isEmpty) {
      await enqueueNextWord();
    }
    if (_wordQueue.isEmpty) {
      throw Exception("Queue is empty despite just adding to it");
    }
    Word nextWord = _wordQueue.removeFirst();
    const answers = ["m", "f", "n"]; // TODO: make this generic!
    int correctAnswerIndex = answers.indexOf(nextWord.gender);
    if (correctAnswerIndex < 0) {
      // TODO: handle this
      throw IndexError.withLength(correctAnswerIndex, answers.length);
    }
    WordQuestion wordQuestion = WordQuestion(
        word: nextWord,
        answers: answers,
        correctAnswerIndex: correctAnswerIndex);
    _wordQuestionStreamController
        .add(wordQuestion); // Emit the question to the stream
  }

  Future<void> enqueueNextWord() async {
    // Put another word in the queue
    Word nextWord = await getNextWord();
    _wordQueue.add(nextWord); // Add to the queue
  }

  // TODO: add getNextWords(int nWords)
  Future<Word> getNextWord() async {
    Database db = await DatabaseHelper.getDatabase();
    List<Map<String, dynamic>> result = await db.query("vocabulary",
        columns: ["pk", "level", "Lemma", "Genus"],
        where: "Artikel IS NOT NULL",
        orderBy: "RANDOM()",
        limit: 1);
    return result.isNotEmpty
        ? Word(
            id: result.first['pk'] as int,
            level: result.first['level'] as String,
            root: result.first['Lemma'] as String,
            gender: (result.first['Genus']
                as String)[0], // only need first letter: m, f, n
          )
        : throw Exception('No results found');
  }

  Future<List<Word>> fetchData() async {
    Database db = await DatabaseHelper.getDatabase();
    List<Map<String, dynamic>> result = await db.query("vocabulary",
        columns: ["pk", "level", "Lemma", "Genus"],
        where: "Artikel IS NOT NULL");
    return [
      for (final {
            'pk': pk as int,
            'level': level as String,
            'Lemma': lemma as String,
            'Genus': genus as String
          } in result)
        // TODO: fem., mask., neut. are the possible Genus entries (possibly multiple, separated by comma). Make Word able to handle multiple genders!
        Word(id: pk, level: level, root: lemma, gender: genus[0]),
    ];
  }

  Future<List<EncounteredWord>> getEncounteredWords() async {
    const String query = '''
    SELECT ew.pk, ew.word_id, ew.date_encountered, 
           ew.times_reviewed, ew.times_correct, ew.is_mastered, 
           ew.last_reviewed, ew.review_history, ew.custom_notes, v.Lemma, v.Genus, v.level
    FROM encountered_words AS ew
    INNER JOIN vocabulary AS v ON ew.word_id = v.pk;
  ''';
    print("Querying...");
    Database db = await DatabaseHelper.getDatabase();
    List<Map<String, dynamic>> result = await db.rawQuery(query);
    print("Query successful: len = ${result.length}");
    return [
      for (final {
            'word_id': wordId as int,
            'level': level as String,
            'Lemma': lemma as String,
            'Genus': genus as String,
            'date_encountered': dateEncountered as String,
            'times_reviewed': timesReviewed as int,
            'times_correct': timesCorrect as int,
            'review_history': reviewHistory as int,
            'is_mastered': isMastered as int,
            'last_reviewed': lastReviewed as String,
            'custom_notes': customNotes as String,

            // TODO: add custom_notes if present (can be null)
          } in result)
        // TODO: fem., mask., neut. are the possible Genus entries (possibly multiple, separated by comma). Make Word able to handle multiple genders!
        EncounteredWord(
          id: wordId,
          level: level,
          root: lemma,
          gender: genus[0],
          dateEncountered: dateEncountered,
          timesReviewed: timesReviewed,
          timesCorrect: timesCorrect,
          reviewHistory: reviewHistory,
          lastReviewed: lastReviewed,
          isMastered: isMastered,
          customNotes: customNotes
        ),
    ];
  }

  Future<void> encounterWord(
      Word word, bool isCorrect, DateTime lastEncounter) async {
    /// Update word in encountered_words table if there, or create new entry if
    /// not present in table.
    /// isCorrect: if true, latest encounter was "positive".
    Database db = await DatabaseHelper.getDatabase();
    // 1. check if word already encountered
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM encountered_words WHERE word_id = ?', [word.id]);
    if (result.isNotEmpty) {
      // Word already encountered
      if (result.length != 1) {
        throw Exception("Encountered word not unique! Performed SELECT "
            "FROM encountered_words WHERE word_id = ${word.id}");
      }
      int timesReviewed = result.first["times_reviewed"] as int;
      int isMastered = result.first["is_mastered"] as int;
      int reviewHistory = result.first["review_history"] as int;
      int timesCorrect = result.first["times_correct"] as int;
      // update encountered_words entry:
      //  1. increment times reviewed, times correct
      //  2. update is_mastered
      //  3. update last_reviewed to lastEncounter
      //  4. update review_history: shift to left by one, add isCorrect (0 or 1) as last bit
      timesReviewed++;
      if (isCorrect) {
        timesCorrect++;
      }
      // TODO: implement logic of isMastered here!
      isMastered = isMastered > 0 && isCorrect ? 1 : 0;
      String lastReviewed = dateTimeAsString(lastEncounter);
      // FIXME: dart passes by reference right? so reviewHistory = shiftAndAddBit() would be wrong? Or maybe newReviewHistory is not needed at all?
      int newReviewHistory =
          shiftAndAddBit(reviewHistory, isCorrect, mask: 0xFFFFFFFF);
      await db.update(
          'encountered_words',
          {
            'times_reviewed': timesReviewed,
            'times_correct': timesCorrect,
            'is_mastered': isMastered,
            'last_reviewed': lastReviewed,
            'review_history': newReviewHistory,
          },
          where: 'word_id = ?',
          whereArgs: [word.id]);
    } else {
      // word not yet encountered
      String dt = dateTimeAsString(lastEncounter);
      await db.insert("encountered_words", {
        "word_id": word.id,
        "date_encountered": dt,
        "times_reviewed": 1,
        "times_correct": isCorrect ? 1 : 0,
        "is_mastered": 0,
        "last_reviewed": dt,
        "custom_notes": "", // TODO: add custom notes?
        "review_history": isCorrect ? 1 : 0
      });
    }
  }

  void dispose() {
    _wordQuestionStreamController.close();
  }
}
