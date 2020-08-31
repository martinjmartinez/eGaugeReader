import 'package:flutter/material.dart';
import 'package:peta_app/Utils/Database.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'Pages/HomePage.dart';

void main() {
  SyncfusionLicense.registerLicense("NT8mJyc2IWhia31hfWN9ZmdoYmF8YGJ8ampqanNiYmlmamlmanMDHmg+MiEnOj05PjIhJzo9NikwISYpEzQ+Mjo/fTA8Pg==");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peta Demo',
      theme: ThemeData(
        backgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Dashboard'),
    );
  }
}




