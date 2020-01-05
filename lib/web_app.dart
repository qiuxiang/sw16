import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebApp extends StatelessWidget {
  WebViewController _controller;

  @override
  Widget build(var context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.reload();
        },
        child: Icon(Icons.refresh),
      ),
      body: WebView(
        initialUrl: 'http://192.168.1.17:8000',
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: [
          _javascriptChannel('getDevices', (data, callback) {
            callback(data);
          }),
          _javascriptChannel('print', (data, callback) {
            print(data);
          })
        ].toSet(),
      ),
    );
  }

  JavascriptChannel _javascriptChannel(String name, JCHandler handler) {
    return JavascriptChannel(
      name: name,
      onMessageReceived: (message) {
        var json = jsonDecode(message.message);
        handler(json['data'], (data) {
          _controller.evaluateJavascript(
              'javascriptChannelCallback(${json['id']}, \'${jsonEncode(data)}\')');
        });
      },
    );
  }
}

typedef void JCCallback(data);
typedef void JCHandler(message, JCCallback callback);
