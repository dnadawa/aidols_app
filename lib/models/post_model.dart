import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String videoUrl;
  final String caption;
  final dynamic likes;
  final String authorId;
  final Timestamp timestamp;

  Post({
    this.id,
    this.imageUrl,
    this.videoUrl,
    this.caption,
    this.likes,
    this.authorId,
    this.timestamp,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      imageUrl: doc['imageUrl'],
      videoUrl: doc['videoUrl'],
      caption: doc['caption'],
      likes: doc['likes'],
      authorId: doc['authorId'],
      timestamp: doc['timestamp'],
    );
  }
}
