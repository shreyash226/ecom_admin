import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mazaghar/models/user.dart';

/*import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';*/
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mazaghar/pages/addProduct.dart';
import 'package:mazaghar/pages/create_account.dart';
import 'package:mazaghar/pages/dashboard.dart';
import 'package:mazaghar/pages/profile.dart';
import 'package:mazaghar/pages/profile_page.dart';
import 'package:mazaghar/widgets/app_properties.dart';

import 'check_out_page.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('sellersUsers');
final postsRef = Firestore.instance.collection('sellersPost');
final postsRefCat = Firestore.instance.collection('sellersPostCategory');
final postsRefCatMix = Firestore.instance.collection('sellersPostCatMix');
final activityUserFeed = Firestore.instance.collection('activityUserFeed');
final activitysellerFeed = Firestore.instance.collection('activitysellerFeed');
final String locationCity = "Belgaum";

final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Animation<double> opacity;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  bool isAuthgoogle = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
        isAuthgoogle =false;
      });
      //configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
        isAuthgoogle =true;
      });
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      // print("Firebase Messaging Token: $token\n");
      usersRef
          .document(user.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        // print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          // print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
                body,
                overflow: TextOverflow.ellipsis,
              ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        // print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      // print("Settings registered: $settings");
    });
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      // TODO: Navigate to Create page
      final details = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      // 3) get username from create account, use it to make new user document in users collection
      if(details[0]!=null) {

        usersRef.document(user.id).setData({
        "id": user.id,
        "username": details[0],
        "email": user.email,
        "photoUrl": user.photoUrl,
        "address":details[1],
        "cityName": "Belgaum",
        "brandName" :details[2],
        "state" : "decative",
        "phoneNumber" : details[3],
        "gName" : user.displayName,
        "timestamp": timestamp,
        "state":"Active",
        "allowed":"10"
      });
      // make new user their own follower (to include their posts in their timeline)
/*      await followersRef
          .document(user.id)
          .collection('userFollowers')
          .document(user.id)
          .setData({});*/
      doc = await usersRef.document(user.id).get();
      currentUser = User.fromDocument(doc);}
    }
    else{
    currentUser = User.fromDocument(doc);}
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.
    animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Admin(),
          //CheckOutPage(keySerach: "All",),
          AddProduct(currentUser: currentUser),
          Profile(profileId: currentUser.id,currentUser: currentUser,),
          Container(child: ProfilePage()),
/*          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),*/
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
            //BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35.0,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );
/*    return RaisedButton(
       child: Text('Logout'),
       onPressed: logout,
     );*/
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/background_white.png'), fit: BoxFit.cover)),
        //alignment: Alignment.center,
        /*child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterShare',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),*/
        child: Container(
          decoration: BoxDecoration(color: transparentYellowIntro),
          child: SafeArea(
            child: new Scaffold(
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                        //opacity: opacity.value,
                        child: new Image.asset('images/logo.png')),
                  ),
                  isAuthgoogle==true?GestureDetector(
                    onTap: login,
                    child: Container(
                      width: 260.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'images/google_signin_button.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ):Text("Loading..."),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: 'Powered by '),
                            TextSpan(
                                text: 'MazaBappa',
                                style: TextStyle(fontWeight: FontWeight.bold))
                          ]),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
