import 'package:dedida/Constants.dart';
import 'package:dedida/SessionOrchestrator.dart';
import 'package:dedida/Settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  bool saveLocked = true; // lock save button while loading or while saving
  Settings? currentSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(
        child: FutureBuilder(
            future: widget.sessionOrchestrator.getSettings(),
            builder: (BuildContext context, AsyncSnapshot<Settings> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                if (snapshot.data == null) {
                  return Text("Null settings received...");
                } else {
                  currentSettings ??= snapshot.data!; // only initialize once
                  saveLocked = false;
                  return settingsList();
                }
              } else {
                return Text("No data detected.");
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // TODO: fix this async function!!!
            await widget.sessionOrchestrator.saveSettings(currentSettings!);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Saved settings"),
                duration: Duration(seconds: 2)));
          },
          child: Icon(Icons.save)),
    );
  }

  Widget settingsList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Datasets to use"),
        SizedBox(
          height: 300,
          width: 200,
          child: ListView(
            children: kDatasetsNames.map((String datasetName) {
              return CheckboxListTile(
                  title: Text(datasetName),
                  value: currentSettings!.usedDatasets.contains(datasetName),
                  onChanged: (bool? isChecked) {
                    setState(() {
                      if (isChecked == true) {
                        currentSettings!.addUsedDataset(datasetName);
                      } else {
                        currentSettings!.removeUsedDataset(datasetName);
                      }
                    });
                  });
            }).toList(),
          ),
        )
      ],
    );
  }
}

Widget textWithCheckbox(String text, bool isChecked, Function onChanged) {
  return Row(
    children: [Text(text), Checkbox(value: isChecked, onChanged: onChanged())],
  );
}
