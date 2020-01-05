import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'web_app.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'SW16',
      home: Builder(
        builder: (context) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return WebApp();
                }));
              },
              child: Icon(Icons.play_arrow),
            ),
          );
        },
      ),
    );
  }
}
