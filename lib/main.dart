import 'package:flutter/material.dart';
import 'sw16.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SW16',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
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
  SW16Finder finder = new SW16Finder();
  List<SW16Device> devices = [];
  List<SW16DeviceInfo> _devices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SW16")),
      body: Padding(
          padding: EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RaisedButton(
                child: Text("Find Devices"), onPressed: refreshDevices),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _devices
                    .map((device) => Padding(
                        padding: EdgeInsets.only(top: 6, bottom: 6),
                        child: Text(device.toString())))
                    .toList()),
            RaisedButton(child: Text("Turn On"), onPressed: turnOn),
            RaisedButton(child: Text("Turn Off"), onPressed: turnOff),
          ])),
    );
  }

  initState() {
    super.initState();
    initFinder();
  }

  initFinder() async {
    await finder.init();
    finder.listen((device) {
      print(device);
      var sw16 = SW16Device(device.ip);
      sw16.connect();
      devices.add(sw16);
      setState(() {
        _devices.add(device);
      });
    });
  }

  turnOn() {
    devices[0].turn(0, SW16Device.ON);
    devices[1].turn(15, SW16Device.ON);
  }

  turnOff() {
    devices[0].turn(0, SW16Device.OFF);
  }

  refreshDevices() {
    finder.find();
    devices.clear();
    setState(() {
      _devices.clear();
    });
  }
}
