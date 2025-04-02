import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Linguistics/Word.dart';
import '../WordQuestion.dart';

class WordQuizWidget extends StatefulWidget {
  final WordQuestion wordQuestion;
  final void Function(Word word, bool isCorrectAnswer)
      onAnswered; // Trigger the moving on to next question, updating score etc.
  final int? score;
  final int? total;

  const WordQuizWidget(
      {super.key,
      required this.wordQuestion,
      required this.onAnswered,
      this.score,
      this.total});

  @override
  State<WordQuizWidget> createState() => _WordQuizWidgetState();
}

class _WordQuizWidgetState extends State<WordQuizWidget> {
  // TODO: buttonColors and number of answer buttons should be created from WordQuestion!
  late List<Color> _buttonColors;
  String _scoreText = "";
  bool buttonsLocked = false;
  int? _tappedAnswerIndex;

  void handleAnswerTap(int index) {
    // Do nothing if buttons locked
    if (buttonsLocked) {
      return;
    }
    Word word = widget.wordQuestion.word;
    // lock buttons, call onAnswered()
    _tappedAnswerIndex = index;
    bool isCorrect =
        _tappedAnswerIndex == widget.wordQuestion.correctAnswerIndex;
    widget.onAnswered(word, isCorrect);
    // Lock buttons, change tapped button color to green/red depending on whether correct answer
    setState(() {
      //buttonsLocked = true;
      _buttonColors[_tappedAnswerIndex!] =
          isCorrect ? Colors.green : Colors.red;
    });
  }

  @override
  void initState() {
    super.initState();
    _buttonColors =
        List.filled(widget.wordQuestion.answers.length, Colors.white);
    if (widget.score != null && widget.score != null) {
      _scoreText = "Score: ${widget.score} / ${widget.total}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(_scoreText),
        Text(widget.wordQuestion.word.root, style: TextStyle(fontSize: 30)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "der" button
            ElevatedButton(
              onPressed: () => buttonsLocked ? null : handleAnswerTap(0),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    _buttonColors[0]), // Set the background color
              ),
              child: Text("der"),
            ),

            ElevatedButton(
              onPressed: () => buttonsLocked ? null : handleAnswerTap(1),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    _buttonColors[1]), // Set the background color
              ),
              child: Text("die"),
            ),
            ElevatedButton(
              onPressed: () => buttonsLocked ? null : handleAnswerTap(2),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    _buttonColors[2]), // Set the background color
              ),
              child: Text("das"),
            ),
          ],
        )
      ],
    );
  }
}
