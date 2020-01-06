

import 'dart:async';
import 'package:chewie/chewie.dart';

import 'package:aidols_app/models/user_data.dart';
import 'package:aidols_app/screens/comments.dart';
import 'package:flutter/material.dart';
import 'package:aidols_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String logged_user;
  final String email;

  const FeedScreen({Key key, this.logged_user, this.email}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState(logged_user,email);
}

class _FeedScreenState extends State<FeedScreen>{
 final String logged_user;

  final CollectionReference collectionReference  = Firestore.instance.collection("posts");
 final CollectionReference userRef  = Firestore.instance.collection("users");
 var subscription2;
  var user;
  List<DocumentSnapshot> posts;
  StreamSubscription<QuerySnapshot> subscription;

 VideoPlayerController _videoPlayerController;
 Future<void> _initializeVideoPlayerFuture;


  final String email;
  _FeedScreenState(this.logged_user, this.email);



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = collectionReference.snapshots().listen((datasnapshot){
      setState(() {
        posts = datasnapshot.documents;
      });
    });


    print(logged_user);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.dispose();
    subscription?.cancel();

  }
    String propic;
   Future<String> getImage(String author)async{
    subscription2 = await userRef.where('email',isEqualTo: author).getDocuments();
    user = await subscription2.documents;
    propic = await user[0].data['profileImageUrl'];


    return propic;

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Aidols',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontSize: 35.0,
          ),
        ),
      ),
      backgroundColor: Colors.blue,
      body: Column(
        children: <Widget>[
          Container(
            child: Expanded(
              child: posts!=null?ListView.builder(

                shrinkWrap: true,
                itemCount: posts.length,

                itemBuilder: (context,i){
                  String caption = posts[i].data['caption'];
                  int likes = posts[i].data['likes_count'];
                  String image_url = posts[i].data['imageUrl'];
                  String video_url =  posts[i].data['videoUrl'];
                  print(video_url);

                  String author = posts[i].data['author'];
                  String uid = posts[i].data['authorID'];
                  DateTime time = posts[i].data['timestamp'].toDate();
                  var formatter = new DateFormat('yyyy-MM-dd HH:mm');
                  String formattedDate = formatter.format(time);


                  _videoPlayerController = VideoPlayerController.network(video_url!=''?video_url:'',);

                  _initializeVideoPlayerFuture = _videoPlayerController.initialize();


                  var x = getImage(uid);
                  print(x);

                  return Container(
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Colors.white
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: ListTile(
                            key: UniqueKey(),
                            subtitle: Text(formattedDate,style: TextStyle(fontSize: 20),),
                            leading: CircleAvatar(backgroundImage: NetworkImage(x.toString()),radius: 30,),
                            title: Text(author,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                          ),
                        ),

                        video_url!=''?
                        Chewie(
                          key: UniqueKey(),
                          controller: ChewieController(
                            videoPlayerController: _videoPlayerController,
                            autoInitialize: true,
                            looping: false,
                            allowFullScreen: false,
                            aspectRatio: 3/2,
                          ),
                        ):
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image(image: NetworkImage(image_url)),
                        ),
                        
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(caption,
                            style: TextStyle(
                              fontSize: 20,color: Colors.black,

                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15,5,15,0),
                          child: Divider(thickness: 3,color: Colors.black,),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: <Widget>[
                            IconButton(icon: Icon(Icons.thumb_up), onPressed: null),
                            Text(likes.toString(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),

                          ],
                        ),
                        FlatButton(onPressed: (){


                          //please change the value of above variable to currently logged user

                          var liked_users = List<String>.from(posts[i].data['liked_users']);
                          int newLikes;

                          if(liked_users.contains(email)){
                                newLikes = likes - 1;
                                liked_users.remove(email);
                                collectionReference.document(posts[i].documentID).updateData({
                                  'liked_users': liked_users,
                                  'likes_count': newLikes
                                });
                          }
                          else{
                            newLikes = likes + 1;
                            liked_users.add(email);
                            collectionReference.document(posts[i].documentID).updateData({
                              'liked_users': liked_users,
                              'likes_count': newLikes
                            });
                          }

                          print(newLikes);
                          print(liked_users);
                          }, child: Text('Like'),color: Colors.red,),

                        FlatButton(onPressed: (){


                          //please change the value of above variable to currently logged user

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Comments(docId: posts[i].documentID,uid: logged_user,email: email,)),
                          );


                        }, child: Text('Comment'),color: Colors.blue,)



                      ],
                    ),
                  );
  },
              ): Center(child: CircularProgressIndicator(backgroundColor: Colors.white,)),
            ),
          ),
        ],
      ),
    );
  }
}
