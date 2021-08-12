import 'package:draw/Game.dart';
import 'package:draw/screens/DrawingScreen.dart';
import 'package:draw/screens/DrawingViewingScreen.dart';
import 'package:flutter/material.dart';

class WordChoiceScreen extends StatefulWidget {
  static const route = '/WordChoiceScreen';

  @override
  _WordChoiceScreenState createState() => _WordChoiceScreenState();
}

class _WordChoiceScreenState extends State<WordChoiceScreen> {
  final game = Game();
  final words = Words.take(count: 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: game.collection.doc(game.game).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return Center(
                child: Container(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.indigo,
                  ),
                ),
              );
            }

            // Condition when current user chooses the
            // word to draw and the firebase gets updated
            if (snapshot.data['current']['word'] != null) {
              WidgetsBinding.instance.addPostFrameCallback((duration) => {
                    // Navigate according to the player turn,
                    // if current player has the turn, navigate to
                    // Drawing Screen else navigate to Drawing View Screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        snapshot.data['current']['uuid'] == game.uuid
                            ? DrawingScreen.route
                            : DrawingViewingScreen.route,
                        (Route<dynamic> route) => false),
                  });
            } // end if

            // getting the in-turn player name
            String nameOfPlayerInTurn;
            for (var player in snapshot.data['players']) {
              if (player['uuid'] == snapshot.data['current']['uuid']) {
                nameOfPlayerInTurn = player['name'];
                break;
              }
            }

            final bool isCurrentDevicePlayerTurn =
                snapshot.data['current']['uuid'] == game.uuid;

            if (isCurrentDevicePlayerTurn) {
              return Center(
                child: Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 32.0, bottom: 8.0, left: 32.0,),
                        child: FlatButton(
                          onPressed: () async {
                            await game.setChosenWord(
                                word: words[index].toUpperCase());
                          },
                          color: Colors.indigo,
                          height: 58.0,
                          child: Text(
                            "${words[index].toUpperCase()}",
                            style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: Container(
                  padding: EdgeInsets.only(left: 32.0, right: 32.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: nameOfPlayerInTurn.toUpperCase(),
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " IS CHOOSING WORD",
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

          }),
    );

  }
}
