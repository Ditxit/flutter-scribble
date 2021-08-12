import 'package:draw/Game.dart'; // Dart language has a bug, so use relative path for singleton class imports
import 'package:draw/screens/LobbyScreen.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  static const route = '/LandingScreen';

  //Color(0xff102b46);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Game game = Game();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: TextFormField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.name,
          initialValue: game.name,
          onChanged: (String value) {
            game.name = value;
          },
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
          cursorColor: Colors.pink,
          decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "Enter Player Name"),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Container(
            child: FlutterLogo(
              size: 120,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 58,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  game.create();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      LobbyScreen.route, (Route<dynamic> route) => false);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.pink,
                  child: Text("CREATE GAME",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showSearch(context: context, delegate: DataSearch());
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.green,
                  child: Text("JOIN GAME",
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
  }
}

class DataSearch extends SearchDelegate<String> {
  List<String> history = [];
  Game game = Game();

  DataSearch()
      : super(
          searchFieldLabel: 'Game Code',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for app bar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // flutter default on-tap event widget returned
    // we are not using this method, instead navigating
    // the user to the game lobby of respective game.
    return SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().length != 5)
      return Center(
        child: Container(
          child: Text("Enter Game Code"),
        ),
      );

    return StreamBuilder(
        stream: game.collection.doc(query).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          //if (snapshot.data['creator'] == null) return Text("Error");

          return ListTile(
            title: Text(query),
            subtitle: Text("Tap to join"),
            onTap: () async {
              await game.join(query);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  LobbyScreen.route, (Route<dynamic> route) => false);
            },
          );
        });
  }
}
