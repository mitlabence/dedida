import 'package:dedida/SessionOrchestrator.dart';
import 'package:dedida/WordQuestion.dart';
import 'package:flutter/material.dart';
import '../Linguistics/Word.dart';
import '../Widgets/WordQuizWidget.dart';
//TODO: add colors to genders

class QuizView extends StatefulWidget {
  final SessionOrchestrator sessionOrchestrator;

  const QuizView({super.key, required this.sessionOrchestrator});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int score = 0;
  int total = 0;
  WordQuestion? wordQuestion;
  late Stream<WordQuestion> wordQuestionStream;

  @override
  void initState() {
    super.initState();
    wordQuestionStream = widget.sessionOrchestrator.wordQuestionStream;
    widget.sessionOrchestrator.streamNextWordQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WordQuestion>(
        stream: widget.sessionOrchestrator.wordQuestionStream,
        builder: (BuildContext context, AsyncSnapshot<WordQuestion> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            // Need to pass a (unique/new) key so WordQuizWidget is created anew
            // Otherwise lockButtons, button colors etc. are not reset.
            return WordQuizWidget(
              key: ValueKey<int>(snapshot.data!.word.id),
              wordQuestion: snapshot.data!,
              onAnswered: checkTip,
            );
          }
        });
  }


  void checkTip(Word word, bool isCorrect) async {
    total++;
    if (isCorrect) {
      score++;
    }
    // TODO: add word to encountered word, or update word
    DateTime dt = DateTime.now();
    await widget.sessionOrchestrator.encounterWord(word, isCorrect, dt);
    await Future.delayed(Duration(seconds: 2));
    widget.sessionOrchestrator.streamNextWordQuestion();
  }
}
