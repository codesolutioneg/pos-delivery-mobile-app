import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n_x.dart';

Future<void> launchPhoneCall(BuildContext context, String phone) async {
  if (phone.trim().isEmpty) return;
  final uri = Uri(scheme: 'tel', path: phone.trim());
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cannotOpenDialer)),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.callFailed('$e'))),
      );
    }
  }
}

Color statusColor(String status) {
  final s = status.toLowerCase();
  if (s.contains('deliver') || s == 'completed' || s == 'done') {
    return const Color(0xFF10B271);
  }
  if (s.contains('reject') || s.contains('cancel')) {
    return const Color(0xFFFF3840);
  }
  if (s.contains('accept') ||
      s.contains('pick') ||
      s.contains('ship') ||
      s.contains('on_the_way') ||
      s == 'sent') {
    return const Color(0xFF5BC236);
  }
  if (s.contains('pending') || s == 'new' || s == 'received') {
    return const Color(0xFFFFCB39);
  }
  return const Color(0xFF009DE0);
}
