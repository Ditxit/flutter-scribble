import 'package:draw/Game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeaderBoardScreen extends StatefulWidget {
  static const route = '/LeaderBoardScreen';

  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  final game = Game();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leader Board")
      ),
      body: StreamBuilder(
          stream: game.collection.doc(game.game).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return LinearProgressIndicator();
            }

            // Loading all players in memory first
            final players = snapshot.data['players'];

            // Mapping player data with player uuid
            final Map<String, Map> playerData = {};
            for (var player in players) {
              playerData[player['uuid']] = player;
            }

            return ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final uuid = players[index]['uuid'];
                final rank = "${index + 1}";
                final name = players[index]['name'];
                final points = players[index]['points'].fold(0, (a, b) => a + b);
                return ListTile(
                  leading: Text(rank),
                  title: Text(name),
                  trailing: Text("${points} POINTS"),
                );
              },
            );
          }),
    );
  }
}
