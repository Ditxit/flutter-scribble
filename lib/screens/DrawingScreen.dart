import 'dart:math';
import 'package:draw/DrawingPainter.dart';
import 'package:draw/Drawing.dart';
import 'package:draw/Game.dart';
import 'package:draw/screens/LandingScreen.dart';
import 'package:draw/screens/LeaderBoardScreen.dart';
import 'package:draw/screens/MessageScreen.dart';
import 'package:draw/screens/WordChoiceScreen.dart';
import 'package:draw/widgets/LinearCountDown.dart';
import 'package:flutter/material.dart';

class DrawingScreen extends StatefulWidget {
  static const route = '/DrawingScreen';

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final drawing = Drawing();
  final game = Game();

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
        } else if (snapshot['current']['uuid'] != game.uuid) {
          // Check if this player in no longer in turn.
          // This user is no longer in turn when the
          // time up callback changes the player turn in
          // fire store server.
          // If not in turn, navigate this player to
          // word choice page to continue the game further.
          Navigator.of(context).pushNamedAndRemoveUntil(
              WordChoiceScreen.route, (Route<dynamic> route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Future builder reads data once.
    // It is not like the stream builder where
    // on changing data in database, rebuilds the widgets again.
    // Instead future builder only builds data once with initial
    // data and do not track changes further.
    return FutureBuilder(
      future: game.currentGameDocument.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(
              child: CircularProgressIndicator(),
            ),
          );
          return LinearProgressIndicator();
        }

        final turnEndTime = snapshot.data['current']['upto'];
        return Scaffold(
          // these boolean values helps to
          // extend body behind the topAppBar and bottomNavBar
          extendBody: true, // for bottomNavBar
          extendBodyBehindAppBar: true, // for topAppBar

          body: GestureDetector(
            onPanDown: (details) {
              setState(() {
                drawing.add(details.globalPosition);
              });
            },
            onPanStart: (details) {
              setState(() {
                drawing.add(details.globalPosition);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                drawing.add(details.globalPosition);
              });
            },
            onPanEnd: (details) {
              drawing.add(null);
              game.draw(drawing.get());
            },
            onPanCancel: () {
              drawing.add(null);
              game.draw(drawing.get());
            },
            // TODO : fill color inside a contained stroke
            // onLongPress: (details) {},
            child: Center(
              child: CustomPaint(
                painter: DrawingPainter(drawing: drawing),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          ),

          bottomNavigationBar: Container(
            height: 62.0,
            child: Column(
              children: [
                LinearCountDown(
                  endTime: turnEndTime,
                  onComplete: () {
                    game.changePlayerTurn();
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
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: IconButton(
                                            icon: Icon(
                                                Icons.remove_circle_rounded),
                                            onPressed: () {
                                              setState(() {
                                                drawing.thickness *= 0.80;
                                              });
                                            },
                                          ),
                                          trailing: IconButton(
                                            icon:
                                                Icon(Icons.add_circle_rounded),
                                            onPressed: () {
                                              setState(() {
                                                drawing.thickness *= 1.20;
                                              });
                                            },
                                          ),
                                          title: Text(
                                            "${drawing.thickness}",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.format_paint_rounded),
                                          title: const Text('Change Color'),
                                          onTap: () {
                                            setState(() {
                                              drawing.color = Colors.primaries[
                                                  Random().nextInt(
                                                      Colors.primaries.length)];
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        const Divider(
                                          height: 10,
                                          thickness: 2,
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.undo_rounded),
                                          title:
                                              const Text('Clear Last Stroke'),
                                          subtitle: Text(
                                              'Removes only last stroke from canvas'),
                                          onTap: () {
                                            setState(() {
                                              drawing.undo(last: 1);
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: new Icon(
                                              Icons.layers_clear_rounded),
                                          title: new Text('Clear Canvas'),
                                          subtitle: Text(
                                              'Removes all the strokes from canvas'),
                                          onTap: () {
                                            setState(() {
                                              drawing.wipe();
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: new Icon(
                                              Icons.exit_to_app_rounded),
                                          title: new Text(
                                            'Leave Game',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            game.leave();
                                            //Navigator.pop(context);
                                            Navigator.pushNamed(
                                                context, LandingScreen.route);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
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
                            Navigator.pushNamed(
                                context, LeaderBoardScreen.route);
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
      },
    );
  }
}
