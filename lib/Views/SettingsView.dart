import 'package:dedida/SessionOrchestrator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../TestStream.dart';

class SettingsView extends StatefulWidget {
  final SessionOrchestrator sessionOrchestrator;

  const SettingsView({super.key, required this.sessionOrchestrator});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}
// For now, show a test of using StreamController in an external class TestStream.
// TestStream has a StreamController with a stream. The class attribute i is
// incremented and sent to the stream when calling the f() function.

class _SettingsViewState extends State<SettingsView> {
  final TestStream counter = TestStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(
        child: StreamBuilder<int?>(
            stream: counter.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Waiting");
              }
              return Text("${snapshot.data ?? 0}");
            }),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            counter.f();
          },
          child: Icon(Icons.add)),
    );
  }
}
