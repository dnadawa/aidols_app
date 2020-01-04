import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String videoUrl;
  final String caption;
  final dynamic liked_users;
  final String authorId;
  final int likes_count;
  final Timestamp timestamp;
  final String authorName;

  Post({
    this.id,
    this.imageUrl,
    this.videoUrl,
    this.caption,
    this.liked_users,
    this.likes_count,
    this.authorId,
    this.authorName,
    this.timestamp,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      imageUrl: doc['imageUrl'],
      videoUrl: doc['videoUrl'],
      caption: doc['caption'],
      likes_count: doc['likes_count'],
      liked_users: doc['liked_users'],
      authorName: doc['authorName'],
      authorId: doc['authorId'],
      timestamp: doc['timestamp'],
    );
  }
}
