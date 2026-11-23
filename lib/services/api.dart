import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'store.dart';

/// Network layer. Everything degrades gracefully — the app is usable with no signal.
class Api {
  Api._();
  static final Api instance = Api._();

  final http.Client client = http.Client();
  static const Duration timeout = Duration(seconds: 12);

  Future<void> init() async {}

  Future<Map<String, dynamic>?> getJson(String url) async {
    if (Store.instance.offlineMode) return null;
    try {
      final r = await client.get(Uri.parse(url)).timeout(timeout);
      if (r.statusCode != 200) return null;
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Live TON price + 24h change.
  Future<Map<String, dynamic>?> tonStats() async {
    return getJson('https://api.coingecko.com/api/v3/simple/price'
        '?ids=the-open-network&vs_currencies=usd&include_24hr_change=true');
  }

  /// Ask a question — plain-language tech explanation.
  Future<String> ask(String question) async {
    if (Store.instance.offlineMode) {
      return 'Offline mode is on. Turn it off in Settings to ask questions.';
    }
    try {
      final body = jsonEncode({
        'model': 'openai',
        'messages': [
          {
            'role': 'system',
            'content': 'You are JayP, an Ethiopian technology educator based in Addis Ababa. '
                'You explain technology clearly, in plain language, with an Ethiopian and '
                'African frame of reference. You are direct, technically accurate, and never '
                'condescending. Keep answers under 180 words.'
          },
          {'role': 'user', 'content': question}
        ],
      });
      final r = await client
          .post(
            Uri.parse('https://text.pollinations.ai/openai'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 45));
      if (r.statusCode != 200) {
        return 'The answer service returned HTTP ${r.statusCode}. Try again shortly.';
      }
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) return 'No answer came back. Try rephrasing.';
      final msg = choices.first['message'] as Map<String, dynamic>?;
      final content = msg?['content']?.toString().trim();
      return (content == null || content.isEmpty) ? 'Empty response.' : content;
    } on TimeoutException {
      return 'That took too long. Check your connection and try again.';
    } catch (_) {
      return 'Could not reach the answer service. You may be offline.';
    }
  }
}
