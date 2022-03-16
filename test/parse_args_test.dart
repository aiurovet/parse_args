import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

////////////////////////////////////////////////////////////////////////////////

Map<String, List> opts = {};

////////////////////////////////////////////////////////////////////////////////

void main() {
  group('parseArgs -', () {
    test('empty', () {
      opts.clear();
      parseArgs([], onParse);
      expect(opts.length, 0);
    });
    test('start with plain args', () {
      opts.clear();
      parseArgs(['a', 'bc'], onParse);
      expect(opts.length, 1);
      expect(opts['']?.length, 2);
    });
    test('similar options', () {
      opts.clear();
      parseArgs(['-appconfig', '--appconfig', '-app-config', '--app-config', '-AppConfig'], onParse);
      expect(opts.length, 1);
      expect(opts.containsKey('appconfig'), true);
    });
    test('multiple values', () {
      opts.clear();
      parseArgs(['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '--', '-v23'], onParse);
      expect(opts.length, 2);
      expect(opts['opt1']?.length, 1);
      expect(opts['opt2']?.length, 4);
    });
  });
}

////////////////////////////////////////////////////////////////////////////////

bool onParse(String optName, List<String> values) {
  opts[optName] = values;
  print('"$optName": $values');
  return true;
}

////////////////////////////////////////////////////////////////////////////////
