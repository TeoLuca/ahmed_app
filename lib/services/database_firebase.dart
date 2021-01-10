import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseFirebase {
  DatabaseFirebase();

  //collection reference
  final CollectionReference suggestionsCollection =
      FirebaseFirestore.instance.collection('suggestions');

  final CollectionReference bugCollection =
      FirebaseFirestore.instance.collection('bugs');

  Future<void> updateSuggestionData(String title, String description) async {
    return await suggestionsCollection.doc().set({
      'title': title,
      'description': description,
    });
  }

  Future<void> updateBugsData(String title, String description) async {
    return await bugCollection.doc().set({
      'title': title,
      'description': description,
    });
  }
}
