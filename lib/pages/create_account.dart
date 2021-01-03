import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mazaghar/widgets/header.dart';
import 'package:mazaghar/widgets/progress.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;
  String address;
  String cityName;
  String brandName;
  String phoneNumber;

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, [username,address,brandName,phoneNumber]);
      });
    }
  }



  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          titleText: "Set up your profile details", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create a username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          usernameField(),
                          addressField(),
                          //cityNameField(),
                          brandNameField(),
                          phoneNumberField(),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

   usernameField() {
    return Padding(
        padding: EdgeInsets.all(6.0),
        child: Container(
        child: TextFormField(
          validator: (val) {
            if (val.trim().length < 3 || val.isEmpty) {
              return "Username too short";
            } else if (val.trim().length > 12) {
              return "Username too long";
            } else {
              return null;
            }
          },
          onSaved: (val) => username = val,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Username",
            labelStyle: TextStyle(fontSize: 15.0),
            hintText: "Must be at least 3 characters",
          ),
        )
    ),
    );
  }
   addressField() {
     return Padding(
       padding: EdgeInsets.all(6.0),
       child: Container(
           child: TextFormField(
             validator: (val) {
               if (val.trim().length < 10 || val.isEmpty) {
                 return "Address too short";
               } else if (val.trim().length > 100) {
                 return "Address too long";
               } else {
                 return null;
               }
             },
             onSaved: (val) => address = val,
             decoration: InputDecoration(
               border: OutlineInputBorder(),
               labelText: "Address",
               labelStyle: TextStyle(fontSize: 15.0),
               hintText: "Must be at least 10 characters",
             ),
           )
       ),
     );
  }
   cityNameField() {
     return Padding(
       padding: EdgeInsets.all(6.0),
       child: Container(
           child: TextFormField(
             validator: (val) {
               if (val.trim().length < 3 || val.isEmpty) {
                 return "Username too short";
               } else if (val.trim().length > 12) {
                 return "Username too long";
               } else {
                 return null;
               }
             },
             onSaved: (val) => username = val,
             decoration: InputDecoration(
               border: OutlineInputBorder(),
               labelText: "Username",
               labelStyle: TextStyle(fontSize: 5.0),
               hintText: "Must be at least 3 characters",
             ),
           )
       ),
     );
  }
   brandNameField() {
     return Padding(
       padding: EdgeInsets.all(6.0),
       child: Container(
           child: TextFormField(
             validator: (val) {
               if (val.trim().length < 3 || val.isEmpty) {
                 return "Brand name too short";
               } else if (val.trim().length > 30) {
                 return "Brand name too long";
               } else {
                 return null;
               }
             },
             onSaved: (val) => brandName = val,
             decoration: InputDecoration(
               border: OutlineInputBorder(),
               labelText: "Brand name",
               labelStyle: TextStyle(fontSize: 15.0),
               hintText: "Must be at least 3 characters",
             ),
           )
       ),
     );
  }
   phoneNumberField() {
     return Padding(
       padding: EdgeInsets.all(6.0),
       child: Container(
           child: TextFormField(
             keyboardType: TextInputType.number,
             validator: (val) {
               if (val.trim().length < 10 || val.isEmpty) {
                 return "Phone Number too short";
               } else if (val.trim().length > 10) {
                 return "Phone Number too long";
               } else {
                 return null;
               }
             },
             onSaved: (val) => phoneNumber = val,
             decoration: InputDecoration(
               border: OutlineInputBorder(),

               labelText: "Mobile Number +91",
               labelStyle: TextStyle(fontSize: 15.0),
               hintText: "Must be at least 3 characters",
             ),
           )
       ),
     );}
}
