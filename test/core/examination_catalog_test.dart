import 'package:flutter_test/flutter_test.dart';
import 'package:ocurithm/modules/Examination/data/catalog/history_catalog.dart';
import 'package:ocurithm/modules/Examination/data/catalog/complain_catalog.dart';

/// Verification for Task 3.3. `history_catalog.dart`/`complain_catalog.dart`
/// are hand-maintained Dart ports of the backend's shared
/// `@ocurithm/examination-catalog` package (Task 1.2's audit confirmed an
/// exact 121-field / 84-field / 19-category match). These counts have no
/// automated link back to the source of truth, so a future edit to either
/// side can silently drift — this test is the tripwire.
void main() {
  test('history catalog has the same field count as the backend package',
      () {
    expect(historyFields.length, 121);
  });

  test('history catalog has the same category count as the backend package',
      () {
    expect(historyCategories.length, 19);
  });

  test('complain catalog has the same field count as the backend package',
      () {
    expect(complainFields.length, 84);
  });
}
