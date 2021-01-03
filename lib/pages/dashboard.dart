import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mazaghar/models/activityfeed.dart';
import 'package:mazaghar/pages/check_out_page.dart';
import 'package:mazaghar/widgets/productPost.dart';

import 'Home_sign_in.dart';
//import 'package:shop_app_admin/screens/add_product.dart';
//import '../db/category.dart';
//import '../db/brand.dart';

enum Page { dashboard, manage }

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor notActive = Colors.grey;
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  //BrandService _brandService = BrandService();
  //CategoryService _categoryService = CategoryService();

  int _revenue = 0;
  int _numberOfProduct = 0;
  int _soldProduct = 0;
  int _newProductOrders =0;
  int _ackProductOrders = 0 ;
  int _canceledProdut = 0;
  List<ActivityFeed> productsfeed = [];
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getNumbers();
  }

  getNumbers() async {
    int revenue = 0;
    int numberOfProduct = 0;
    int soldProduct = 0;
    int newProductOrders =0;
    int ackProductOrders = 0 ;
    int canceledProdut = 0;
    QuerySnapshot snapshot = await activitysellerFeed
        .document(locationCity)
        .collection(currentUser.id)
        .getDocuments();
    productsfeed=
        snapshot.documents.map((doc) => ActivityFeed.fromDocument(doc)).toList();
    productsfeed.forEach((feed) {
      if(feed.type=="sold") {
        soldProduct++;revenue=revenue+ int.parse(feed.price);}
      else if(feed.type=="accepted"){
        ackProductOrders++;
      }else if(feed.type=="closed"){
        canceledProdut++;
      }else if(feed.type=="create"){
        newProductOrders++;
      }
    });

    QuerySnapshot snapshotdata = await postsRef
        .document(locationCity)
        .collection(currentUser.id)
        .getDocuments();
      int postCount = snapshotdata.documents.length;
      posts = snapshotdata.documents.map((doc) => Post.fromDocument(doc)).toList();
      print("new product called "+newProductOrders.toString());
      setState(() {

        _revenue = revenue;
        _numberOfProduct = postCount;
        _soldProduct = soldProduct;
        _newProductOrders =newProductOrders;
        _ackProductOrders = ackProductOrders ;
        _canceledProdut = canceledProdut;
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                  child: FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.dashboard);
                      },
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedPage == Page.dashboard
                            ? active
                            : notActive,
                      ),
                      label: Text('Dashboard'))),
/*              Expanded(
                  child: FlatButton.icon(
                      onPressed: () {
                        setState(() => _selectedPage = Page.manage);
                      },
                      icon: Icon(
                        Icons.sort,
                        color:
                        _selectedPage == Page.manage ? active : notActive,
                      ),
                      label: Text('Manage'))),*/
            ],
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: _loadScreen());
  }

  Widget _loadScreen() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Column(
          children: <Widget>[
            Container(
              height: 30,
              child:
            ListTile(

                title: currentUser.state == "Active" ?Text(
                  'Your Account is Activated',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, color: Colors.green),
                ):Text(
                  'To activate your Account, please contact support',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, color: Colors.red),
                )
            ),),
            Container(
              height: 50,
              child: ListTile(
              subtitle: FlatButton.icon(
                onPressed:getNumbers,
                icon: Icon(
                  Icons.refresh,
                  size: 50.0,
                  color: Colors.green,
                ),
                label: Text("Refresh",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0, color: Colors.green)),
              ),
            ),),
            Container(
              height: 100,
              child:ListTile(

                subtitle: FlatButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Icons.attach_money,
                    size: 30.0,
                    color: Colors.green,
                  ),
                  label: Text(_revenue.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30.0, color: Colors.green)),
                ),
                title: Text(
                  'Revenue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17.0, color: Colors.grey),
                ),
              ) ,
            ),

            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Card(
                      child: ListTile(
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(Icons.add_shopping_cart),
                              label: Text("Products")),
                          subtitle: Text(
                            _numberOfProduct.toString()+"/"+currentUser.allowed ,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: active, fontSize: 60.0),
                          )),
                    ),
                  ),
                  /*Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      child: ListTile(
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(Icons.category),
                              label: Text("Categories")),
                          subtitle: Text(
                            '23',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: active, fontSize: 60.0),
                          )),
                    ),
                  ),*/
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Card(

                      child: ListTile(
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => CheckOutPage(
                          keySerach: "create",
                        ))),
                          title: FlatButton.icon(
                              onPressed:  null,
                              icon: Icon(Icons.card_giftcard),
                              label: Text("New orders")),
                          subtitle: Text(
                            _newProductOrders.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: active, fontSize: 60.0),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Card(
                      child: ListTile(
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => CheckOutPage(
                            keySerach: "sold",
                          ))),
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(Icons.tag_faces),
                              label: Text("Sold products")),
                          subtitle: Text(
                            _soldProduct.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: active, fontSize: 60.0),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Card(
                      child: ListTile(
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => CheckOutPage(
                            keySerach: "accepted",
                          ))),
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(Icons.shopping_cart),
                              label: Text("accepted")),
                          subtitle: Text(
                            _ackProductOrders.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: active, fontSize: 60.0),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Card(
                      child: ListTile(
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => CheckOutPage(
                            keySerach: "closed",
                          ))),
                          title: FlatButton.icon(
                              onPressed: null,
                              icon: Icon(Icons.close),
                              label: Text("Canceled")),
                          subtitle: Text(
                            _canceledProdut.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: active, fontSize: 60.0),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
/*      case Page.manage:
        return ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add product"),
              onTap: () {
                //Navigator.push(context, MaterialPageRoute(builder: (_) => AddProduct()));
                // todo : add
                Text("Add product");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.change_history),
              title: Text("Products list"),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text("Add category"),
              onTap: () {
                _categoryAlert();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Category list"),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text("Add brand"),
              onTap: () {
                _brandAlert();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text("brand list"),
              onTap: () {
                //_brandService.getBrands();
              },
            ),
            Divider(),
          ],
        );
        break;*/
      default:
        return Container();
    }
  }

/*  void _categoryAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _categoryFormKey,
        child: TextFormField(
          controller: categoryController,
          validator: (value){
            if(value.isEmpty){
              return 'category cannot be empty';
            }
          },
          decoration: InputDecoration(
              hintText: "add category"
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(onPressed: (){
          if(categoryController.text != null){
            //_categoryService.createCategory(categoryController.text);
          }
          Fluttertoast.showToast(msg: 'category created');
          Navigator.pop(context);
        }, child: Text('ADD')),
        FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('CANCEL')),

      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  void _brandAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _brandFormKey,
        child: TextFormField(
          controller: brandController,
          validator: (value){
            if(value.isEmpty){
              return 'category cannot be empty';
            }
          },
          decoration: InputDecoration(
              hintText: "add brand"
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(onPressed: (){
          if(brandController.text != null){
           // _brandService.createBrand(brandController.text);
          }
          Fluttertoast.showToast(msg: 'brand added');
          Navigator.pop(context);
        }, child: Text('ADD')),
        FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('CANCEL')),

      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }*/
}