import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/app_localizations.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('community'), style: AppTextStyles.heading),
        backgroundColor: AppColors.backgroundMid,
      ),
      body: Center(
        child: Text(AppLocalizations.of(context).t('community'), style: AppTextStyles.body),
      ),
    );
  }
}
