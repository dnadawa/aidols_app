import 'dart:async';


import 'package:aidols_app/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aidols_app/models/user_model.dart';
import 'package:aidols_app/screens/edit_profile_screen.dart';
import 'package:aidols_app/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String email;



  ProfileScreen({this.userId, this.email});

  @override
  ProfileScreenState createState() => ProfileScreenState(email);
}

class ProfileScreenState extends State<ProfileScreen> {

  final String email;


  final CollectionReference collectionReference  = Firestore.instance.collection("posts");
  List<DocumentSnapshot> images;
  StreamSubscription<QuerySnapshot> subscription;

  ProfileScreenState(this.email);

  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // TODO: implement initStated
    super.initState();
    subscription = collectionReference.where('authorID', isEqualTo: email).orderBy('timestamp',descending: true).snapshots().listen((datasnapshot){
      setState(() {
        images = datasnapshot.documents;
      });
    });
    print(email);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.exit_to_app), onPressed: ()=>AuthService.logout())
        ],
        title: Text(
          'Aidols',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontSize: 35.0,
          ),
        ),
      ),
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);



          return ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: user.profileImageUrl.isEmpty
                          ? AssetImage('assets/images/user_placeholder.jpg')
                          : CachedNetworkImageProvider(user.profileImageUrl),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    '12',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'posts',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    '386',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'followers',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    '345',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'following',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 200.0,
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                    user: user,
                                  ),
                                ),
                              ),
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      height: 80.0,
                      child: Text(
                        user.bio,
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    Divider(),

                    images!=null?GridView.builder(
                      shrinkWrap: true,
                        physics: ScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                        itemCount: images!=null?images.length:0,

                        itemBuilder: (contex,i){

                          String imgPath = images[i].data['imageUrl'];
                          String video_url = images[i].data['videoUrl'];

                          _videoPlayerController = VideoPlayerController.network(video_url!=''?video_url:'',);
                          _initializeVideoPlayerFuture = _videoPlayerController.initialize();


                        return video_url!=''?Chewie(
                              key: UniqueKey(),
                              controller: ChewieController(
                                videoPlayerController: _videoPlayerController,
                                autoInitialize: true,
                                looping: false,
                                allowFullScreen: false,
                                showControls: false,
                                aspectRatio: 1,
                              ),
                        ):Padding(
                          padding: const EdgeInsets.all(2),
                          child: Image(image: NetworkImage(imgPath),fit: BoxFit.cover,),
                        );




//                          return imgPath!=''?Padding(
//                            padding: const EdgeInsets.all(2),
//                            child: Image(image: NetworkImage(imgPath),fit: BoxFit.cover,),
//                          ):null;

                        },




                    ):Center(child: Text("No Posts",style: TextStyle(fontSize: 30),)),


                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
