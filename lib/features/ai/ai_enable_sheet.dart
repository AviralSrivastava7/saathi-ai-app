import 'package:flutter/material.dart';
import '../../core/storage/ai_popup_storage.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../core/localization/app_localizations.dart';
import 'connect_ai_screen.dart';

class AIEnableSheet extends StatelessWidget {
  const AIEnableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // small grab handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              loc.t('saathi_here'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              loc.t('ai_dialog_desc'),
              style: const TextStyle(
                height: 1.4,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              loc.t('ai_dialog_bullets'),
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await AIPopupStorage.markShown();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    smoothPageRoute(page: const ConnectAIScreen()),
                  );
                },
                child: Text(loc.t('enable_saathi_ai')),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () async {
                  await AIPopupStorage.markShown();
                  Navigator.pop(context);
                },
                child: Text(
                  loc.t('not_now'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
