import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  final String userId;
  final String uid;
  final String imageUrl;
  final String description;
  final DateTime timestamp;

  Post({
    required this.uid,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Post(
      uid: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
