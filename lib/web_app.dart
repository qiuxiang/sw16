import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'sw16.dart';

class WebApp extends StatelessWidget {
  final _loaded = Completer<bool>();
  final _webView = new FlutterWebviewPlugin();
  final _sw16 = SW16();

  WebApp() {
    _sw16.onFind.listen((device) {
      eval('onMessage("device", \'${jsonEncode(device)}\')');
    });
    _sw16.onStatusChanged.listen((status) {
      eval('onMessage("status", \'${jsonEncode(status)}\')');
    });
    _webView.onStateChanged.listen((state) {
      if (state.type == WebViewState.finishLoad && !_loaded.isCompleted) {
        _loaded.complete(true);
      }
    });
  }

  @override
  Widget build(context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return WebviewScaffold(
      url: "http://localhost:8081",
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
    await _loaded.future;
    _webView.evalJavascript(js);
  }
}
