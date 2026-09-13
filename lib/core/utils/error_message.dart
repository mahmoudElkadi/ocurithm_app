/// Turns a caught error into something worth showing a user.
///
/// The repositories signal a failed request by throwing `Exception(message)`, and
/// the action cubits hand `e.toString()` straight to a snackbar — which prefixes
/// every server message with a literal `Exception: `. The server's own wording is
/// often the whole point ("Cannot delete doctor with 3 future appointments."), so
/// the prefix is stripped rather than shown.
String readableError(Object error, {String fallback = 'An error occurred'}) {
  final text = error
      .toString()
      .replaceFirst(RegExp(r'^\s*(_?\w*Exception|Error)\s*:\s*'), '')
      .trim();

  return text.isEmpty ? fallback : text;
}
