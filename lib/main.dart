import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aidols_app/models/user_data.dart';
import 'package:aidols_app/screens/feed_screen.dart';
import 'package:aidols_app/screens/home_screen.dart';
import 'package:aidols_app/screens/login_screen.dart';
import 'package:aidols_app/screens/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final CollectionReference userRef  = Firestore.instance.collection("users");
  var user;
  QuerySnapshot subscription;




  Widget _getScreenId() {



    getName(String x,BuildContext context) async {
      subscription = await userRef.where('email', isEqualTo: x).getDocuments();
      user = subscription.documents;
//    String y = user[0].data['name'];

      //return y;

      //Provider.of<UserData>(context).currentUserName = y;
    }

    String y;
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,

      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {


          Provider.of<UserData>(context).currentUserId = snapshot.data.uid;
          String x = snapshot.data.email;
          Provider.of<UserData>(context).currentUserEmail = x;

          getName(x,context).then((_){
             y = user[0].data['name'];
            Provider.of<UserData>(context).currentUserName = y;
            print('User is $y');
          });



          print("Logged in main.dart is $y");




          return HomeScreen(logged: y,);
        } else {
          return LoginScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var changeNotifierProvider = ChangeNotifierProvider(
      builder: (context) => UserData(),
      child: MaterialApp(
        title: 'Aidols',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
                color: Colors.black,
              ),
        ),
        home: _getScreenId(),
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          SignupScreen.id: (context) => SignupScreen(),
          FeedScreen.id: (context) => FeedScreen(),
        },
      ),
    );
    return changeNotifierProvider;
  }
}
