import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LinearCountDown extends StatefulWidget {

  final int endTime; // millisecondsSinceEpoch
  final Function onComplete;

  const LinearCountDown({ Key key, this.endTime, this.onComplete })
      : super(key: key);

  @override
  _LinearCountDownState createState() => _LinearCountDownState();

}

class _LinearCountDownState extends State<LinearCountDown> {

  Duration tickDuration; // hold the duration to tick the clock
  int currentTime; // holds the current time in millisecond
  int startTime; // holds the start time in millisecond
  int endTime; // holds the end time in millisecond
  Function onComplete; // holds the function to execute on time up

  Timer timer;

  @override
  void initState() {
    super.initState();

    tickDuration =  Duration(seconds: 1); // checking every millisecond
    startTime = DateTime.now().millisecondsSinceEpoch;
    currentTime = startTime;
    endTime = widget.endTime;
    onComplete = widget.onComplete;

    timer = Timer.periodic(
        tickDuration,
            (Timer timer) {
          if (endTime > currentTime) {
            setState(() {
              currentTime = DateTime.now().millisecondsSinceEpoch;
            });
          }else {
            setState(() {
              timer.cancel();
            });
            onComplete();
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    //return Text("${((endTime - currentTime) / 1000).round()}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0,),);
    final progress = 1.0 - (endTime - currentTime) / (endTime - startTime);
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

}