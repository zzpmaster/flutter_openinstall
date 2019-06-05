import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_openinstall/flutter_openinstall.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_openinstall');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterOpeninstall.platformVersion, '42');
  });
}
