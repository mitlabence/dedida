import 'dart:async';
import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'word.dart';

const List<String> buttonGenders = ["m", "f", "n"];
const Map<String, String> genderArticlesMap = {
  "m": "der",
  "f": "die",
  "n": "das"
};

Future<List<Word>> fetchData() async {
  Database db = await DatabaseHelper.getDatabase();
  List<Map<String, dynamic>> result = await db.query("A1", columns: ["pk", "Lemma", "Genus"], where: "Artikel IS NOT NULL");
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String dbpath = await getDatabasesPath();
  List<Word> words = await fetchData();
  runApp(MyApp(words: words));
}

class MyApp extends StatelessWidget {
  final List<Word> words;

  const MyApp({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "dedida",
        theme: ThemeData(primarySwatch: Colors.amber),
        initialRoute: '/home',
        routes: {
          '/home': (context) => MainScreen(words: words),
        });
  }
}

class MainScreen extends StatefulWidget {
  final List<Word> words;

  MainScreen({super.key, required this.words});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<int> iWordsList = [];
  int iQuestion = 0; // This marks the question index, not the word index. Use iWordsList[iQuestion] to get the corresponding word
  int score = 0;
  int total = 0;
  bool buttonsLocked = false;
  List<Color> buttonColors = [Colors.white, Colors.white, Colors.white];
  late int nWords;

  @override
  void initState() {
    super.initState();
    nWords = widget.words.length;
    iWordsList = List.generate(nWords, (index) => index);
    iWordsList.shuffle(); // Want a random order
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Score: $score / $total"),
        Text(widget.words[iWordsList[iQuestion]].root, style: TextStyle(fontSize: 30)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "der" button
            ElevatedButton(
              onPressed: () =>
                  buttonsLocked ? null : checkTip(0, widget.words[iWordsList[iQuestion]]),
              child: Text("der"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    buttonColors[0]), // Set the background color
              ),
            ),

            ElevatedButton(
              onPressed: () =>
                  buttonsLocked ? null : checkTip(1, widget.words[iWordsList[iQuestion]]),
              child: Text("die"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    buttonColors[1]), // Set the background color
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  buttonsLocked ? null : checkTip(2, widget.words[iWordsList[iQuestion]]),
              child: Text("das"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    buttonColors[2]), // Set the background color
              ),
            ),
          ],
        )
      ],
    )));
  }

  void checkTip(
    int iAnswer,
    Word word,
  ) async {
    // Check if answer is correct. If yes, increment scoreCounter. If reach length of dictionary, restart.
    // If incorrect, only increment word counter (cyclically as well)
    final String genderTip = buttonGenders[iAnswer];
    if (genderTip == word.gender) {
      // right answer
      // Increase score, set colors, freeze buttons
      setState(() {
        score++;
        buttonColors[iAnswer] = Colors.green;
        buttonsLocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Correct!"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // wrong answer
      // Set colors, freeze buttons
      setState(() {
        buttonColors[iAnswer] = Colors.red;
        buttonsLocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Right answer: ${genderArticlesMap[word.gender]}"),
          duration: Duration(seconds: 2),
        ),
      );
    }
    setState(() {
      // Increase total number of guesses
      total++;
    });
    // wait
    await Future.delayed(Duration(seconds: 2));
    // Unlock buttons, set colors, next word
    setState(() {
      iQuestion = iQuestion == widget.words.length - 1 ? 0 : iQuestion + 1;
      buttonColors[iAnswer] = Colors.white;
      buttonsLocked = false;
    });
  }
}
