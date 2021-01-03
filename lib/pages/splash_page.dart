import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mazaghar/widgets/app_properties.dart';

import 'Home_sign_in.dart';
import 'intro_page.dart';

final DateTime timestamp = DateTime.now();

SharedPreferences prefs ;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> opacity;
  AnimationController controller;



  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward().then((_) {
      navigationPage();
    });

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void navigationPage() async {
    /*Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => WelcomeBackPage()));*/
    prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("splash"))
    {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => Home()));
    }
    else{
      prefs.setBool("splash", false);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => IntroPage()));
    }
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/background_white.png'), fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(color: transparentYellowIntro),
        child: SafeArea(
          child: new Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Opacity(
                      opacity: opacity.value,
                      child: new Image.asset('images/logo.png')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(text: 'Powered by '),
                          TextSpan(
                              text: 'MazaBappa',
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ]),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
