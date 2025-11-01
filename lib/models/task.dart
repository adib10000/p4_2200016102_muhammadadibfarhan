import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime? timestamp;

  const Task({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.isDone,
    this.timestamp,
  });

  Task copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    bool? isDone,
    DateTime? timestamp,
  }) {
    return Task(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'isDone': isDone,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory Task.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Task(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      isDone: data['isDone'] as bool? ?? false,
      timestamp: _parseTimestamp(data['timestamp']),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
