import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String address;
  final String cityName;
  final String brandName;
  final String state;
  final String phoneNumber;
  final String gName;
  final String allowed;
  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.address,
    this.cityName,
    this.brandName,
    this.state,
    this.phoneNumber,
    this.gName,
    this.allowed

  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      address: doc['address'],
      cityName: doc['cityName'],
      brandName: doc['brandName'],
      state: doc['state'],
      phoneNumber: doc['phoneNumber'],
      gName: doc['gName'],
      allowed: doc['allowed'],
    );
  }
}
