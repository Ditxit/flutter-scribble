import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw/utilities/WordHint.dart';
import 'package:nanoid/generate.dart';

class Words {
  // This function returns a list of n random
  // words to choose for the game.
  static List<String> take({int count = 3}) {
    final words = [
      "America",
      "Balloon",
      "Biscuit",
      "Blanket",
      "Chicken",
      "Chimney",
      "Country",
      "Cupcake",
      "Curtain",
      "Diamond",
      "Eyebrow",
      "Fireman",
      "Husband",
      "Morning",
      "Octopus",
      "Popcorn",
      "Printer",
      "Sandbox",
      "Skyline",
      "Spinach",
      "Backpack",
      "Basement",
      "Building",
      "Campfire",
      "Complete",
      "Elephant",
      "Exercise",
      "Hospital",
      "Internet",
      "Mosquito",
      "Sandwich",
      "Scissors",
      "Seahorse",
      "Skeleton",
      "Snowball",
      "Treasure",
      "Blueberry",
      "Breakfast",
      "Bubblegum",
      "Cellphone",
      "Hairbrush",
      "Hamburger",
      "Jellyfish",
      "Landscape",
      "Nightmare",
      "Pensioner",
      "Rectangle",
      "Snowboard",
      "Spaceship",
      "Spongebob",
      "Swordfish",
      "Telephone",
      "Telescope",
      "Broomstick",
      "Commercial",
      "Flashlight",
      "Lighthouse",
      "Microphone",
      "Photograph",
      "Skyscraper",
      "Strawberry",
      "Sunglasses",
      "Toothbrush",
      "Toothpaste",
    ];
    words.shuffle();
    return words.getRange(0, count).toList();
  }
}

enum GameState {
  NOT_JOINED_TO_GAME, // not joined in any game whatsoever
  WAITING_TO_START, // room joined but waiting to play
  PLAYING_NOW, // user is playing game now
  PLAYING_AND_TURN, // if game is started and its my turn
  CALCULATING_SCORE, // game ended recently
  GOT_KICKED_OUT, // got kicked out of a game
}

// Singleton Class
class Game {
  // Holds the game state
  GameState state;

  // The "game" holds the document
  // name of the game in firebase
  String game;

  // The uuid is unique user
  // id of local player.
  String uuid;

  // The "name" holds the
  // name of local player
  String name;

  // the 'gameCollection' object holds the
  // instance of 'game' collections
  CollectionReference collection;

  // the "currentGameDocument" stores the current game document
  // instance of the from firebase
  DocumentReference currentGameDocument;

  // Preparing For Singleton Constructor
  static final Game _singleton = new Game._privateConstructor();

  Game._privateConstructor() {
    this.state = GameState.NOT_JOINED_TO_GAME;
    this.game = generate('0123456789', 5);
    this.uuid = generate('abcdefghijklmnopqrstuvwxyz0123456789', 10);
    this.name = "PLAYER ${generate('0123456789', 3)}";
    this.collection = FirebaseFirestore.instance.collection('games');
    this.currentGameDocument = null;
  }

  // Returning same singleton using
  // factory for this class
  factory Game() {
    // Return the rest of object as it is
    return _singleton;
  }

  // This function helps to
  // reset the game to the initial state
  reset() {
    _singleton.currentGameDocument = null;
    _singleton.game = generate('0123456789', 5);
    _singleton.state = GameState.NOT_JOINED_TO_GAME;
  }

  // This method creates new
  // game in firebase when called
  Future<void> create() async {
    // if user already in a game - return
    if (_singleton.isRunning()) return;

    await _singleton.collection.doc(_singleton.game).set({
      // holds how many seconds for single word
      'drawing_time': 100, // seconds
      'word_choosing_time': 20, // seconds
      'total_rounds': 5, // total rounds in game
      'current_round': 0, // current round in this game : 0

      // holds the drawing data
      'drawing': [],

      // holds the uuid of player who created the game
      'creator': _singleton.uuid,

      // holds the game created timestamp
      'created': DateTime.now().millisecondsSinceEpoch,

      // holds the game started status
      'started': false,

      // holds the game ended status
      // if it is true, we need to show
      // final score screen to players
      'ended': false,

      // Holds the players map who are playing the game
      'players': [
        {
          'uuid': _singleton.uuid, // user unique  id
          'name': _singleton.name, // user name
          'points': [], // user points in each guess
        },
      ],

      // holds the uuid of players who
      // are blocked to join the game
      'blocked': [],

      // holds the uuid of player who is allowed to draw
      'current': {
        'uuid': null, // holds the player with turn
        'word': null, // holds the word to guess by other player
        'hint': null, // holds the word hint string
        'upto': null, // holds the ending time of player turn
      },

      // holds the user name, uuid,
      // message and score associated
      // with each message.
      // if score is not null, the guess
      // is correct.
      'guesses': [],
    });

    // Finally join the self created game.
    await _singleton.join(_singleton.game);
  }

  // This function starts the game
  Future<void> start() async {
    DocumentSnapshot documentSnapshot =
        await _singleton.currentGameDocument.get();

    if (documentSnapshot.exists) {
      final game = documentSnapshot.data();

      // Return without starting if current
      // player is not the creator of this game
      if (game['creator'] != _singleton.uuid) return;

      // There is not enough player to start the game
      if (game['players'].length < 2) return;

      final players = game['players']..shuffle();
      final current = {
        'uuid': players.first['uuid'],
        'word': null,
        'hint': null,
        'upto': null,
      };

      await _singleton.currentGameDocument.update({
        'started': true,
        'ended': false,
        'current_round': 1, // when game starts the current round is always 1
        'players': players,
        'blocked': [],
        'current': current,
      });

      // Changing game state to started
      _singleton.state = current['uuid'] == _singleton.uuid
          ? GameState.PLAYING_AND_TURN
          : GameState.PLAYING_NOW;
    }
  }

  // TODO: Add Hints List
  // Function used by the "IN TURN" user
  // to set the chosen word in the firebase
  Future<void> setChosenWord({String word}) async {
    DocumentSnapshot documentSnapshot =
        await _singleton.currentGameDocument.get();

    if (documentSnapshot.exists) {
      final game = documentSnapshot.data();

      // Return without updating if its not
      // current player turn in the game
      if (game['current']['uuid'] != _singleton.uuid) return;

      final current = {
        'uuid': game['current']['uuid'],
        'word': word,
        'hint': WordHint.generate(word),
        'upto': DateTime.now().millisecondsSinceEpoch +
            (game['drawing_time'] * 1000),
      };

      await _singleton.currentGameDocument.update({
        'current': current,
      });
    }
  }

  // TODO: Add feedback if the guess was pretty close.
  Future<void> addGuessMessageNew({String text}) async {
    // DOING IN TRANSACTION
    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          // READ PART
          DocumentSnapshot snapshot =
              await transaction.get(_singleton.currentGameDocument);

          // LOGIC PART
          if (!snapshot.exists) {
            throw Exception("Exception: Snapshot does not exist");
          }

          // Check if this current guess message is
          // the correct guess.
          final isCurrentGuessMessageIsCorrectGuess =
              snapshot['current']['word'].trim().toUpperCase() ==
                  text.trim().toUpperCase();

          // If its turn of this device player and makes the correct guess
          // it is false play from this player. So, we return without
          // saving the message to database.
          if (snapshot['current']['uuid'] == _singleton.uuid &&
              isCurrentGuessMessageIsCorrectGuess) return;

          // Checking if the user has already
          // made the correct guess in this turn
          bool hasAlreadyMadeCorrectGuess = false;
          for (var guess in snapshot['guesses']) {
            // Looking for guess message which is
            // correct among every guess messages
            // by sent by this user previously.
            if (guess['uuid'] == _singleton.uuid && guess['is_correct']) {
              hasAlreadyMadeCorrectGuess = true;
              break;
            }
          }

          // Keeping all players data into memory
          var players = snapshot['players'];

          // initially the guess point is 0
          var point = 0;

          // If user has not already made correct guess
          // in this turn and if current message is correct answer,
          // we should increase the player point according
          // to the time difference.
          if (isCurrentGuessMessageIsCorrectGuess &&
              !hasAlreadyMadeCorrectGuess) {
            for (int i = 0; i < players.length; i++) {
              if (players[i]['uuid'] == _singleton.uuid) {
                point = snapshot['current']['upto'] -
                    DateTime.now().millisecondsSinceEpoch;
                point = point > 0 ? (point / 1000).round() : 0;
                if (point > 0) {
                  players[i]['points'].add(point);
                }
                break;
              }
            }
          }

          // Prepare the new guess map object
          final guess = {
            'uuid': _singleton.uuid,
            'text': text,
            'is_correct': isCurrentGuessMessageIsCorrectGuess,
            'point': point,
          };

          final guesses = List.from(snapshot['guesses'])..addAll([guess]);

          // COMMIT PART
          transaction.update(_singleton.currentGameDocument, {
            'players': players,
            'guesses': guesses,
          });

          // POST TRANSACTION PART
          // Change the turn if all the guessers
          // made the correct guesses so that game will not
          // wait unnecessarily until time's up
          if (isCurrentGuessMessageIsCorrectGuess &&
              !hasAlreadyMadeCorrectGuess) {
            final correctGuessersUUIDs = Set();
            for (var guess in guesses) {
              correctGuessersUUIDs.add(guess['uuid']);
            }
            if (correctGuessersUUIDs.length == players.length - 1) {
              // how many seconds to
              // wait before changing turn ?
              final seconds = 3;

              // What is the time threshold
              final threshold =
                  DateTime.now().millisecondsSinceEpoch + (seconds * 2 * 1000);

              if (snapshot['current']['upto'] > threshold) {
                Future.delayed(Duration(seconds: seconds), () async {
                  await _singleton.changePlayerTurn();
                });
              }
            }
          }
        })
        .then((value) => print("Guess message added : $value"))
        .catchError((error) => print("Failed to add guess message : $error"));
  }

  // TODO: Optimize this function when mind is fresh
  // This function helps the players in game
  // to add guess message in the chat list
  Future<void> addGuessMessage({String text}) async {
    DocumentSnapshot documentSnapshot =
        await _singleton.currentGameDocument.get();

    if (documentSnapshot.exists) {
      final game = documentSnapshot.data();

      // Check if this current guess message is
      // the correct guess.
      final isCurrentGuessMessageIsCorrectGuess =
          game['current']['word'].trim().toUpperCase() ==
              text.trim().toUpperCase();

      // If its turn of this device player and makes the correct guess
      // it is false play from this player. So, we return without
      // saving the message to database.
      if (game['current']['uuid'] == _singleton.uuid &&
          isCurrentGuessMessageIsCorrectGuess) return;

      // Checking if the user has already
      // made the correct guess in this turn
      bool hasAlreadyMadeCorrectGuess = false;
      for (var guess in game['guesses']) {
        // Looking for guess message which is
        // correct among every guess messages
        // by sent by this user previously.
        if (guess['uuid'] == _singleton.uuid && guess['is_correct']) {
          hasAlreadyMadeCorrectGuess = true;
          break;
        }
      }

      // Keeping all players data into memory
      var players = game['players'];

      // initially the guess point is 0
      var point = 0;

      // If user has not already made correct guess
      // in this turn and if current message is correct answer,
      // we should increase the player point according
      // to the time difference.
      if (isCurrentGuessMessageIsCorrectGuess && !hasAlreadyMadeCorrectGuess) {
        for (int i = 0; i < players.length; i++) {
          if (players[i]['uuid'] == _singleton.uuid) {
            point =
                game['current']['upto'] - DateTime.now().millisecondsSinceEpoch;
            point = point > 0 ? (point / 1000).round() : 0;
            if (point > 0) {
              players[i]['points'].add(point);
            }
            break;
          }
        }
      }

      // Prepare the new guess map object
      final guess = {
        'uuid': _singleton.uuid,
        'text': text,
        // 'time': DateTime.now().millisecondsSinceEpoch,
        'is_correct': isCurrentGuessMessageIsCorrectGuess,
        'point': point,
      };

      final guesses = List.from(game['guesses'])..addAll([guess]);

      await _singleton.currentGameDocument.update({
        'players': players,
        'guesses': guesses,
      });

      // Change the turn if all the guessers
      // made the correct guesses so that game will not
      // wait unnecessarily until time's up
      if (isCurrentGuessMessageIsCorrectGuess && !hasAlreadyMadeCorrectGuess) {
        final correctGuessersUUIDs = Set();
        for (var guess in guesses) {
          correctGuessersUUIDs.add(guess['uuid']);
        }
        if (correctGuessersUUIDs.length == players.length - 1) {
          // how many seconds to
          // wait before changing turn ?
          final seconds = 3;

          // What is the time threshold
          final threshold =
              DateTime.now().millisecondsSinceEpoch + (seconds * 2 * 1000);

          if (game['current']['upto'] > threshold) {
            Future.delayed(Duration(seconds: seconds), () async {
              await _singleton.changePlayerTurn();
            });
          }
        }
      }
    }
  }

  /*
  1. ✔ It changes the turn of player in the game.
  2. ✔ It increase the game round if a round completes.
  3. ✔ It ends the game if all the round is completed.
  4. ❌ TODO: Optimize this method a little in fresh mind.
  */
  Future<void> changePlayerTurn() async {
    DocumentSnapshot documentSnapshot =
        await _singleton.currentGameDocument.get();

    if (documentSnapshot.exists) {
      final game = documentSnapshot.data();
      final currentPlayerUUID = game['current']['uuid'];

      // Validation for, correct user changing the turn
      // if (currentPlayerUUID != _singleton.uuid) return;

      final players = game['players'];

      var nextPlayerUUID;
      for (int i = 0; i < players.length; i++) {
        if (players[i]['uuid'] == currentPlayerUUID) {
          final isCurrentPlayerLastInList =
              players[i]['uuid'] == players.last['uuid'];
          nextPlayerUUID = isCurrentPlayerLastInList
              ? players.first['uuid']
              : players[i + 1]['uuid'];
        }
      }

      // Increase round if the next player is
      // first player in the player list.
      final int currentRound = (nextPlayerUUID == players.first['uuid'])
          ? game['current_round'] + 1
          : game['current_round'];

      // If the current round exceeds the total round
      // to be played, the game is officially complete.
      // so, end game and return void in the function.
      if (currentRound > game['total_rounds']) {
        await _singleton.end(); // end game as the all round is played;
        return;
      }

      // Creating new  current turn
      // data to update database
      final current = {
        'uuid': nextPlayerUUID,
        'word': null,
        'hint': null,
        'upto': null,
      };

      await _singleton.currentGameDocument.update({
        'current_round': currentRound,
        'drawing': [], // remove the drawing
        'current': current, // change turn
        'guesses': [], // clear guesses
      });
    }
  }

  // End method ends the game.
  // it does not deletes the game.
  // When ended, users are presented with
  // final score and presented with 2 option;
  // either to rejoin lobby or leave game
  Future<void> end() async {
    DocumentSnapshot documentSnapshot =
        await _singleton.currentGameDocument.get();

    if (documentSnapshot.exists) {
      final current = {
        'uuid': null,
        'word': null,
        'hint': null,
        'upto': null,
      };

      await _singleton.currentGameDocument.update({
        'started': false,
        'ended': true,
        'current_round': 0, // when game ends the current round is always 0
        'current': current,
        'guesses': [],
      });
    }
  }

  leave() {
    // if user not in any game, return
    if (!_singleton.isRunning()) return;

    // else prepare to remove user from the game
    _singleton.currentGameDocument
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      final game = documentSnapshot.data();
      String creator = game['creator'];
      final players = game['players'];

      // Check if current game have
      // more than 1 user
      if (players.length > 1) {
        // remove current from the players list
        players.removeWhere((player) => player['uuid'] == _singleton.uuid);

        // if current player was the creator,
        // transfer the creator ship to another player
        if (creator == _singleton.uuid) {
          creator = players[0]['uuid'];
        }

        // finally, update the database
        _singleton.currentGameDocument.update({
          'creator': creator,
          'players': players,
        });
      } else {
        // if no more players will be left,
        // deleting the game is a better option
        _singleton.currentGameDocument.delete();
      }

      // reset the game for
      // this user so that they
      // will be eligible to play new
      // game again now
      _singleton.reset();
    });
  }

  draw(List drawing) {
    // does the currentGameDocument has data ?
    // is it this player turn in the game ? (look at the current key)
    // update the

    _singleton.currentGameDocument.update({
      'drawing': drawing,
    });
  }

  Future<void> join(String game) async {
    // Change the game name
    // _singleton.game = game;

    DocumentSnapshot documentSnapshot =
        await _singleton.collection.doc(game).get();

    if (documentSnapshot.exists) {
      final players = documentSnapshot.data()['players'];

      // initially, we suppose that
      // evey player is not joined yet.
      bool isNewPlayer = true;

      for (var player in players) {
        if (player['uuid'] == _singleton.uuid) {
          isNewPlayer = false;
          break;
        }
      }

      // If this is new player in this game
      if (isNewPlayer) {
        // Add new player data
        // to the list
        players.add({
          'uuid': _singleton.uuid,
          'name': _singleton.name,
          'points': [],
        });

        // Add the updated the data in db
        await _singleton.collection.doc(game).update({
          'players': players,
        });

        // Change the game name
        _singleton.game = game;
      }

      // mark the player is playing the game now
      _singleton.currentGameDocument = _singleton.collection.doc(game);

      // Changing the game state to waiting
      _singleton.state = GameState.WAITING_TO_START;
    }
  }

  // function to remove user
  // from the game temporarily
  remove(String uuid) {
    if (!_singleton.isRunning()) return;
    // TODO: check if the remover is game creator or not
    _singleton.currentGameDocument
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      final game = documentSnapshot.data();
      final creator = game['creator'];

      if (_singleton.uuid == creator) {
        final players = game['players'];
        players.removeWhere((player) => player['uuid'] == uuid);
        _singleton.currentGameDocument.update({
          'players': players,
        });
      }
    });
  }

  // function to remove user
  // from the game permanently
  block(String uuid) {
    // TODO: add block method to block player from joining the game again
  }

  // bool isRunning () {
  //   return _singleton.currentGameDocument != null;
  // }

  bool isRunning() => [GameState.WAITING_TO_START, GameState.PLAYING_NOW]
      .contains(_singleton.state);

  void printTest(String text) {
    print(text);
  }
}
