import 'package:monolib_dart/cli.dart';
import 'package:test/test.dart';

void main() {
  group('Flag', () {
    test('findAndRemoveFlag - long flag', () {
      final flag = Flag(long: '--verbose', description: 'Verbose mode');
      final args = ['run', '--verbose', 'file.txt'];
      final result = flag.findAndRemoveFlag(args);

      expect(result, isNotNull);
      expect(result!.index, 1);
      expect(result.type, FlagFindType.long);
      expect(result.matchedFlag, flag);
      expect(args, ['run', 'file.txt']);
    });

    test('findAndRemoveFlag - short standalone flag', () {
      final flag = Flag(short: '-v', description: 'Verbose mode');
      final args = ['run', '-v', 'file.txt'];
      final result = flag.findAndRemoveFlag(args);

      expect(result, isNotNull);
      expect(result!.index, 1);
      expect(result.type, FlagFindType.shortStandalone);
      expect(result.matchedFlag, flag);
      expect(args, ['run', 'file.txt']);
    });

    test('findAndRemoveFlag - short combined flag', () {
      final flag = Flag(short: '-v', description: 'Verbose mode');
      final args = ['run', '-xvf', 'file.txt'];
      final result = flag.findAndRemoveFlag(args);

      expect(result, isNotNull);
      expect(result!.index, 1);
      expect(result.type, FlagFindType.shortCombined);
      expect(result.matchedFlag, flag);
      expect(args, ['run', '-xf', 'file.txt']);
    });

    test('findAndRemoveFlag - short combined to standalone', () {
      final flag = Flag(short: '-v', description: 'Verbose mode');
      final args = ['run', '-v', 'file.txt'];
      final result = flag.findAndRemoveFlag(args);

      expect(result, isNotNull);
      expect(result!.index, 1);
      expect(result.type, FlagFindType.shortStandalone);
      expect(result.matchedFlag, flag);
      expect(args, ['run', 'file.txt']);
    });

    test('findAndRemoveFlag - not found', () {
      final flag = Flag(short: '-v', long: '--verbose', description: 'Verbose');
      final args = ['run', 'file.txt'];
      final result = flag.findAndRemoveFlag(args);

      expect(result, isNull);
      expect(args, ['run', 'file.txt']);
    });

    test('hasFlag', () {
      final flag = Flag(short: '-v', long: '--verbose', description: 'Verbose');

      var args = ['run', '--verbose'];
      expect(flag.hasFlag(args), isTrue);
      expect(args, ['run']);

      args = ['run', '-v'];
      expect(flag.hasFlag(args), isTrue);
      expect(args, ['run']);

      args = ['run'];
      expect(flag.hasFlag(args), isFalse);
      expect(args, ['run']);
    });

    test('getFlagValue', () {
      final flag = Flag(short: '-f', long: '--file', description: 'File');

      var args = ['run', '--file', 'test.txt'];
      expect(flag.getFlagValue(args), 'test.txt');
      expect(args, ['run']);

      args = ['run', '-f', 'test2.txt'];
      expect(flag.getFlagValue(args), 'test2.txt');
      expect(args, ['run']);
    });

    test('getFlagValue - short combined throws exception', () {
      final flag = Flag(short: '-f', description: 'File');
      final args = ['run', '-xf'];
      expect(() => flag.getFlagValue(args), throwsException);
    });

    test('getFlagValue - missing value throws exception', () {
      final flag = Flag(short: '-f', long: '--file', description: 'File');
      final args = ['run', '--file'];
      expect(() => flag.getFlagValue(args), throwsException);
    });

    test('getFlagValue - not found', () {
      final flag = Flag(short: '-f', long: '--file', description: 'File');
      final args = ['run'];
      expect(flag.getFlagValue(args), isNull);
    });

    test('getOptionalFlagValue - value present', () {
      final flag = Flag(short: '-f', long: '--file', description: 'File');
      final args = ['run', '--file', 'test.txt'];
      final result = flag.getOptionalFlagValue(args);

      expect(result, isA<FlagPresent>());
      expect((result as FlagPresent).value, 'test.txt');
      expect(args, ['run']);
    });

    test('getOptionalFlagValue - short combined returns null value', () {
      final flag = Flag(short: '-f', description: 'File');
      final args = ['run', '-xf'];
      final result = flag.getOptionalFlagValue(args);

      expect(result, isA<FlagPresent>());
      expect((result as FlagPresent).value, isNull);
      expect(args, ['run', '-x']);
    });

    test('getOptionalFlagValue - value missing returns null value', () {
      final flag = Flag(short: '-f', long: '--file', description: 'File');
      final args = ['run', '--file'];
      final result = flag.getOptionalFlagValue(args);

      expect(result, isA<FlagPresent>());
      expect((result as FlagPresent).value, isNull);
      expect(args, ['run']);
    });

    test('getOptionalFlagValue - not present', () {
      final flag = Flag(short: '-f', long: '--file', description: 'File');
      final args = ['run'];
      final result = flag.getOptionalFlagValue(args);

      expect(result, isA<FlagNotPresent>());
    });

    test('toString', () {
      final flag1 =
          Flag(short: '-v', long: '--verbose', description: 'Verbose mode');
      expect(flag1.toString(), '-v, --verbose - Verbose mode');

      final flag2 = Flag(short: '-v', description: 'Verbose mode');
      expect(flag2.toString(), '-v - Verbose mode');

      final flag3 = Flag(long: '--verbose', description: 'Verbose mode');
      expect(flag3.toString(), '--verbose - Verbose mode');
    });

    test('assertions', () {
      expect(() => Flag(description: 'Desc'), throwsA(isA<AssertionError>()));
      expect(() => Flag(short: 'v', description: 'Desc'),
          throwsA(isA<AssertionError>()));
      expect(() => Flag(short: '-vx', description: 'Desc'),
          throwsA(isA<AssertionError>()));
      expect(() => Flag(long: '-v', description: 'Desc'),
          throwsA(isA<AssertionError>()));
      expect(() => Flag(long: 'verbose', description: 'Desc'),
          throwsA(isA<AssertionError>()));
    });
  });
}
