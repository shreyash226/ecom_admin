import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mazaghar/models/user.dart';
import 'package:mazaghar/pages/Home_sign_in.dart';
import 'package:mazaghar/widgets/custom_image.dart';
import 'package:mazaghar/widgets/progress.dart';

import 'app_properties.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String description;
  //final String timestamp;
  final String mediaUrl1;
  final String mediaUrl2;
  final String mediaUrl3;
  final dynamic likes;
  final String location;
  final String state;
  final String productName;
  final String price;
  final String category;
  final String brandname;
  final String phoneNumber;


  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.description,
   // this.timestamp,
    this.mediaUrl1,
    this.mediaUrl2,
    this.mediaUrl3,
    this.likes,
    this.location,
    this.state,
    this.productName,
    this.price,
    this.category,
    this.brandname,
    this.phoneNumber,

  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      description: doc['description'],
     // timestamp: doc['timestamp'],
      mediaUrl1: doc['mediaUrl1'],
      mediaUrl2: doc['mediaUrl2'],
      mediaUrl3: doc['mediaUrl3'],
      likes: doc['likes'],
      location: doc['location'],
      state: doc['state'],
      productName: doc['productName'],
      price: doc['price'],
      category: doc['category'],
      brandname: doc['brandname'],
      phoneNumber: doc['phoneNumber'],

    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId:this.ownerId,
    username:this.username,
    description :this.description,
    //timestamp:this.timestamp,
    mediaUrl1:this.mediaUrl1,
    mediaUrl2:this.mediaUrl2,
    mediaUrl3:this.mediaUrl3,
    likes: this.likes,
    location:this.location,
    state:this.state,
    productName: this.productName,
    price: this.price,
    category: this.category,
    brandname:this.brandname,
    phoneNumber: this.phoneNumber,
    likeCount: getLikeCount(this.likes),
  );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String description;
  //final String timestamp;
  final String mediaUrl1;
  final String mediaUrl2;
  final String mediaUrl3;
  final String location;
  final String state;
  final String productName;
  final String price;
  final String category;
  final String brandname;
  final String phoneNumber;
  int likeCount;
  Map likes;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.description,
   // this.timestamp,
    this.mediaUrl1,
    this.mediaUrl2,
    this.mediaUrl3,
    this.likes,
    this.location,
    this.state,
    this.productName,
    this.price,
    this.category,
    this.brandname,
    this.phoneNumber,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => Text(""),//showProfile(context, profileId: user.id),
            child: Text(
              productName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(category),
          trailing: isPostOwner
              ? IconButton(
            onPressed: () => handleDeletePost(context),
            icon: Icon(Icons.delete),
          )
              : Text(''),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably


  deletePost() async {
    // delete post itself
    postsRef
        .document(location)
        .collection(currentUserId)
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    postsRefCat
        .document(location)
        .collection(category)
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    postsRefCat
        .document(location)
        .collection("MixCategory")
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for thep ost
    storageRef.child("post_1$postId.jpg").delete();
    storageRef.child("post_2$postId.jpg").delete();
    storageRef.child("post_3$postId.jpg").delete();
    Navigator.pop(context);

    // then delete all activity feed notifications
  }


  buildPostImage() {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          //cachedNetworkImage(mediaUrl1),
          SizedBox(height: 400, child: Carousel(

            //boxFit: BoxFit.cover,
            images: [
              cachedNetworkImageProduct(mediaUrl1),
              cachedNetworkImageProduct(mediaUrl2),
              cachedNetworkImageProduct(mediaUrl3)
            ],
            autoplay: false,
            dotSize: 10.0,
            dotColor: darkGrey,

            indicatorBgPadding: 2.0,
            animationCurve: Curves.fastOutSlowIn,
            dotBgColor: Color.fromRGBO(253, 184, 70, 0.5),
            animationDuration: Duration(milliseconds: 1000),
          ),),

          //Image.network(mediaUrl1),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(children: <Widget>[
          Container(
            margin: EdgeInsets.all(20.0),
            child: Text("Product Prize : $price Rs",style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 25
            ),),
          )

        ],),
/*        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20.0),
              child: Text(
                "$likeCount User have liked your Product",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              ),
            ),
          ],
        ),*/
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "Description :",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
            ),
            Expanded(

                child: Text(description ,style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
                fontSize: 18
            ),)),

          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      //mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}
