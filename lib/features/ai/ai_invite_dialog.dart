import 'package:flutter/material.dart';
import '../../core/storage/ai_popup_storage.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/smooth_page_route.dart';
import 'connect_ai_screen.dart';

class AIInviteDialog extends StatelessWidget {
  const AIInviteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(loc.t('saathi_here').replaceAll(' is here', ' 💙')),
      content: Text(
        loc.t('ai_dialog_desc'),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await AIPopupStorage.markShown();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: Text(loc.t('baad_me')),
        ),
        ElevatedButton(
          onPressed: () async {
            await AIPopupStorage.markShown();
            Navigator.pop(context);
            Navigator.push(
              context,
              smoothPageRoute(page: const ConnectAIScreen()),
            );
          },
          child: Text(loc.t('OK')),
        ),
      ],
    );
  }
}
