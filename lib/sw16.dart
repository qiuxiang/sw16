import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SW16Device {
  final String ip;
  final String data;

  SW16Device(this.ip, this.data);

  @override
  String toString() {
    return "$ip: $data";
  }
}

class SW16Controller {
  String address;
  int port;
  Socket socket;
  bool connected;
  List<int> status;
  List<int> data = [
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

  SW16Controller(this.address, {this.port = 8080});

  connect() async {
    const timeout = Duration(seconds: 2);
    socket = await Socket.connect(address, port, timeout: timeout);
    socket.listen(onData, onDone: () {
      socket.destroy();
    });
  }

  onData(data) {
    if (data[1] == 12) {
      print(data);
      status = data.sublist(2, 18);
      print(status);
    }
  }

  turn(int index, int state) async {
    data[2] = index;
    data[3] = state;
    send();
  }

  turnAll() {
    data[1] = 0x0a;
    for (int i = 2; i < 16; i += 1) {
      data[i] = ON;
    }
  }

  send() {
    socket.add(data);
  }
}

class SW16 {
  RawDatagramSocket _udp;
  final StreamController<SW16Device> _devices = StreamController();
  final devices = List<SW16Device>();

  SW16() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 23333).then((udp) {
      _udp = udp;
      udp.broadcastEnabled = true;
      udp.listen((_) {
        var response = udp.receive();
        if (response != null) {
          var address = response.address.address;
          var data = utf8.decode(response.data);
          var device = SW16Device(address, data);
          devices.add(device);
          _devices.sink.add(device);
        }
      }, onDone: () {
        _devices.close();
      });
    });
  }

  refreshDevices() {
    devices.clear();
    _udp.send('HLK'.codeUnits, InternetAddress('255.255.255.255'), 988);
  }

  Stream<SW16Device> get findDevices {
    return _devices.stream;
  }
}
