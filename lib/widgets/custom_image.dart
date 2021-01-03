import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mazaghar/widgets/progress.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(20.0),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );


}
Widget cachedNetworkImageProduct(String mediaUrl) {
  return
    PinchZoomImage(
      zoomedBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
      hideStatusBarWhileZooming: true,

      image:
      CachedNetworkImage(

        imageUrl: mediaUrl,
        fit: BoxFit.scaleDown,
        width: 500,
        height: 500,
        /*   imageBuilder: (context, imageProvider) => PhotoView(
      imageProvider: imageProvider,

    ),*/
        placeholder: (context, url) => Padding(
          child: circularProgress(),
          padding: EdgeInsets.all(20.0),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
}