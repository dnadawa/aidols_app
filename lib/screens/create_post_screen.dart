import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aidols_app/models/post_model.dart';
import 'package:aidols_app/models/user_data.dart';
import 'package:aidols_app/services/database_service.dart';
import 'package:aidols_app/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File _image;
  File _videoFile;
  VideoPlayerController _videoPlayerController;
  TextEditingController _captionController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Add Photo'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: Text('Choose From Gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
        
            CupertinoActionSheetAction(
              child: Text('Capture Video'),
              onPressed: () {
                _handleVideo(ImageSource.camera);
              },
            ),
            CupertinoActionSheetAction(
              child: Text('Choose from Video\'s'),
              onPressed: () {
                _handleVideo(ImageSource.gallery);
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add Photo/Video'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            SimpleDialogOption(
              child: Text('Choose From Gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
            SimpleDialogOption(
              child: Text('Capture Video'),
              onPressed: () {
                _handleVideo(ImageSource.camera);
              },
            ),
            SimpleDialogOption(
              child: Text('Choose from Video\'s'),
              onPressed: () {
                _handleVideo(ImageSource.gallery);
              },
            ),
            SimpleDialogOption(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  _handleVideo(ImageSource source) async {
    Navigator.pop(context);
    File videoFile = await ImagePicker.pickVideo(source: source);
    _videoFile = videoFile;
    _videoPlayerController = VideoPlayerController.file(_videoFile)
      ..initialize().then((_) {
        setState(() {
          _videoPlayerController.play();
        });
      });
  }

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
//      imageFile = await _cropImage(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }


  _submit() async {

    if (!_isLoading && (_image != null || _videoFile != null) && _caption.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      print('clicked');

      // Create post
      String imageUrl2,videoUrl2 = '';
      if(_image!=null){
         imageUrl2 = await StorageService.uploadPost(_image);
      }
      if(_videoFile!=null){
         videoUrl2 = await StorageService.uploadPost(_videoFile);
      }
      print(imageUrl2);
      print(videoUrl2);

      Post post = Post(
        imageUrl: imageUrl2,
        videoUrl: videoUrl2,
        caption: _caption,
        liked_users: [],
        likes_count: 0,
        authorId: Provider.of<UserData>(context).currentUserEmail,
        authorName: Provider.of<UserData>(context).currentUserName,
        timestamp: Timestamp.fromDate(DateTime.now()),
      );

      DatabaseService.createPost(post);

      // Reset data
      _captionController.clear();

      setState(() {
        imageUrl2 = '';
        videoUrl2 = '';
        _caption = '';
        _image = null;
        _videoFile = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _submit,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              children: <Widget>[
                _isLoading
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.blue[200],
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      )
                    : SizedBox.shrink(),
                GestureDetector(
                  onTap: _showSelectImageDialog,
                  child: Container(
                    height: width,
                    width: width,
                    color: Colors.grey[300],
                    child: _videoFile == null && _image == null
                        ? Icon(
                            Icons.add_a_photo,
                            color: Colors.white70,
                            size: 150.0,
                          )
                        : _image != null
                            ? Image(
                                image: FileImage(_image),
                                fit: BoxFit.cover,
                              )
                            : Chewie(
                                controller: ChewieController(
                                  videoPlayerController: _videoPlayerController,
                                  autoInitialize: true,
                                  looping: true,
                                  aspectRatio: 1,
                                ),
                              ),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextField(
                    controller: _captionController,
                    style: TextStyle(fontSize: 18.0),
                    decoration: InputDecoration(
                      labelText: 'Caption',
                    ),
                    onChanged: (input) => _caption = input,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
