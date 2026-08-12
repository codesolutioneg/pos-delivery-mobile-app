import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'firebase_project_selector.dart';

/// Debug screen to pick which Firebase project to use (same list as POS).
class FirebaseProjectPickerPage extends StatelessWidget {
  const FirebaseProjectPickerPage({
    super.key,
    required this.onSelected,
    this.currentClientId,
  });

  final Future<void> Function(String clientId) onSelected;
  final String? currentClientId;

  @override
  Widget build(BuildContext context) {
    final entries = kDevFirebaseClients.entries.toList();
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('اختر بيانات الفرع'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        itemCount: entries.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppDimensions.spaceSm),
        itemBuilder: (context, index) {
          final e = entries[index];
          final selected = e.key == currentClientId;
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              side: BorderSide(
                color: selected ? AppColors.brandPrimary : Colors.transparent,
              ),
            ),
            tileColor: AppColors.bgSecondary,
            selected: selected,
            title: Text(e.value, style: AppTextStyles.bodyMd()),
            subtitle: Text(e.key, style: AppTextStyles.bodySm()),
            trailing: selected
                ? Icon(Icons.check_circle, color: AppColors.brandPrimary)
                : const Icon(Icons.chevron_right),
            onTap: () => onSelected(e.key),
          );
        },
      ),
    );
  }
}
