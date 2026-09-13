import 'format_helper.dart';

/// Helpers shared by the glasses-prescription form, its PDF and the read-only
/// examination views, so the printed table and the screen never disagree.
class GlassesPrescription {
  const GlassesPrescription._();

  static const int ipdMin = 1;
  static const int ipdMax = 180;

  static const String nStyleManual = 'manual';
  static const String nStyleAuto = 'auto';

  /// Unset reads as manual, which is how the printout behaved before the setting
  /// existed.
  static String resolveNStyle(String? nStyle) =>
      nStyle == nStyleAuto ? nStyleAuto : nStyleManual;

  /// Before IPD became a numeric field, doctors typed "IPD: 63" by hand so the
  /// printout would carry a label. The label is printed for them now, so strip any
  /// they already saved rather than rendering "IPD: IPD: 63".
  static String normalizeIpd(dynamic value) {
    if (value == null) return '';
    return value
        .toString()
        .replaceFirst(RegExp(r'^\s*ipd\s*[:\-]?\s*', caseSensitive: false), '')
        .trim();
  }

  static num? _toNumber(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == '-' || text == 'N/A') return null;
    return num.tryParse(text.startsWith('+') ? text.substring(1) : text);
  }

  /// The "N" row of a printed glasses prescription.
  ///
  /// `auto` gives the optician a ready-to-grind near-vision power: the near addition
  /// is folded into the spherical, and the cylinder and axis repeat the far-vision
  /// row unchanged. `manual` leaves the arithmetic to the optician, printing the
  /// addition as "add +2.00" with the rest of the row blank.
  static NearVisionRow buildNearVisionRow({
    required String? nStyle,
    dynamic spherical,
    dynamic cylindrical,
    dynamic axis,
    dynamic nearVisionAddition,
  }) {
    if (resolveNStyle(nStyle) == nStyleManual) {
      final formatted =
          FormatHelper.formatPositiveValue(nearVisionAddition) ?? '-';
      final hasValue = _toNumber(nearVisionAddition) != null;

      return NearVisionRow(
        spherical: hasValue ? 'add $formatted' : '-',
        cylindrical: '',
        axis: '',
      );
    }

    final sphericalValue = _toNumber(spherical);
    final additionValue = _toNumber(nearVisionAddition);
    // Either half on its own is still worth printing; only a fully empty pair is "-".
    final total = sphericalValue == null && additionValue == null
        ? null
        : (sphericalValue ?? 0) + (additionValue ?? 0);

    return NearVisionRow(
      spherical: total == null
          ? '-'
          : (FormatHelper.formatPositiveValue(total) ?? '-'),
      cylindrical: FormatHelper.formatPositiveValue(cylindrical) ?? '-',
      axis: (axis == null || axis.toString().trim().isEmpty)
          ? '-'
          : axis.toString(),
    );
  }
}

class NearVisionRow {
  const NearVisionRow({
    required this.spherical,
    required this.cylindrical,
    required this.axis,
  });

  final String spherical;
  final String cylindrical;
  final String axis;
}
