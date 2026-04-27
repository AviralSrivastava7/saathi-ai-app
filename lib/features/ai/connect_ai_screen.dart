import 'package:flutter/material.dart';
import '../../core/storage/ai_key_storage.dart';
import '../../core/config/ai_config.dart';
import '../../core/localization/app_localizations.dart';

class ConnectAIScreen extends StatefulWidget {
  const ConnectAIScreen({super.key});

  @override
  State<ConnectAIScreen> createState() => _ConnectAIScreenState();
}

class _ConnectAIScreenState extends State<ConnectAIScreen> {
  final controller = TextEditingController();
  String provider = 'openai';

  void _save() async {
    await AIKeyStorage.save(controller.text.trim(), provider);
    AIConfig.apiKey = controller.text.trim();
    AIConfig.provider = provider;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.t('connect_ai'))),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('ai_listen_better'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              loc.t('create_api_key'),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {},
              child: const Text(
                'https://platform.openai.com/api-keys',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: loc.t('paste_api_key'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              loc.t('billing_warn'),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _save,
              child: Text(loc.t('save_continue')),
            ),
          ],
        ),
      ),
    );
  }
}
