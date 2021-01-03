import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mazaghar/models/activityfeed.dart';
import 'package:mazaghar/models/product.dart';
import 'package:mazaghar/widgets/app_properties.dart';
import 'Home_sign_in.dart';

//TODO: NOT DONE. WHEEL SCROLL QUANTITY
class CheckOutPage extends StatefulWidget {
  final String keySerach;

  const CheckOutPage({Key key, this.keySerach}) : super(key: key);

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  bool isLoading = true;
  List<ActivityFeed> products = [];
  int _perPage = 8;
  DocumentSnapshot _lastDoc;
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreProducts = false;
  bool _moreProductAvaiable = true;

  var isProductAv =false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProducts();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll <= delta) {
        _getProductsMore();
      }
    });
  }

  _getProducts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await activitysellerFeed
        .document(locationCity)
        .collection(currentUser.id)
        .where('type', isEqualTo: widget.keySerach)
        //.orderBy('timestamp', descending: true)
        .limit(_perPage)
        .getDocuments();
    products = snapshot.documents
        .map((doc) => ActivityFeed.fromDocument(doc))
        .toList();
    bool avi=false;
    if(snapshot.documents.length!=0 ){
      _lastDoc = snapshot.documents[snapshot.documents.length - 1];
      avi=true;
    }
    setState(() {
      isProductAv=avi;
      isLoading = false;
    });
  }

  _getProductsMore() async {
    if (_moreProductAvaiable == false) {
      return;
    }
    if (_gettingMoreProducts == true) {
      return;
    }
    print(_lastDoc.data["postId"]);
    print("in more product passes");

    _gettingMoreProducts = true;
    QuerySnapshot snapshot = await activitysellerFeed
        .document(locationCity)
        .collection(currentUser.id)
        .orderBy('timestamp', descending: true)
        .startAfter([_lastDoc.data["timestamp"]])
        .limit(_perPage)
        .getDocuments();
    if (snapshot.documents.length < _perPage) {
      _moreProductAvaiable = false;
    }
    _lastDoc = snapshot.documents[snapshot.documents.length - 1];
    products.addAll(snapshot.documents
        .map((doc) => ActivityFeed.fromDocument(doc))
        .toList());
    setState(() {});
    _gettingMoreProducts = false;
  }

  onclickproduct(ActivityFeed productfeed) async {
 /*   DocumentSnapshot doc = await postsRefCat
        .document(locationCity)
        .collection("MixCategory")
        .document(productfeed.productId).get();
    if (doc.exists) {
      dailogbox();
    }
    else {

    }
    return;*/
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatusDialog(productfeed,widget.keySerach);
        }
    );
  }



  cardFeed(ActivityFeed productfeed) {
    return  InkWell(
      onTap:
      (){onclickproduct(productfeed);} ,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(productfeed.image),
                  maxRadius: 24,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                                text: productfeed.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            TextSpan(
                              text: ' Order form ',
                            ),
                            TextSpan(
                              text: productfeed.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),

                            ),TextSpan(
                              text: ' \nContact number :',
                            ),
                            TextSpan(
                              text: productfeed.phoneUser,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize : 18
                                ,
                              ),
                            )
                          ]),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.blue[700],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child:
                      Text('View to change the status', style: TextStyle(color: Colors.blue[700])),
                    )
                  ],
                ),
                /*Row(
                  children: <Widget>[
                    Icon(
                      Icons.cancel,
                      size: 14,
                      color: Color(0xffF94D4D),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Decline',
                          style: TextStyle(color: Color(0xffF94D4D))),
                    )
                  ],
                ),*/
              ],
            )
          ],
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: darkGrey),

        title: Text(
          'Orders',
          style: TextStyle(
              color: darkGrey, fontWeight: FontWeight.w500, fontSize: 18.0),
        ),
      ),
      body: isProductAv?
      LayoutBuilder(
        builder: (_, constraints) => SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              height: constraints.maxHeight,
              child: Scrollbar(
                child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (_, index) => cardFeed(products[index]),
                  itemCount: products.length,
                ),
              ),
            ),
          ),
        ),
      )
          :Center(child: Text("No Orders"),),
    );
  }
}

class Scroll extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    LinearGradient grT = LinearGradient(
        colors: [Colors.transparent, Colors.black26],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter);
    LinearGradient grB = LinearGradient(
        colors: [Colors.transparent, Colors.black26],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);

    canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, 30),
        Paint()
          ..shader = grT.createShader(Rect.fromLTRB(0, 0, size.width, 30)));

    canvas.drawRect(Rect.fromLTRB(0, 30, size.width, size.height - 40),
        Paint()..color = Color.fromRGBO(50, 50, 50, 0.4));

    canvas.drawRect(
        Rect.fromLTRB(0, size.height - 40, size.width, size.height),
        Paint()
          ..shader = grB.createShader(
              Rect.fromLTRB(0, size.height - 40, size.width, size.height)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}


class StatusDialog extends StatefulWidget {
  final ActivityFeed productfeedR;
  final  String keySerach_;
  StatusDialog(this.productfeedR, this.keySerach_);


  @override
  State<StatefulWidget> createState() {
    return StatusDialogState();
  }
}

class StatusDialogState extends State<StatusDialog> {

  String _selectedText = "Accept the order";



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Status Update"),
      content: new DropdownButton<String>(
        hint: Text("Status"),
        value: _selectedText,
        items: <String>['Accept the order', 'Cancel the order', 'Sold the order',]
            .map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        onChanged: (String val) {
          print(val);
          setState(() {
            _selectedText = val;
          });
        },
      ),
      actions: <Widget>[

        FlatButton(
          child: Text("CANCEL"),
          onPressed: () {
            Navigator.pop(context);

          },
        ),
        FlatButton(
          child: Text("UPDATE"),
          onPressed: () {
            String inputVal = "";
            switch(_selectedText) {
              case "Accept the order": {
                inputVal="accepted";
              }
              break;

              case "Cancel the order": {
                inputVal="closed";
              }
              break;
              case "Sold the order": {
                inputVal="sold";
              }
              break;

              default: {
                //statements;
              }
              break;
            }
            activityUserFeed
                .document(locationCity)
                .collection(widget.productfeedR.userId)
                .document(widget.productfeedR.feedId )
                .setData({
              "type": inputVal,
              "productName":widget.productfeedR.productName,
              "ownerId": widget.productfeedR.ownerId,
              "username": widget.productfeedR.username,
              "sellername" :widget.productfeedR.sellername,
              "userId": widget.productfeedR.userId,
              "image": widget.productfeedR.image,
              "timestamp": timestamp,
              "status" : "raised",
              "feedId" : widget.productfeedR.feedId,
              "productId" : widget.productfeedR.productId,
              "price" : widget.productfeedR.price,
              "phoneUser" : widget.productfeedR.phoneUser,
              "sellerPhone": widget.productfeedR.sellerPhone,
            });
            activitysellerFeed
                .document(locationCity)
                .collection(currentUser.id)
                .document(widget.productfeedR.feedId)
                .setData({
              "type": inputVal,
              "productName":widget.productfeedR.productName,
              "ownerId": widget.productfeedR.ownerId,
              "username": widget.productfeedR.username,
              "sellername" :widget.productfeedR.sellername,
              "userId": widget.productfeedR.userId,
              "image": widget.productfeedR.image,
              "timestamp": timestamp,
              "status" : "raised",
              "feedId" : widget.productfeedR.feedId,
              "productId" : widget.productfeedR.productId,
              "price" : widget.productfeedR.price,
              "phoneUser" : widget.productfeedR.phoneUser,
              "sellerPhone": widget.productfeedR.sellerPhone,
            });
            Navigator.pop(context);
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) =>
                CheckOutPage(keySerach: widget.keySerach_,)));
          },
        ),
      ],
    );
  }
}

