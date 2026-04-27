import 'dart:math';
import 'emotion_detector.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ResponseEngine {
  static Map<String, dynamic>? _data;
  static final _rand = Random();

  static Future<void> load() async {
    if (_data != null) return;
    final raw =
        await rootBundle.loadString('assets/data/response_templates.json');
    _data = json.decode(raw);
  }

  static Future<String> reply(String userText) async {
    await load();

    final emotion = EmotionDetector.detect(userText);
    final key = emotion.type.name;

    final bucket = _data![key] ?? _data!['unknown'];

    String pick(List list) => list[_rand.nextInt(list.length)];

    final validation = pick(bucket['validation']);
    final reflection = pick(bucket['reflection']);

    String response = '$validation $reflection';

    if (emotion.intensity >= 3 && bucket['direction'] != null) {
      response += ' ${pick(bucket['direction'])}';
    }

    return response;
  }
}
