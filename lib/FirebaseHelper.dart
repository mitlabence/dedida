import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart';

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

    personalDocument = firebase.collection("de").doc(userUid);
  }
  Future<void> publishRandomStuff() async {
    // FIXME: user does not have sufficient permissions
    WriteBatch batch = firebase.batch();
    final Map<String, dynamic> mapToPublish = {"asd": "keh", "kol": 1};
    batch.set(personalDocument, mapToPublish);
    await batch.commit();
  }
}
