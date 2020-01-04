

import 'dart:async';


import 'package:aidols_app/models/user_data.dart';
import 'package:aidols_app/screens/comments.dart';
import 'package:flutter/material.dart';
import 'package:aidols_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final CollectionReference collectionReference  = Firestore.instance.collection("posts").document('q01YFfzlGDOrn2Etek3awyskCnk1').collection('usersPosts');
  List<DocumentSnapshot> posts;
  StreamSubscription<QuerySnapshot> subscription;

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
    subscription?.cancel();

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
                            subtitle: Text('2012.22.12',style: TextStyle(fontSize: 20),),
                            leading: CircleAvatar(backgroundColor: Colors.blue,radius: 30,),
                            title: Text('Sanjula Hasaranga',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                          ),
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
