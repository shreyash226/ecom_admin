import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:mazaghar/models/activityfeed.dart';
import 'package:mazaghar/models/user.dart';
import 'package:mazaghar/widgets/app_properties.dart';
import 'package:mazaghar/widgets/productPost.dart';
import 'package:mazaghar/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:mazaghar/pages/dashboard.dart';
import 'Home_sign_in.dart';


class AddProduct extends StatefulWidget {

  final User currentUser;

  AddProduct({this.currentUser});
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quatityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  List<String> selectedSizes = <String>[];
  File _image1;
  File _image2;
  File _image3;
  bool isUploading = false;
  bool splashscreen =true;
  String postId = Uuid().v4();


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
    _getCategories();
    getNumbers();

/*    _getBrands();*/
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown(){
    List<DropdownMenuItem<String>> items = new List();
    for(int i = 0; i < categories.length; i++){
      setState(() {
        items.insert(0, DropdownMenuItem(child: Text(categories[i].data['category']),
            value: categories[i].data['category']));
      });
    }
    return items;
  }

  getNumbers() async {
    int revenue = 0;
    int numberOfProduct = 0;
    int soldProduct = 0;
    int newProductOrders =0;
    int ackProductOrders = 0 ;
    int canceledProdut = 0;
    QuerySnapshot snapshot = await activityUserFeed
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
    print("number_of_product :"+postCount.toString());
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
    return  splashscreen == true ? buildSplashScreen() :
      Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon:
            Icon(Icons.close, color: black,),
          onPressed: () => selectImage(context,true),
          )
        ],
        elevation: 0.1,
        backgroundColor: white,


        title: Text("add product", style: TextStyle(color: black),),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              isUploading ? linearProgress() : Text(""),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(color: grey.withOpacity(0.5), width: 2.5),
                          onPressed: (){
                            _selectImage(ImagePicker.pickImage(source: ImageSource.gallery), 1);
                          },
                          child: _displayChild1()
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(color: grey.withOpacity(0.5), width: 2.5),
                          onPressed: (){
                            _selectImage(ImagePicker.pickImage(source: ImageSource.gallery), 2);

                          },
                          child: _displayChild2()
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: grey.withOpacity(0.5), width: 2.5),
                        onPressed: (){
                          _selectImage(ImagePicker.pickImage(source: ImageSource.gallery), 3);
                        },
                        child: _displayChild3(),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Enter a product Details',textAlign: TextAlign.center ,style: TextStyle(color: red, fontSize: 12),),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                      hintText: 'Product name'
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return 'You must enter the product name';
                    }else if(value.length > 30){
                      return 'Product name cant have more than 30 letters';
                    }else{
                      return null;
                    }
                  },
                ),
              ),

//              select category
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Category: ', style: TextStyle(color: red),),
                  ),
                  DropdownButton(items: categoriesDropDown, onChanged: changeSelectedCategory, value: _currentCategory,),
/*                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Brand: ', style: TextStyle(color: red),),
                  ),
                  DropdownButton(items: brandsDropDown, onChanged: changeSelectedBrand, value: _currentBrand,),*/
                ],
              ),

//
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: descriptionController,

                  decoration: InputDecoration(
                    hintText: 'Description',
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return 'You must enter the product Description';
                    }else if(value.length > 500){
                      return 'Product Description cant have more than 500 letters';
                    }else{
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: quatityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Price',
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return 'You must enter the product Price';
                    }else if(value.length > 5){
                      return 'Product Price cant have more than 5 digit';
                    }else if(value.contains("0")){
                      return 'Product name cant be 0 ';
                    }
                    else{
                      return null;
                    }
                  },
                ),
              ),




              FlatButton(
                color: red,
                textColor: white,
                child: Text('add product'),
                onPressed: () {
                  validateAndUpload();
                },
               // onPressed: isUploading ? null : () => validateAndUpload(),
              )
            ],
          ),
        ),
      ),
    );
  }

  _getCategories() async{
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data['category'];
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  void _selectImage(Future<File> pickImage, int imageNumber) async{
    File tempImg = await pickImage;
    switch(imageNumber){
      case 1:  setState(() => _image1 = tempImg);
      break;
      case 2:  setState(() => _image2 = tempImg);
      break;
      case 3:  setState(() => _image3 = tempImg);
      break;
    }
  }

  Widget _displayChild1() {
    if(_image1 == null){
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: new Icon(Icons.add, color: grey,),
      );
    }else{
      return Image.file(_image1, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  Widget _displayChild2() {
    if(_image2 == null){
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: new Icon(Icons.add, color: grey,),
      );
    }else{
      return Image.file(_image2, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  Widget _displayChild3() {
    if(_image3 == null){
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 70, 14, 70),
        child: new Icon(Icons.add, color: grey,),
      );
    }else{
      return Image.file(_image3, fit: BoxFit.fill, width: double.infinity,);
    }
  }
  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_image1.readAsBytesSync());
    final compressedImageFile = File('$path/img_1$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _image1 = compressedImageFile;
    });

    final tempDir2 = await getTemporaryDirectory();
    final path2 = tempDir2.path;
    Im.Image imageFile2 = Im.decodeImage(_image2.readAsBytesSync());
    final compressedImageFile2 = File('$path2/img_2$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile2, quality: 85));
    setState(() {
      _image2 = compressedImageFile2;
    });

    final tempDir3 = await getTemporaryDirectory();
    final path3 = tempDir3.path;
    Im.Image imageFile3 = Im.decodeImage(_image3.readAsBytesSync());
    final compressedImageFile3 = File('$path/img_3$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile3, quality: 85));
    setState(() {
      _image3 = compressedImageFile3;
    });
  }
  Future<String> uploadImage(imageFile,count) async {
    StorageUploadTask uploadTask =
    storageRef.child("post_$count$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      { String media_url1,String media_url2 ,String media_url3}) {
    String proname = productNameController.text;
    var listOfKeys = proname.split(" ");
    var finalListKeys =[];
    listOfKeys.forEach((element) {
      for(int i=1;i<=element.length;i++){

        finalListKeys.add(element.substring(0,i));
      }
    });
    print(finalListKeys);
    print(postId);
    postsRef
        .document(widget.currentUser.cityName)
        .collection(widget.currentUser.id)
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "description": descriptionController.text,
      "timestamp": timestamp,
      "mediaUrl1": media_url1,
      "mediaUrl2": media_url2,
      "mediaUrl3": media_url3,
      "likes" :{},
      "location" :widget.currentUser.cityName,
      "state" :"active",
      "productName" : productNameController.text,
      "price" : quatityController.text,
      "category":_currentCategory,
      "brandname":widget.currentUser.brandName,
      "phoneNumber":widget.currentUser.phoneNumber,
      "searchkeys":finalListKeys,
        });

    postsRefCat
        .document(widget.currentUser.cityName)
        .collection(_currentCategory)
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "description": descriptionController.text,
      "timestamp": timestamp,
      "mediaUrl1": media_url1,
      "mediaUrl2": media_url2,
      "mediaUrl3": media_url3,
      "likes" :{},
      "location" :widget.currentUser.cityName,
      "state" :"active",
      "productName" : productNameController.text,
      "price" : quatityController.text,
      "category":_currentCategory,
      "brandname":widget.currentUser.brandName,
      "phoneNumber":widget.currentUser.phoneNumber,
      "searchkeys":finalListKeys,
    });

    postsRefCat
        .document(widget.currentUser.cityName)
        .collection("MixCategory")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "description": descriptionController.text,
      "timestamp": timestamp,
      "mediaUrl1": media_url1,
      "mediaUrl2": media_url2,
      "mediaUrl3": media_url3,
      "likes" :{},
      "location" :widget.currentUser.cityName,
      "state" :"active",
      "productName" : productNameController.text,
      "price" : quatityController.text,
      "category":_currentCategory,
      "brandname":widget.currentUser.brandName,
      "phoneNumber":widget.currentUser.phoneNumber,
      "searchkeys":finalListKeys,
    });
  }
  Container buildSplashScreen() {
    return Container(
      color: yellow.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //SvgPicture.asset('assets/images/upload.svg', height: 260.0),

          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child:currentUser.state !="Active"? RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:Text(
                  "Your Account is Deactivated, Please contact support",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                color: Colors.deepOrange,
                onPressed: () {}):
            int.parse(currentUser.allowed)> _numberOfProduct ?RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:Text(
                  "Add product",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                color: Colors.deepOrange,
                onPressed: ()=> selectImage(context,false)):
            RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:Text(
                  "Product quota is over \nDelete old Product to Add new product",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                color: Colors.deepOrange,
                onPressed: (){}),
          ),
        ],
      ),
    );
  }

  void validateAndUpload() async{
    print("in Validate");
    if(_formKey.currentState.validate()){
      if(_image1 != null && _image2 != null && _image3 != null){
        setState(() {
          isUploading = true;
        });
          await compressImage();
          String mediaUrl1 = await uploadImage(_image1,"1");
          String mediaUrl2 = await uploadImage(_image2,"2");
          String mediaUrl3 = await uploadImage(_image3,"3");
          createPostInFirestore(
              media_url1:mediaUrl1,
              media_url2:mediaUrl2,
              media_url3:mediaUrl3
        );
        descriptionController.clear();
        productNameController.clear();
        quatityController.clear();
        _formKey.currentState.reset();

        setState(() {
          descriptionController.clear();
          productNameController.clear();
          quatityController.clear();
          _image1 = null;
          _image2 = null;
          _image3 = null;
          isUploading = false;
          postId = Uuid().v4();
          splashscreen = true;
        });

      }else{
        Fluttertoast.showToast(msg: 'all the images must be provided');
      }
    }
    else{
      Fluttertoast.showToast(msg: 'all the images must be provided 1');
    }
  }

  selectImage(BuildContext context,val) {
    setState(() {
      splashscreen = val;
      descriptionController.clear();
      productNameController.clear();
      quatityController.clear();
      _image1 = null;
      _image2 = null;
      _image3 = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}