import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mazaghar/pages/Home_sign_in.dart';
import 'package:mazaghar/pages/splash_page.dart';
import 'package:mazaghar/widgets/app_properties.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    // print("Timestamps enabled in snapshots\n");
  }, onError: (_) {
    // print("Error enabling timestamps in snapshots\n");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connekt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: yellow.withOpacity(0.8),
      ),
      home: SplashScreen(),
    );
  }
}
