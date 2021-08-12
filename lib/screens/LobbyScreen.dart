import 'package:draw/Game.dart'; // Dart language has a bug, so use relative path for singleton class imports
import 'package:draw/screens/DrawingScreen.dart';
import 'package:draw/screens/DrawingViewingScreen.dart';
import 'package:draw/screens/LandingScreen.dart';
import 'package:draw/screens/WordChoiceScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LobbyScreen extends StatefulWidget {
  static const route = '/LobbyScreen';

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  // The same game Singleton is created in Lobby also.
  Game game = Game();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: game.collection.doc(game.game).snapshots(),
        builder: (context, snapshot) {
          // If the snapshot is not ready to display data
          // return the progress indicator so that user have
          // some visual feedback all the time.
          if (snapshot.connectionState != ConnectionState.active) {
            return Scaffold(
              body: Center(
                child: Container(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.indigo,
                  ),
                ),
              ),
            );
          }

          // Get all the players list from the snapshot
          final players = snapshot.data['players'];

          // code to check whether the player is still in game
          // if not in the current game running in this lobby
          // navigate the user to the landing screen as he/she
          // should not be here.
          bool isPlayerInGame = false;

          for (var player in players) {
            if (player['uuid'] == game.uuid) isPlayerInGame = true;
          }

          // If player not in game, i.e. he/she got kicked out
          // so, should be navigated to Landing Screen from the Lobby
          if (!isPlayerInGame)
            WidgetsBinding.instance.addPostFrameCallback((duration) => {
                  game.reset().then(
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            LandingScreen.route,
                            (Route<dynamic> route) => false),
                      ),
                });

          // Condition when the game starts.
          if (snapshot.data['started'] == true) {
            WidgetsBinding.instance.addPostFrameCallback((duration) => {
                  // Navigate according to the player turn,
                  // if current player has first turn navigate to
                  // Drawing Screen else navigate to Drawing View Screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      WordChoiceScreen.route, (Route<dynamic> route) => false),
                });
          } // end if

          // If this device player is game creator
          final isThisDevicePlayerIsGameCreator =
              snapshot.data['creator'] == game.uuid;

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.indigo,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  game.leave().then(
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            LandingScreen.route,
                            (Route<dynamic> route) => false),
                      );
                },
              ),
              centerTitle: true,
              title: Text(game.game),
              actions: [
                IconButton(
                  icon: Icon(Icons.content_copy_rounded),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: "${game.game}"));
                  },
                ),
              ],
            ),
            body: Container(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  // if the player data current index is of this device player
                  final isDevicePlayerCurrentIndexPlayer =
                      players[index]['uuid'] == game.uuid;
                  final isThisIndexPlayerIsGameCreator =
                      snapshot.data['creator'] == players[index]['uuid'];

                  // check_circle_outline_rounded
                  return ListTile(
                    title: Text(
                      players[index]['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDevicePlayerCurrentIndexPlayer
                            ? Colors.pink
                            : Colors.black,
                      ),
                    ),
                    trailing: isThisDevicePlayerIsGameCreator &&
                            !isDevicePlayerCurrentIndexPlayer
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              // delete user
                              game.remove(players[index]['uuid']);
                            })
                        : isThisIndexPlayerIsGameCreator
                            ? TextButton(
                                onPressed: null, child: Text("CREATOR"))
                            : SizedBox(),
                  );
                },
              ),
            ),
            bottomNavigationBar:
                players.length < 2 || !isThisDevicePlayerIsGameCreator
                    ? SizedBox()
                    : Container(
                        height: 58,
                        color: Colors.white,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await game.start();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  color: Colors.indigo,
                                  child: Text(
                                      "START GAME - ${players.length} PLAYERS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          );
        });
  }
}
