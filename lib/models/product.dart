import 'package:cloud_firestore/cloud_firestore.dart';
class Product{
/*  String image;
  String name;
  String description;
  double price;

  Product(this.image, this.name, this.description, this.price);*/
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
  Product(
  {
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
    this.price ,
    this.category,
    this.brandname,
    this.phoneNumber,
  }
      );

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
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
}