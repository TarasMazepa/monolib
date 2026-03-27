import 'csv_codec.dart';

extension CsvOnString on String {
  List<List<String>> decodeCsv() {
    return const CsvCodec().decode(this).cast<List<String>>();
  }
}
