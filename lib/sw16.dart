import 'dart:convert';
import 'dart:io';
import 'dart:async';

class SW16DeviceInfo {
  final String ip;
  final String data;

  SW16DeviceInfo(this.ip, this.data);

  @override
  String toString() {
    return "$ip: $data";
  }
}

class SW16Finder {
  RawDatagramSocket udp;
  final StreamController<SW16DeviceInfo> streamController = StreamController();

  Future<void> init() async {
    udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 23333);
    udp.broadcastEnabled = true;
    udp.listen((e) {
      var response = udp.receive();
      if (response != null) {
        var address = response.address.address;
        var data = utf8.decode(response.data);
        streamController.sink.add(SW16DeviceInfo(address, data));
      }
    }, onDone: () {
      streamController.close();
    });
  }

  find() {
    udp.send('HLK'.codeUnits, InternetAddress('255.255.255.255'), 988);
  }

  StreamSubscription<SW16DeviceInfo> listen(void onData(SW16DeviceInfo event)) {
    return streamController.stream.listen(onData);
  }
}

class SW16Device {
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

  SW16Device(this.address, {this.port = 8080});

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
  RawDatagramSocket udp;
  final StreamController<SW16DeviceInfo> findController = StreamController();

  SW16() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 23333).then((_udp) {
      udp = _udp;
      udp.broadcastEnabled = true;
      udp.listen((_) {
        var response = udp.receive();
        if (response != null) {
          var address = response.address.address;
          var data = utf8.decode(response.data);
          findController.sink.add(SW16DeviceInfo(address, data));
        }
      }, onDone: () {
        findController.close();
      });
    });
  }

  Stream<SW16DeviceInfo> get onFindDevices {
    return findController.stream;
  }
}
