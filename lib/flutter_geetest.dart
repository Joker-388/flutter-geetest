import 'dart:async';

import 'package:flutter/services.dart';

class FlutterGeetest {
  static const MethodChannel _channel =
      const MethodChannel('flutter_geetest');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future initGeeTest() async {
    var result = await _channel.invokeMethod(
        'initGeeTest',
    );
    return result;
  }

  static Future configureGeeTest(String gt_public_key, String gt_challenge, String gt_success_code) async {
    var result = await _channel.invokeMethod(
        'configureGeeTest',
        {
          'gt_public_key':gt_public_key,
          'gt_challenge':gt_challenge,
          'gt_success_code':gt_success_code,
        }
    );
    return result;
  }

  static Future<dynamic> startGTCaptcha(bool animation) async {
    var result = await _channel.invokeMethod(
        'startGTCaptcha',
        {
          'animation':animation,
        }
    );
    return result;
  }
}

