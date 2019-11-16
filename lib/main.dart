import 'dart:async';
import 'package:flutter/material.dart';
import 'sw16.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var sw16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(padding: EdgeInsets.all(16), child: Text('Hello')),
    );
  }

  initState() {
    super.initState();
    sw16 = SW16();
    sw16.connect();
  }

  reassemble() {
    super.reassemble();
    const state = SW16.OFF;
    sw16.turn(0, state);
    new Timer(Duration(milliseconds: 100), () {
      sw16.turn(1, state);
    });
  }
}
