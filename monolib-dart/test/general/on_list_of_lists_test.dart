import 'package:monolib_dart/monolib_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OnListOfLists', () {
    test('formatTable', () {
      final table = [
        ['Name', 'Age', 'Score'],
        ['Alice', 25, TableCellAlignRight('95.5')],
        ['Bob', 30, 80],
        ['Charlie', 22, TableCellAlignLeft('88.8')],
        [null, 'Unknown', null], // Test null values
      ];

      final expected =
          'Name    Age     Score\n'
          'Alice        25  95.5\n' // Age and Score (TableCellAlignRight or num) right-aligned
          'Bob          30    80\n'
          'Charlie      22 88.8 \n' // TableCellAlignLeft string left-aligned
          '        Unknown      \n';

      final sink = StringBuffer();
      table.formatTable(sink);
      expect(sink.toString(), expected);
    });
  });
}
