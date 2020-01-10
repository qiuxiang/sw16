import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'sw16.dart';

class WebApp extends StatelessWidget {
  final _webView = Completer<WebViewController>();
  final _sw16 = SW16();

  WebApp() {
    _sw16.device.listen((device) {
      eval('onMessage("device", \'${jsonEncode(device)}\')');
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () async {
          (await _webView.future).reload();
        },
      ),
      body: WebView(
        initialUrl: 'http://localhost:8081',
        onWebViewCreated: (controller) {
          _webView.complete(controller);
        },
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: [
          javascriptChannel('findDevices', (_) => _sw16.findDevices()),
          javascriptChannel('clearDevices', (_) => _sw16.clearDevices()),
          javascriptChannel('getDevices', (_) => _sw16.devices),
          javascriptChannel(
              'turnOn', (index) => _sw16.turnOn(index[0], index[1])),
          javascriptChannel(
              'turnOff', (index) => _sw16.turnOff(index[0], index[1])),
          javascriptChannel('logcat', (message) => print(message))
        ].toSet(),
      ),
    );
  }

  JavascriptChannel javascriptChannel(String name, handler) {
    return JavascriptChannel(
      name: name,
      onMessageReceived: (message) async {
        dynamic json = jsonDecode(message.message);
        var data = await handler(json['data']);
        if (data != null) {
          eval('channelCallback(${json['id']}, \'${jsonEncode(data)}\')');
        }
      },
    );
  }

  eval(String js) async {
    (await _webView.future).evaluateJavascript(js);
  }
}
