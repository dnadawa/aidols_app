import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aidols_app/models/user_data.dart';
import 'package:provider/provider.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = Firestore.instance;
  static QuerySnapshot subscription2;
  static var user;
  static CollectionReference collectionReference  = Firestore.instance.collection("users");

  static void signUpUser(
      BuildContext context, String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser signedInUser = authResult.user;
      if (signedInUser != null) {
        _firestore.collection('/users').document(signedInUser.uid).setData({
          'name': name,
          'email': email,
          'profileImageUrl': '',
        });
        Provider.of<UserData>(context).currentUserId = signedInUser.uid;
        Provider.of<UserData>(context).currentUserName = name;
        Provider.of<UserData>(context).currentUserEmail = email;
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  static void logout() {
    _auth.signOut();
  }


  static void login(String email, String password, BuildContext context) async {
    try {
      //Provider.of<UserData>(context).currentUserName = name;
      Provider.of<UserData>(context).currentUserEmail = email;
      var uid = await getUname(context);
      Provider.of<UserData>(context).currentUserName = uid;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e);
    }
  }

  static getUname(BuildContext context) async{
    subscription2 = await collectionReference.where("email", isEqualTo: Provider.of<UserData>(context).currentUserEmail).getDocuments();
    user = subscription2.documents;
    print(user[0].data['name']);
    return user[0].data['name'];

  }



}
