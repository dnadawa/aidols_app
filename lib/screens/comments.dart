import 'dart:async';

import 'package:aidols_app/models/user_model.dart';
import 'package:aidols_app/screens/profile_screen.dart';
import 'package:aidols_app/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Comments extends StatefulWidget {


final String docId;
final String uid;
final String email;

   Comments({Key key, this.docId, this.uid, this.email}) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState(docId,uid,email);
}

class _CommentsState extends State<Comments> {
  
   final String docId;
   final String uid;
   final String email;
  _CommentsState(this.docId, this.uid, this.email);



  CollectionReference collectionReference2  = Firestore.instance.collection("users");





  String img_url;
   List<DocumentSnapshot>  comments;

   StreamSubscription<QuerySnapshot> subscription;
   QuerySnapshot subscription2;
   CollectionReference collectionReference;
   var userlist;



   getpro() async {
     subscription2 = await collectionReference2.where("email", isEqualTo: email).getDocuments();
     userlist = subscription2.documents;

     print(userlist[0].data['profileImageUrl']);
   }


  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();
    getpro();
     collectionReference  = Firestore.instance.collection("posts").document('q01YFfzlGDOrn2Etek3awyskCnk1').collection('usersPosts').document(docId).collection('comments');
     subscription = collectionReference.snapshots().listen((datasnapshot){
      setState(() {
        comments = datasnapshot.documents;
      });
    });



  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();

  }



  
  

  @override
  Widget build(BuildContext context) {


    TextEditingController comment = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: comment!=null?ListView.builder(
              shrinkWrap: true,
              itemCount: comments.length,
              itemBuilder: (context,i){
                String comment = comments[i].data['comment'];
                String user = comments[i].data['user'];
                String image = comments[i].data['image'];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 05, 10, 05),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(image)),
                          title: Text(user,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:73),
                          child: Text(comment, style: TextStyle(fontSize: 17),),
                        ),
                      ],
                    ),
                  ),
                );
              },


            ):Center(child: CircularProgressIndicator(),),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: comment,
                      decoration: InputDecoration(
                        hintText: "Add Comment",
                        enabledBorder:UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 5),
                            borderRadius: BorderRadius.circular(10)
                        ),

                      ),

                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: () async {



                  final CollectionReference collectionReference  = Firestore.instance.collection("posts")
                      .document('q01YFfzlGDOrn2Etek3awyskCnk1').collection('usersPosts').document(docId).collection('comments');
                  Map data =<String, dynamic> {
                    'comment': comment.text,
                    'user': uid,
                    'image': userlist[0].data['profileImageUrl']


                  };
                  await collectionReference.add(data);
                  comment.clear();


                })
              ],
            ),
          ),

        ],
      ),
    );
  }
}
