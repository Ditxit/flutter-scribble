import 'package:draw/screens/DrawingScreen.dart';
import 'package:draw/screens/DrawingViewingScreen.dart';
import 'package:draw/screens/LandingScreen.dart';
import 'package:draw/screens/LeaderBoardScreen.dart';
import 'package:draw/screens/LobbyScreen.dart';
import 'package:draw/screens/MessageScreen.dart';
import 'package:draw/screens/ScreenController.dart';
import 'package:draw/screens/WordChoiceScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribble',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: AppBarTheme(elevation: 0.0),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: LandingScreen.route,
      routes: {
        ScreenController.route: (context) => new ScreenController(),
        LandingScreen.route: (context) => new LandingScreen(),
        LobbyScreen.route: (context) => new LobbyScreen(),
        DrawingScreen.route: (context) => new DrawingScreen(),
        DrawingViewingScreen.route: (context) => new DrawingViewingScreen(),
        WordChoiceScreen.route: (context) => new WordChoiceScreen(),
        MessageScreen.route: (context) => new MessageScreen(),
        LeaderBoardScreen.route: (context) => new LeaderBoardScreen(),
      },
    );
  }
}
