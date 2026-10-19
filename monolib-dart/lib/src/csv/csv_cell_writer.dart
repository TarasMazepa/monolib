/// Writes a single [cell] of data to [sink] in an RFC 4180-compatible CSV format.
///
/// Escaping is applied when [cell] starts with a double quote (`"`), or when
/// it contains a comma (`,`) or a newline character (`\n`). Internal double
/// quotes do not trigger full-cell escaping unless one of those conditions is
/// also met.
///
/// When escaped, the entire [cell] is enclosed in double quotes and any
/// internal double quotes are doubled (`"` becomes `""`). If [cell] is empty,
/// nothing is written to [sink].
///
/// Example:
/// ```dart
/// final sink = StringBuffer();
///
/// // Simple cell (no escaping)
/// writeCsvCell('hello', sink);
/// // sink contains: hello
///
/// // Cell with a comma
/// writeCsvCell('hello, world', sink);
/// // sink contains: "hello, world"
///
/// // Cell starting with a quote
/// writeCsvCell('"hello"', sink);
/// // sink contains: """hello"""
/// ```
void writeCsvCell(String cell, StringSink sink) {
  if (cell.isEmpty) return;

  bool needsEscaping =
      cell[0] == '"' || cell.contains(',') || cell.contains('\n');

  if (needsEscaping) {
    sink.write('"');
    int lastWritten = 0;
    while (true) {
      int nextQuote = cell.indexOf('"', lastWritten);
      if (nextQuote == -1) {
        sink.write(cell.substring(lastWritten));
        break;
      }
      sink.write(cell.substring(lastWritten, nextQuote));
      sink.write('""');
      lastWritten = nextQuote + 1;
    }
    sink.write('"');
  } else {
    sink.write(cell);
  }
}
