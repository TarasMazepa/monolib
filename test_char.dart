import 'package:characters/characters.dart';

void main() {
  final baseChar = '\u200B';
  final combiningChar = String.fromCharCode(0x0300 + 1);
  final str = '$baseChar$combiningChar';
  print(str.characters.length);
  print(str.length);

  final fullStr = 'Hello' + str + 'World';
  print(fullStr.characters.length);
}
