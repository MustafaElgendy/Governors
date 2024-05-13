import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getDocID(DocumentReference docRef) async {
  DocumentSnapshot snapshot = await docRef.get();
  var docID = await snapshot.reference.id;
  return docID;
}
