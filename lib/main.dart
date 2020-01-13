import 'package:flutter/material.dart';
import 'web_app.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(context) {
    return MaterialApp(
      title: 'SW16',
      routes: {"/": (_) => WebApp()},
    );
  }
}
