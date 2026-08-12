import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// OTP confirm dialog (Yasser UX) without pin_code_fields dependency.
class OtpConfirmationDialog extends StatefulWidget {
  const OtpConfirmationDialog({
    super.key,
    required this.expectedOtp,
    required this.orderNumber,
    required this.onSuccess,
  });

  final String expectedOtp;
  final String orderNumber;
  final VoidCallback onSuccess;

  static Future<void> show(
    BuildContext context, {
    required String expectedOtp,
    required String orderNumber,
    required VoidCallback onSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpConfirmationDialog(
        expectedOtp: expectedOtp,
        orderNumber: orderNumber,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<OtpConfirmationDialog> createState() => _OtpConfirmationDialogState();
}

class _OtpConfirmationDialogState extends State<OtpConfirmationDialog> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;
  String _error = '';

  @override
  void initState() {
    super.initState();
    final n = widget.expectedOtp.length.clamp(4, 6);
    _controllers = List.generate(n, (_) => TextEditingController());
    _nodes = List.generate(n, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _verify() {
    if (_value == widget.expectedOtp) {
      Navigator.of(context).pop();
      widget.onSuccess();
      return;
    }
    setState(() => _error = 'Invalid OTP. Please try again.');
    for (final c in _controllers) {
      c.clear();
    }
    _nodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security, color: AppColors.brandPrimary),
            ),
            const SizedBox(height: 16),
            Text('Order Verification', style: AppTextStyles.titleMd()),
            const SizedBox(height: 8),
            Text(
              'Enter the OTP from the customer\nfor order ${widget.orderNumber}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_controllers.length, (i) {
                return Container(
                  width: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _nodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _error.isEmpty
                              ? AppColors.brandPrimary
                              : AppColors.error,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (v) {
                      if (_error.isNotEmpty) setState(() => _error = '');
                      if (v.isNotEmpty && i < _nodes.length - 1) {
                        _nodes[i + 1].requestFocus();
                      }
                      if (_value.length == _controllers.length) _verify();
                    },
                  ),
                );
              }),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error, style: AppTextStyles.bodySm(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.driverApp300,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _value.length == _controllers.length
                        ? _verify
                        : null,
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.brandPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ask the customer for the OTP to complete delivery',
                      style: AppTextStyles.bodySm(color: AppColors.brandPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
