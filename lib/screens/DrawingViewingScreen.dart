import 'package:draw/DrawingPainter.dart';
import 'package:draw/Drawing.dart';
import 'package:draw/Game.dart';
import 'package:draw/screens/LandingScreen.dart';
import 'package:draw/screens/LeaderBoardScreen.dart';
import 'package:draw/screens/MessageScreen.dart';
import 'package:draw/screens/WordChoiceScreen.dart';
import 'package:draw/widgets/LinearCountDown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class DrawingViewingScreen extends StatefulWidget {
  static const route = '/DrawingViewingScreen';

  @override
  _DrawingViewingScreenState createState() => _DrawingViewingScreenState();
}

class _DrawingViewingScreenState extends State<DrawingViewingScreen> {
  // Record of all the touch events coordinates
  final drawing = Drawing();

  final game = Game();

  // TODO: Use Future Builder in the entire scaffold
  // TODO: Keep using the listener to change the drawing.

  Future<void> vibrate(int second) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(
        duration: second,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // This event looks for the change in data of this game in database,
    // and updated the drawing screen if data is updated by the drawer.
    game.currentGameDocument.snapshots().listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        // keeping game data in memory
        final snapshot = documentSnapshot.data();

        if (snapshot['ended']) {
          // if game ended, navigate users to
          // landing page currently
          Navigator.of(context).pushNamedAndRemoveUntil(
              LandingScreen.route, (Route<dynamic> route) => false);
        } else if (snapshot['current']['word'] == null) {
          // Check if the current turn have word.
          // If no word is present that its turn of next
          // player. so Navigate to WordChoiceScreen.
          // If not in turn, navigate this player to
          // word choice page to continue the game further.
          Navigator.of(context).pushNamedAndRemoveUntil(
              WordChoiceScreen.route, (Route<dynamic> route) => false);
        } else {
          // Show the current updated
          // drawing in the canvas
          setState(() {
            drawing.set(snapshot['drawing']);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "W _ _ _  H _ _ _",
          style: TextStyle(
            color: Colors.black,
            shadows: [
              Shadow(
                  // bottomLeft
                  offset: Offset(-2, -2),
                  color: Colors.white),
              Shadow(
                  // bottomRight
                  offset: Offset(2, -2),
                  color: Colors.white),
              Shadow(
                  // topRight
                  offset: Offset(2, 2),
                  color: Colors.white),
              Shadow(
                  // topLeft
                  offset: Offset(-2, 2),
                  color: Colors.white),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: CustomPaint(
          painter: DrawingPainter(drawing: drawing),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 62.0,
        child: Column(
          children: [
            FutureBuilder(
              future: game.currentGameDocument.get(),
              builder: (context, snapshot) {
                return Expanded(
                  child: snapshot.hasData
                      ? LinearCountDown(
                          endTime: snapshot.data['current']['upto'],
                          onComplete: () {
                            /* Do nothing */
                          },
                        )
                      : SizedBox(),
                );
              },
            ),
            Container(
              height: 58.0,
              color: Colors.indigo,
              child: Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      height: double.maxFinite,
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      height: double.maxFinite,
                      child: Icon(
                        Icons.chat,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, MessageScreen.route);
                      },
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      height: double.maxFinite,
                      child: Icon(
                        Icons.leaderboard,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, LeaderBoardScreen.route);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
