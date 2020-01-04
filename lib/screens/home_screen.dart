import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aidols_app/models/user_data.dart';
import 'package:aidols_app/screens/activity_screen.dart';
import 'package:aidols_app/screens/create_post_screen.dart';
import 'package:aidols_app/screens/feed_screen.dart';
import 'package:aidols_app/screens/profile_screen.dart';
import 'package:aidols_app/screens/search_screen.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(logged_user: Provider.of<UserData>(context).currentUserName,email: Provider.of<UserData>(context).currentUserEmail,),
          SearchScreen(),
          CreatePostScreen(),
          ActivityScreen(),
          ProfileScreen(userId: Provider.of<UserData>(context).currentUserId),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentTab,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        activeColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
