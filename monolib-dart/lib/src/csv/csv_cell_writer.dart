/// Provides [writeCsvCell], a utility for formatting and escaping individual CSV cells.
library;

/// Writes a single [cell] of data to a [StringSink] in an RFC 4180-compatible format.
///
/// This function is used internally by encoders like [CsvEncoder] to evaluate
/// the contents of [cell] and determine if escaping is necessary. Escaping
/// is required if the [cell] starts with a quotation
/// mark (`"`), or if it contains any commas (`,`) or newline characters (`\n`).
/// Internal quotation marks do not trigger full cell escaping on their own.
///
/// When escaping is applied, the entire [cell] is enclosed in double quotes,
/// and any internal double quotes are duplicated (i.e., `"` becomes `""`).
/// If the [cell] is empty, nothing is written to the [sink].
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
