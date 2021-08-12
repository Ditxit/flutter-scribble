// import 'package:draw/DrawingPainter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:vibration/vibration.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   // Record of all the touch events coordinates
//   final _offsets = <Offset>[];
//
//   // User options list
//   double _brushThickness = 10.0;
//   Color _paintColor = Colors.black;
//
//   Future<void> vibrate(int second) async {
//     if (await Vibration.hasVibrator()) {
//       Vibration.vibrate(
//         duration: second,
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     SystemChrome.setEnabledSystemUIOverlays([]);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GestureDetector(
//         onDoubleTap: () {
//           setState(() {
//             _offsets.clear();
//             vibrate(50);
//           });
//         },
//         onPanDown: (details) {
//           setState(() {
//             _offsets.add(details.globalPosition);
//           });
//         },
//         onPanStart: (details) {
//           setState(() {
//             _offsets.add(details.globalPosition);
//           });
//         },
//         onPanUpdate: (details) {
//           setState(() {
//             _offsets.add(details.globalPosition);
//           });
//         },
//         onPanCancel: () {
//           if (_offsets.last != null) {
//             setState(() => {_offsets.add(null)});
//           }
//         },
//         onPanEnd: (details) {
//           if (_offsets.last != null) {
//             setState(() => {_offsets.add(null)});
//           }
//         },
//         onLongPress: () {
//           vibrate(50);
//           showModalBottomSheet(
//               context: context,
//               builder: (context) {
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     ListTile(
//                       title: Row(
//                         children: <Widget>[
//                           SizedBox(
//                             width: 48.0,
//                             height: 48.0,
//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(48.0),
//                                   color: Colors.red,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     ListTile(
//                       title: Slider(
//                         value: _brushThickness,
//                         onChanged: (newValue) {
//                           setState(() => _brushThickness = newValue);
//                         },
//                         max: 30.0,
//                         divisions: 3,
//                         //label: "${_brushThickness.floor()}",
//                       ),
//                     ),
//                     const Divider(
//                       height: 10,
//                       thickness: 2,
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.undo_rounded),
//                       title: const Text('Clear Last Stroke'),
//                       subtitle: Text('Removes last stroke from the canvas.'),
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     ListTile(
//                       leading: new Icon(Icons.layers_clear_rounded),
//                       title: new Text('Clear Canvas'),
//                       subtitle: Text('Removes all stroke from the canvas.'),
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 );
//               });
//         },
//         child: Center(
//           child: CustomPaint(
//             painter: DrawPad(_offsets), // DrawPad(_shapes)
//             child: Container(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class CustomColorPicker extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Row(
//         children: [
//           IconButton(icon: Icon(Icons.play_arrow)),
//           Text('00:37'),
//           Slider(value: 0),
//           Text('01:15'),
//         ],
//       ),
//     );
//   }
// }
