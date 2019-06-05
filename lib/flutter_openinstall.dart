import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

class FlutterOpeninstall {
  EventHandler _onWakeupNotification;

  static const MethodChannel _channel =
      const MethodChannel('flutter_openinstall');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  void addEventHandler({
    EventHandler onWakeupNotification,
  }) {
    _onWakeupNotification = onWakeupNotification;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onWakeupNotification":
        return _onWakeupNotification(call.arguments.cast<String, dynamic>());
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
  }
}
