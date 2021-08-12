import 'package:draw/Game.dart';
import 'package:draw/screens/DrawingScreen.dart';
import 'package:draw/screens/DrawingViewingScreen.dart';
import 'package:draw/screens/LandingScreen.dart';
import 'package:draw/screens/LobbyScreen.dart';
import 'package:flutter/material.dart';

class ScreenController extends StatefulWidget {

  static const route = '/ScreenController';

  @override
  _ScreenControllerState createState() => _ScreenControllerState();

}

class _ScreenControllerState extends State<ScreenController> {

  final game = Game();

  @override
  Widget build(BuildContext context) {

    switch(game.state){
      case GameState.NOT_JOINED_TO_GAME : {
        return LandingScreen();
      }
      break;

      case GameState.CALCULATING_SCORE: // TODO: CREATE CALCULATING SCORE SCREEN
      case GameState.GOT_KICKED_OUT: // TODO: CREATE GOT KICKED OUT SCREEN
      case GameState.WAITING_TO_START : {
        return LobbyScreen();
      }
      break;

      case GameState.PLAYING_NOW : {
        return DrawingViewingScreen();
      }
      break;

      case GameState.PLAYING_AND_TURN : {
        return DrawingScreen();
      }
      break;

      default : {
        return LandingScreen();
      }
      break;
    } // switch

  } // build

} // class