import 'package:draw/Game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  static const route = '/MessageScreen';

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final game = Game();

  final messageTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          autofocus: true,
          controller: messageTextEditingController,
          keyboardType: TextInputType.name,
          onFieldSubmitted: (String value) async {
            final text = value.trim();
            if (text.length > 0) {
              //await game.addGuessMessage(text: text);
              await game.addGuessMessageNew(text: text);
              messageTextEditingController.clear();
            }
          },
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
          cursorColor: Colors.indigo[100],
          decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.indigo[100]),
              hintText: "Type your guess"),
        ),
      ),
      body: StreamBuilder(
          stream: game.collection.doc(game.game).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return LinearProgressIndicator();
            }

            if (snapshot.data['guesses'] == null) {
              return SizedBox();
            }

            // Loading messages in the memory first in reverse order
            final guesses = snapshot.data['guesses'].reversed.toList();

            // If it is turn of the current device player,
            final thisIsTurnOfCurrentDevicePlayer =
                snapshot.data['current']['uuid'] == game.uuid;

            // If it is not the turn of the current device player,
            // remove all the correct guesses made by other players.
            if (!thisIsTurnOfCurrentDevicePlayer) {
              guesses.removeWhere(
                  (guess) => guess['uuid'] != game.uuid && guess['is_correct']);
            }

            // Setting the width of chat bubble
            final chatBubbleWidth = MediaQuery.of(context).size.width * 0.7;

            // All players points list
            final Map<String, Map> playerData = {};
            for (var player in snapshot.data['players']) {
              playerData[player['uuid']] = player;
            }

            return ListView.builder(
              itemCount: guesses.length,
              itemBuilder: (context, index) {
                final currentIndexMessagePlayerUUID = guesses[index]['uuid'];

                // Whether current index message belongs to
                // this device player or not
                final isThisMessageSentByCurrentDevicePlayer =
                    currentIndexMessagePlayerUUID == game.uuid;

                // This index message is correct message
                final isCorrectMessage = guesses[index]['is_correct'];

                // Is next message from same player ?
                final isNextMessageFromSamePlayer =
                    (guesses.length - 1 > index) &&
                        (currentIndexMessagePlayerUUID ==
                            guesses[index + 1]['uuid']);

                return Container(
                  margin: const EdgeInsets.only(
                    top: 8.0,
                    left: 8.0,
                    bottom: 0.0,
                    right: 8.0,
                  ),
                  width: chatBubbleWidth,
                  child: Column(
                    children: [
                      Align(
                        alignment: isThisMessageSentByCurrentDevicePlayer
                            ? Alignment.bottomLeft
                            : Alignment.bottomRight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          child: Container(
                            width: chatBubbleWidth,
                            child: Column(
                              children: [
                                // UI for each message header part.
                                // If message is correct show it, otherwise don't.
                                isCorrectMessage
                                    ? Container(
                                        padding: const EdgeInsets.all(16.0),
                                        width: double.maxFinite,
                                        color:
                                            isThisMessageSentByCurrentDevicePlayer
                                                ? Colors.green[800]
                                                : Colors.grey[400],
                                        child: Text(
                                          "+${guesses[index]['point']}, TOTAL ${playerData[currentIndexMessagePlayerUUID]['points'].fold(0, (a, b) => a + b)} POINTS",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                isThisMessageSentByCurrentDevicePlayer
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),

                                // For actual message text part.
                                // Since, correct messages are already filtered out
                                // for non-turn user, so we can show all messages.
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  width: chatBubbleWidth,
                                  color: isThisMessageSentByCurrentDevicePlayer
                                      ? Colors.green[600]
                                      : Colors.grey[300],
                                  child: SelectableText(
                                    guesses[index]['text'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color:
                                          isThisMessageSentByCurrentDevicePlayer
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // UI for showing the user who sent this message
                      isNextMessageFromSamePlayer
                          ? SizedBox()
                          : Align(
                              alignment: isThisMessageSentByCurrentDevicePlayer
                                  ? Alignment.bottomLeft
                                  : Alignment.bottomRight,
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 4.0,
                                  bottom: 16.0,
                                  left: 4.0,
                                  right: 4.0,
                                ),
                                child: Text(
                                  playerData[currentIndexMessagePlayerUUID]
                                      ['name'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
