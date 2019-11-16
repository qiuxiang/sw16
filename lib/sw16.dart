import 'dart:io';
import 'dart:async';

class SW16 {
  var address;
  var port;
  var socket;
  var connected;
  var status;
  var data = [
    0xaa,
    0X0f,
    0,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    0xbb
  ];

  static const ON = 1;
  static const OFF = 2;

  SW16({this.port = 8080});

  connect() async {
    address = await getAddress();
    const timeout = Duration(seconds: 2);
    socket = await Socket.connect(address, port, timeout: timeout);
    socket.listen(onData, onDone: () {
      socket.destroy();
    });
  }

  getAddress() {
    var completer = new Completer();
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 23333).then((udp) {
      var address;
      new Timer(Duration(seconds: 2), () {
        if (address == null) {
          completer.completeError('timeout');
        }
      });
      udp.broadcastEnabled = true;
      udp.listen((e) {
        var response = udp.receive();
        if (response != null) {
          address = response.address.address;
          udp.close();
          completer.complete(address);
        }
      });
      udp.send('HLK'.codeUnits, InternetAddress('255.255.255.255'), 988);
    });
    return completer.future;
  }

  onData(data) {
    if (data[1] == 12) {
      print(data);
      status = data.sublist(2, 18);
      print(status);
    }
  }

  turn(index, state) async {
    data[2] = index;
    data[3] = state;
    send();
  }

  send() {
    socket.add(data);
  }
}
