import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityFeed {
  final String type;
  final String productName;
  final String ownerId;
  final String username;
  final String sellername ;
  final String userId;
  final String image;
  final String status ;
  final String feedId ;
  final String productId ;
  final String price;
  final String phoneUser;
  final String sellerPhone;
  ActivityFeed({
    this.type,
    this.productName,
    this.ownerId,
    this.username,
    this.sellername ,
    this.userId,
    this.image,
    this.status ,
    this.feedId ,
    this.productId,
    this.price,
    this.phoneUser,
    this.sellerPhone
  });

  factory ActivityFeed.fromDocument(DocumentSnapshot doc) {
    return ActivityFeed(
        type: doc['type'],
        productName: doc['productName'],
        ownerId: doc["ownerId"],
        username: doc['username'],
        sellername: doc['sellername'],
        userId: doc['userId'],
        image: doc['image'],
        status: doc['status'],
        feedId: doc['feedId'],
        productId: doc['productId'],
        price: doc["price"],
        phoneUser:doc["phoneUser"],
        sellerPhone:doc["sellerPhone"]
    );
  }
}
