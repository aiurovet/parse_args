// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// A list of options to write result to
///
Map<String, List> opts = {};

/// The main entry point for tests
///
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
      parseArgs(
          'verbose|appconfig',
          [
            '-appconfig',
            '--appconfig',
            '-app-config',
            '--app-config',
            '-AppConfig'
          ],
          onParse);
      expect(opts.length, 1);
      expect(opts.containsKey('appconfig'), true);
    });
    test('multiple names', () {
      opts.clear();
      parseArgs('a|b:|e,exp,expect:|f', ['-e', '1'], onParse);
      expect(opts.length, 1);
      expect(opts['expect']?.length, 1);
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
      parseArgs(
          'bit:b|decs::i|hex:x|oct:o|num:f',
          [
            '-bit',
            '101',
            '-decs',
            '7',
            '89',
            '-hex',
            'AF',
            '-oct',
            '755',
            '-num',
            '1.23'
          ],
          onParse);
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
    test('value separator', () {
      opts.clear();
      parseArgs(
          'a::i|b',
          [
            '-a',
            '1,2,3',
            '-b',
          ],
          onParse,
          valueSeparator: ',');
      expect(opts['a']?.length, 3);
      expect(opts['b'] != null, true);
    });
    test('name/value separator', () {
      parseArgs('a::i|b:', ['-a="1,2,3"', r'-b="\n"'], onParse,
          valueSeparator: ',');
      expect(opts['a']?.length, 3);
      expect(opts['a']?[2], 3);
      expect(opts['b']?.length, 1);
      expect(opts['b']?[0], r'\n');
    });
    test('value separator - bad', () {
      expect(
          () => parseArgs('a::i|b', ['-a', '1,2,3', '4', '-b'], onParse,
              valueSeparator: ','),
          throwsA((e) => e is OptNameException));
    });
    test('name/value separator - bad', () {
      expect(
          () => parseArgs('a::i|b', ['-a="1,2,3"', '4', '-b'], onParse,
              valueSeparator: ','),
          throwsA((e) => e is OptNameException));
    });
    test('undefined option exception', () {
      expect(() => parseArgs('a|b', ['-x'], onParse),
          throwsA((e) => e is OptNameException));
    });
    test('option value missing exception', () {
      expect(() => parseArgs('a|b:', ['-b'], onParse),
          throwsA((e) => e is OptValueMissingException));
    });
    test('too many option values exception', () {
      expect(() => parseArgs('a|b:', ['-b', '1', '2'], onParse),
          throwsA((e) => e is OptValueTooManyException));
    });
    test('unexpected option value exception', () {
      expect(() => parseArgs('a|b', ['-a', '1'], onParse),
          throwsA((e) => e is OptValueUnexpectedException));
    });
  });
  group('unquote -', () {
    test('empty', () {
      expect(unquote(''), '');
    });
    test('empty single-quoted', () {
      expect(unquote("''"), '');
    });
    test('empty double-quoted', () {
      expect(unquote('""'), '');
    });
    test('non-empty single-quoted', () {
      expect(unquote(r"'ab\ncd'"), r'ab\ncd');
    });
    test('non-empty double-quoted', () {
      expect(unquote(r'"ab\ncd"'), r'ab\ncd');
    });
  });
}

/// Parsed options handler: just prints whatever is passed
///
void onParse(bool isFirstRun, String name, List values) {
  opts[name] = values;
  print('"$name": $values');
}
