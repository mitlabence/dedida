import 'package:dedida/Linguistics/EncounteredWord.dart';
import 'package:dedida/SessionOrchestrator.dart';
import 'package:flutter/material.dart';

class EncounteredWordsView extends StatefulWidget {
  final SessionOrchestrator sessionOrchestrator;

  const EncounteredWordsView({super.key, required this.sessionOrchestrator});

  @override
  State<EncounteredWordsView> createState() => _EncounteredWordsViewState();
}

class _EncounteredWordsViewState extends State<EncounteredWordsView> {
  late Future<List<EncounteredWord>> encounteredWordsFuture;

  @override
  void initState() {
    super.initState();
    encounteredWordsFuture = widget.sessionOrchestrator.getEncounteredWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Encountered Words")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
                child: Text("Word: # correct / # encountered"),
              ),
              FutureBuilder(
                  future: encounteredWordsFuture, builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  case ConnectionState.active:
                    return Text("Processing...");
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    else if (snapshot.hasData) {
                      // has List<EncounteredWord>
                      List<EncounteredWord> encounteredWords = snapshot.data!;
                      if (encounteredWords.isEmpty){
                        return Text("No entries found.");
                      }
                      return ListView.builder(
                          itemCount: encounteredWords.length,
                          prototypeItem: ListTile(
                              title: Text("${encounteredWords.first.root}: ${encounteredWords.first.timesCorrect} / ${encounteredWords.first.timesReviewed}")),
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Text("${encounteredWords[index].root}: ${encounteredWords[index].timesCorrect} / ${encounteredWords[index].timesReviewed}"));
                          });
                    }
                    return Text("No data found.");
                  default:
                    return Text("Unhandled connection state.");
                }
              }),
            ],
          ),
        ));
  }
}
