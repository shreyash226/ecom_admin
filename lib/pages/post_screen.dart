import 'package:flutter/material.dart';
import 'package:mazaghar/widgets/header.dart';
import 'package:mazaghar/widgets/productPost.dart';
import 'package:mazaghar/widgets/progress.dart';

import 'Home_sign_in.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  final String location;

  PostScreen({this.userId, this.postId, this.location});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(location)
          .collection(userId)
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
