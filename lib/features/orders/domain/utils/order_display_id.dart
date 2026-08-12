/// Same receipt / POS order display rules as
/// `pos_test/.../delivery_orders_screen.dart` → `_orderDisplayName`.
abstract final class OrderDisplayId {
  OrderDisplayId._();

  static const _skipLabels = {
    'انتظار المزامنة',
    'ملغي',
    'طلب محلي',
    'النهار المزامنة',
    'يوم المزامنة',
  };

  /// Prefer POS-precomputed [displayOrderName], else derive like the POS card.
  static String resolve({
    required String docId,
    String? displayOrderName,
    String? orderNumber,
    String? odooOrderName,
    String? odooOrderId,
  }) {
    final pre = (displayOrderName ?? '').trim();
    if (pre.isNotEmpty && !_skipLabels.contains(pre)) return pre;

    final odooName = (odooOrderName ?? '').trim();
    final isRealOdooName = odooName.isNotEmpty &&
        !_skipLabels.contains(odooName) &&
        odooName.contains('/') &&
        RegExp(r'\d').hasMatch(odooName);
    if (isRealOdooName) return odooName;

    for (final raw in [
      (orderNumber ?? '').trim(),
      odooName.replaceFirst(RegExp(r'^#'), ''),
    ]) {
      if (raw.isEmpty || _skipLabels.contains(raw)) continue;
      final seq = _receiptSeqFromOrderNumber(raw);
      if (seq.isNotEmpty) return '#$seq';
    }

    final odooId = (odooOrderId ?? '').trim();
    if (odooId.startsWith('pending_')) {
      final localId = odooId.substring(8);
      if (localId.length >= 6) {
        return '#${localId.substring(localId.length - 6)}';
      }
      if (localId.isNotEmpty) return '#$localId';
    }

    if (docId.length >= 6) {
      return '#${docId.substring(docId.length - 6).toUpperCase()}';
    }
    if (docId.isNotEmpty) return '#$docId';
    return '#--';
  }

  /// `0808-34792-441` → `34792` — same as POS receipt SEQ.
  static String _receiptSeqFromOrderNumber(String raw) {
    final s = raw.trim().replaceFirst(RegExp(r'^#'), '');
    if (s.isEmpty) return '';
    if (s.length > 24 || s.contains('_')) return '';
    final parts = s.split('-');
    if (parts.length >= 2) {
      final seq = parts[1].trim();
      if (seq.isNotEmpty && RegExp(r'^\d+$').hasMatch(seq)) return seq;
    }
    if (RegExp(r'^\d+$').hasMatch(s)) return s;
    return '';
  }
}
