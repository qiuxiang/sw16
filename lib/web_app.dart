import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'sw16.dart';

class WebApp extends StatelessWidget {
  final _webView = Completer<WebViewController>();
  final _sw16 = SW16();

  WebApp() {
    _sw16.findDevices.listen((device) {
      print(device);
      eval('on');
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
        initialUrl: 'http://192.168.1.17:8000',
        onWebViewCreated: (controller) {
          _webView.complete(controller);
        },
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: [
          javascriptChannel('refreshDevices', (data, callback) {
            _sw16.refreshDevices();
          }),
          javascriptChannel('getDevices', (data, callback) {}),
          javascriptChannel('print', (data, callback) {
            print(data);
          })
        ].toSet(),
      ),
    );
  }

  JavascriptChannel javascriptChannel(String name, handler) {
    return JavascriptChannel(
      name: name,
      onMessageReceived: (message) {
        dynamic json = jsonDecode(message.message);
        handler(json['data'], (data) async {
          eval('channelCallback(${json['id']}, \'${jsonEncode(data)}\')');
        });
      },
    );
  }

  eval(String js) async {
    (await _webView.future).evaluateJavascript(js);
  }
}
