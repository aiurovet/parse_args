import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

////////////////////////////////////////////////////////////////////////////////

Map<String, List> opts = {};

////////////////////////////////////////////////////////////////////////////////

void main() {
  group('parseArgs -', () {
    test('empty', () {
      opts.clear();
      parseArgs('', [], onParse);
      expect(opts.length, 0);
    });
    test('start with plain args', () {
      opts.clear();
      parseArgs('::', ['a', 'bc'], onParse);
      expect(opts.length, 1);
      expect(opts['']?.length, 2);
    });
    test('similar options', () {
      opts.clear();
      parseArgs('verbose|appconfig', [
        '-appconfig',
        '--appconfig',
        '-app-config',
        '--app-config',
        '-AppConfig'
      ], onParse);
      expect(opts.length, 1);
      expect(opts.containsKey('appconfig'), true);
    });
    test('multiple values', () {
      opts.clear();
      parseArgs('opt1:|opt2::',
          ['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '--', '-v23'], onParse);
      expect(opts.length, 2);
      expect(opts['opt1']?.length, 1);
      expect(opts['opt2']?.length, 4);
    });
    test('numeric values', () {
      opts.clear();
      parseArgs('bit:b|decs::i|hex:x|oct:o|num:f',
          ['-bit', '101', '-decs', '7', '89', '-hex', 'AF', '-oct', '755', '-num', '1.23'], onParse);
      expect(opts.length, 5);
      expect(opts['bit']?[0], 5);
      expect(opts['decs']?[0], 7);
      expect(opts['decs']?[1], 89);
      expect(opts['hex']?[0], 175);
      expect(opts['oct']?[0], 493);
      expect(opts['num']?[0], 1.23);
    });
    test('primary and secondary', () {
      opts.clear();
      parseArgs('?,h,help|q,quiet|v,verbose|f,force|o,out:|i,inp::',
          ['-f', '-o', 'o1', '-i', 'i1', 'i2', '-q', '-v', '-h'], onParse);
    });
  });
}

////////////////////////////////////////////////////////////////////////////////

void onParse(String name, List values) {
  opts[name] = values;
  print('"$name": $values');
}

////////////////////////////////////////////////////////////////////////////////
