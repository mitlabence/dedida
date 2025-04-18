import 'package:cloud_firestore/cloud_firestore.dart';
import 'Linguistics/EncounteredWord.dart';
import 'global.dart';
import 'package:dedida/SessionOrchestrator.dart';

class FirebaseHelper {
  static final FirebaseHelper _instance = FirebaseHelper._internal();

  factory FirebaseHelper() {
    return _instance;
  }

  late String userUid;
  late final FirebaseFirestore firebase;
  late final DocumentReference personalDocument;

  FirebaseHelper._internal() {
    // Set root document in firestore
    userUid = firebaseUid;
    // Get instance of Firestore
    firebase = FirebaseFirestore.instance;
    personalDocument = firebase.collection("Users").doc(userUid);
  }

  Future<void> publishRandomStuff() async {
    final CollectionReference colRef = personalDocument
        .collection("Languages")
        .doc("German")
        .collection("EncounteredWords");
    final documentRef = colRef.doc("doc12");
    WriteBatch batch = firebase.batch();
    final Map<String, dynamic> mapToPublish = {"asd1": "keh", "kol": 1};
    batch.set(documentRef, mapToPublish);
    await batch.commit();
  }

  Future<void> publishEncounteredWords({String language = "German"}) async {
    final CollectionReference encounteredWordsRef = personalDocument.collection(
        "Languages").doc(language).collection("EncounteredWords");
    // TODO: test for access, existence of the ref?
    final SessionOrchestrator sessionOrchestrator = SessionOrchestrator();
    final List<EncounteredWord> encounteredWords =
    await sessionOrchestrator.getEncounteredWords();
    WriteBatch batch = firebase.batch();
    // TODO: use EncounteredWord.toMap() to convert before writing to document
    for (EncounteredWord word in encounteredWords) {
      Map<String, dynamic> wordMap = word.toMap();
      final int? wordId = wordMap.remove("id");
      if(wordId == null) {
        throw Exception("publishEncounteredWords(): null id encountered, word map: ${wordMap.toString()}");
      }
      // TODO: make sure keys exist before writing
      DocumentReference wordDocRef = encounteredWordsRef.doc(wordId.toString());
      batch.set(wordDocRef, wordMap, SetOptions(merge:true));
    }
    await batch.commit();
  }
}
