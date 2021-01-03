import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mazaghar/pages/Home_sign_in.dart';
import 'package:mazaghar/pages/post_screen.dart';
import 'package:mazaghar/widgets/custom_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mazaghar/widgets/productPost.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {

    postsRef
        .document(post.location)
        .collection(post.ownerId)
        .document(post.postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostScreen(
              postId: post.postId,
              userId: post.ownerId,
              location: post.location,
            ),
          ),
        );
      }else{
      // Todo Snake bar
        Fluttertoast.showToast(
            msg: "This Post has been deleted !!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }

  });
      }

  @override
  Widget build(BuildContext context) {


/*    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl1),
    );*/
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      child:Card(

      child: Hero(tag: Text("Hero 1"), child:Material(
        borderRadius: BorderRadius.all(Radius.circular(5)) ,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          onTap: () => showPost(context),
          child: GridTile(

            footer: Container(
              color: Colors.white,
/*                 child: ListTile(
                  leading: Text(prod_name,style: TextStyle(
                    fontWeight: FontWeight.bold),
                  ),
                  title: Text("Rs:$prod_price", style: TextStyle(
                    color: Colors.pink , fontWeight: FontWeight.w800
                ),),
                  subtitle: Text("Rs:$prod_old_price", style: TextStyle(
                    color: Colors.black45 , fontWeight: FontWeight.w800,
                      decoration: TextDecoration.lineThrough
                ),)
                ),*/
              child: Row(children: <Widget>[
                Expanded(
                  child: Text(post.productName, style: TextStyle(
                      fontWeight: FontWeight.bold,fontSize: 20.0
                  ),),
                ),
                new Text("Rs ${post.price}", style: TextStyle(fontSize:20.0,color: Colors.red),)
              ],

              ),
            ),
            child: cachedNetworkImage(post.mediaUrl1),),
        ),
      ) ),
    ) ,);
  }
}
