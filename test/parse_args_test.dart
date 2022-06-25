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
      parseArgs('h|::', ['a', 'bc', '-h'], onParse);
      expect(opts, {
        'h': [],
        '': ['a', 'bc']
      });
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
      expect(opts, {'appconfig': []});
    });
    test('multiple names', () {
      opts.clear();
      parseArgs('a|b:|e,exp,expect:|f', ['-e', '1'], onParse);
      expect(opts, {
        'expect': ['1']
      });
    });
    test('plain args after a flag option', () {
      opts.clear();
      parseArgs('a|::', ['-a', '1', '2'], onParse);
      expect(opts, {
        'a': [],
        '': ['1', '2']
      });
    });
    test('plain args after an option with a single value', () {
      opts.clear();
      parseArgs('a:|::', ['-a', 'x', '1', '2'], onParse);
      expect(opts, {
        'a': ['x'],
        '': ['1', '2']
      });
    });
    test('plain args after an option with multiple values', () {
      opts.clear();
      parseArgs('a::|::', ['-a', 'x,y,z', '1', '2'], onParse,
          valueSeparator: ',');
      expect(opts, {
        'a': ['x', 'y', 'z'],
        '': ['1', '2']
      });
    });
    test('plain args after an option with multiple glued values', () {
      opts.clear();
      parseArgs('a::|::', ['-a=1', '2'], onParse);
      expect(opts, {
        'a': ['1'],
        '': ['2']
      });
    });
    test('opt name: noMore', () {
      opts.clear();
      parseArgs(
          'opt1:|opt2::',
          ['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '---', '-v23'],
          onParse);
      expect(opts, {
        'opt1': ['v11'],
        'opt2': ['v21', '-', 'v22', '-v23']
      });
    });
    test('opt name: stop', () {
      opts.clear();
      parseArgs('opt1:|opt2::|::',
          ['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '--', '-v23'], onParse);
      expect(opts, {
        'opt1': ['v11'],
        'opt2': ['v21', '-', 'v22'],
        '': ['-v23']
      });
    });
    test('numeric values', () {
      opts.clear();
      parseArgs(
          'bit:b|dec::i|hex:x|oct:o|num:f',
          [
            '-bit',
            '101',
            '-dec',
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
      expect(opts, {
        'bit': [5],
        'dec': [7, 89],
        'hex': [175],
        'oct': [493],
        'num': [1.23]
      });
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
      expect(opts, {
        'a': [1, 2, 3],
        'b': []
      });
    });
    test('name/value separator', () {
      opts.clear();
      parseArgs('a::i|b:', ['-a="1,2,3"', r'-b="\n"'], onParse,
          valueSeparator: ',');
      expect(opts, {
        'a': [1, 2, 3],
        'b': [r'\n']
      });
    });
    test('multiple lists of values for the same option', () {
      opts.clear();
      parseArgs('a::i|b|c:i|::',
          ['-a', '1,2', '-b', '-c', '3', '-a', '4', '5,6'], onParse,
          valueSeparator: ',');
      expect(opts, {
        'a': [1, 2, 4, 5, 6],
        'b': [],
        'c': [3]
      });
    });
    test('valid sub-options of an option', () {
      opts.clear();
      parseArgs('a::i>and,or|b::',
          ['-a', '1', '-or', '2', '-or', '3', '-b="B,c"'], onParse,
          valueSeparator: ',');
      expect(opts, {
        'a': [1, '-or', 2, '-or', 3],
        'b': ['B', 'c']
      });
    });
    test('valid sub-options of plain arguments', () {
      opts.clear();
      parseArgs(
          'a::i|b::|::>and,or',
          [
            '-a',
            '1',
            '2',
            '3',
            '-b="B,c"',
            '--',
            'x',
            '-and',
            '-not',
            'y',
            '-or',
            'z'
          ],
          onParse,
          valueSeparator: ',');
      expect(opts, {
        'a': [1, 2, 3],
        'b': ['B', 'c'],
        '': ['x', '-and', '-not', 'y', '-or', 'z']
      });
    });
    test('undefined option exception', () {
      opts.clear();
      expect(() => parseArgs('a|b', ['-x'], onParse),
          throwsA((e) => e is OptNameException));
    });
    test('option value missing exception', () {
      opts.clear();
      expect(() => parseArgs('a|b:', ['-b'], onParse),
          throwsA((e) => e is OptValueMissingException));
    });
    test('plain arg not supported exception', () {
      opts.clear();
      expect(() => parseArgs('a|b:', ['-b', '1', '2'], onParse),
          throwsA((e) => e is OptPlainArgException));
    });
    test('unexpected option value (for the flag) exception', () {
      opts.clear();
      expect(() => parseArgs('a|b', ['-a=1', '-b'], onParse),
          throwsA((e) => e is OptValueUnexpectedException));
    });
    test('sub-option before first option exception', () {
      opts.clear();
      expect(() => parseArgs('a:i|b>and,or', ['-and', '-a', '1'], onParse),
          throwsA((e) => e is SubOptOrphanException));
    });
  });
}

/// Parsed options handler: just prints whatever is passed
///
void onParse(bool isFirstRun, String name, List values) {
  opts[name] = values;
  print('"$name": $values');
}
