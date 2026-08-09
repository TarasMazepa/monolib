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
