import 'package:dedida/FirebaseHelper.dart';
import 'package:dedida/SessionOrchestrator.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'DBHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'Views/QuizView.dart';
import 'Views/SettingsView.dart';
import 'Views/EncounteredWordsView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'google_auth.dart';
import 'global.dart';

// TODO: if sqflite does not work on desktop, switch to drift? ( built on SQLite too)
//TODO: add definition (as clickable to show) to words! Have to update database?
//    Or make other tables referencing the primary key in the main database,
//    This way multiple languages translations can be added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final String dbpath = await getDatabasesPath();
  final userCredential = await signInWithGoogle();
  if (userCredential.user == null) {
    // TODO: proper handling of sign-in error
    throw Exception("Authentication failed. User is null!");
  } else {
    firebaseUid = userCredential.user!.uid;
    FirebaseHelper fbh = FirebaseHelper();
    await FirebaseAppCheck.instance.activate(
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. debug provider
      // 2. safety net provider
      // 3. play integrity provider
      androidProvider: AndroidProvider.debug,
    ); // https://firebase.google.com/docs/app-check/flutter/default-providers
    firebaseAppCheckToken = (await FirebaseAppCheck.instance.getToken())!;
    // FIXME: null check should not be forced...
    //await fbh.publishEncounteredWords(); // TODO: implement this on user click (in settings view)
  }

  // TODO: set up database helper and session orchestrator here
  DatabaseHelper dataBaseHelper = DatabaseHelper();
  SessionOrchestrator sessionOrchestrator = SessionOrchestrator();
  runApp(MyApp(sessionOrchestrator: sessionOrchestrator));
}

class MyApp extends StatelessWidget {
  final SessionOrchestrator sessionOrchestrator;

  const MyApp({super.key, required this.sessionOrchestrator});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "dedida",
        theme: ThemeData(primarySwatch: Colors.amber),
        initialRoute: '/quiz',
        routes: {
          '/quiz': (context) => MainScreen(
              sessionOrchestrator: sessionOrchestrator, initialNavBarIndex: 0),
          '/summary': (context) => MainScreen(
              sessionOrchestrator: sessionOrchestrator, initialNavBarIndex: 1),
          '/settings': (context) => MainScreen(
              sessionOrchestrator: sessionOrchestrator, initialNavBarIndex: 2),
        });
  }
}

class MainScreen extends StatefulWidget {
  final SessionOrchestrator sessionOrchestrator;
  final int? initialNavBarIndex;

  const MainScreen(
      {super.key,
      required this.sessionOrchestrator,
      required this.initialNavBarIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _navBarIndex;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    if (widget.initialNavBarIndex != null) {
      _navBarIndex = widget.initialNavBarIndex!;
    } else {
      _navBarIndex = 0;
    }
    _widgetOptions = <Widget>[
      QuizView(
        sessionOrchestrator: widget.sessionOrchestrator,
      ),
      EncounteredWordsView(
        sessionOrchestrator: widget.sessionOrchestrator,
      ),
      SettingsView(
        sessionOrchestrator: widget.sessionOrchestrator,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _navBarIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_navBarIndex)),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.blue,
          selectedItemColor: Colors.amber,
          currentIndex: _navBarIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_list), label: "Summary"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings")
          ]),
    );
  }
}
