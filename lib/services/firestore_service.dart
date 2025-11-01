import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _firestore.collection('tasks');

  Stream<List<Task>> watchTasks(String ownerId) {
    return _tasksRef
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Task.fromDocument(doc))
              .toList(growable: false);
        });
  }

  Future<void> addTask({
    required String ownerId,
    required String title,
    String? description,
  }) async {
    await _tasksRef.add({
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'isDone': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleDone(String id, bool value) async {
    await _tasksRef.doc(id).update({'isDone': value});
  }

  Future<void> deleteTask(String id) async {
    await _tasksRef.doc(id).delete();
  }

  Future<void> updateTask(Task task) async {
    await _tasksRef.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'isDone': task.isDone,
      'timestamp': task.timestamp != null
          ? Timestamp.fromDate(task.timestamp!)
          : FieldValue.serverTimestamp(),
    });
  }
}
