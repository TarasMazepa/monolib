import 'csv_decoder.dart';

List<String> csvRowDecode(String row) {
  final result = const CsvDecoder().convert(row);
  return result.isNotEmpty ? result.first : [];
}
