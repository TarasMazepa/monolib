import 'csv.dart';

extension CsvOnString on String {
  List<List<String>> decodeCsv() {
    return csv.decode(this).cast<List<String>>();
  }
}
