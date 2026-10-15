/// Writes a single [cell] of data to a [StringSink] in a CSV-compatible format.
///
/// This function evaluates the contents of [cell] to determine if escaping
/// is necessary. Escaping is required if the [cell] starts with a quotation
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

  int index = 0;
  bool needsEscaping = cell[0] == '"';
  while (!needsEscaping && index < cell.length) {
    final current = cell[index++];
    needsEscaping = switch (current) {
      ',' => true,
      '\n' => true,
      _ => false,
    };
  }

  if (needsEscaping) {
    sink.write('"');
    for (int j = 0; j < cell.length; j++) {
      sink.write(switch (cell[j]) {
        '"' => '""',
        final symbol => symbol,
      });
    }
    sink.write('"');
  } else {
    sink.write(cell);
  }
}
