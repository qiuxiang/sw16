import 'dart:io';

class SW16 {
  var address;
  var port;
  var socket;
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

  SW16({this.address, this.port = 8080});

  connect() async {
    try {
      socket = await Socket.connect(address, port);
      socket.listen(onData, onDone: () {
        socket.destroy();
      });
      return true;
    } catch (e) {
      return false;
    }
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
