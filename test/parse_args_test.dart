// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  group('parseArgs -', () {
    test('empty', () {
      final result = printResult(parseArgs(
        '',
        [],
      ));
      expect(result.strings.length, 0);
    });
    test('start with plain args', () {
      final result = printResult(parseArgs('h|::', ['a', 'bc', '-h']));
      expect(result.strings, {
        'h': [],
        '': ['a', 'bc']
      });
    });
    test('start with a sub-option of plain args', () {
      final result =
          printResult(parseArgs('h|::>not', ['--not', 'a', 'bc', '-h']));
      expect(result.strings, {
        'h': [],
        '': ['-not', 'a', 'bc']
      });
    });
    test('similar options', () {
      final result = printResult(parseArgs('verbose|appconfig', [
        '-appconfig',
        '--appconfig',
        '-app-config',
        '--app-config',
        '-AppConfig'
      ]));
      expect(result.strings, {'appconfig': []});
    });
    test('multiple names', () {
      final result =
          printResult(parseArgs('a|b:|e,exp,expect:|f', ['-e', '1']));
      expect(result.strings, {
        'expect': ['1']
      });
    });
    test('plain args after a flag option', () {
      final result = printResult(parseArgs('a|::', ['-a', '1', '2']));
      expect(result.strings, {
        'a': [],
        '': ['1', '2']
      });
    });
    test('plain args after an option with a single value', () {
      final result = printResult(parseArgs('a:|::', ['-a', 'x', '1', '2']));
      expect(result.strings, {
        'a': ['x'],
        '': ['1', '2']
      });
    });
    test('plain args after an option with multiple values', () {
      final result = printResult(
          parseArgs('a::|::', ['-a', 'x,y,z', '1', '2'], valueSeparator: ','));
      expect(result.strings, {
        'a': ['x', 'y', 'z'],
        '': ['1', '2']
      });
    });
    test('plain args after an option with glued values', () {
      final result = printResult(parseArgs('a::|::', ['-a=1', '2']));
      expect(result.strings, {
        'a': ['1'],
        '': ['2']
      });
    });
    test('opt name: noMore', () {
      final result = printResult(parseArgs('opt1:|opt2::',
          ['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '---', '-v23']));
      expect(result.strings, {
        'opt1': ['v11'],
        'opt2': ['v21', '-', 'v22', '-v23']
      });
    });
    test('opt name: stop', () {
      final result = printResult(parseArgs('opt1:|opt2::|::',
          ['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '--', '-v23']));
      expect(result.strings, {
        'opt1': ['v11'],
        'opt2': ['v21', '-', 'v22'],
        '': ['-v23']
      });
    });
    test('numeric values', () {
      final result = printResult(parseArgs('bit:b|dec::i|hex:x|oct:o|num:f', [
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
      ]));
      expect(result.strings, {
        'bit': [5],
        'dec': [7, 89],
        'hex': [175],
        'oct': [493],
        'num': [1.23]
      });
    });
    test('primary and secondary', () {
      final result = printResult(parseArgs(
          '?,h,help|q,quiet|v,verbose|f,force|o,out:|i,inp::',
          ['-f', '-o', 'o1', '-i', 'i1', 'i2', '-q', '-v', '-h']));
      expect(result.strings, {
        '-f': [],
        '-o': ['o1'],
        '-i': ['i1', 'i2'],
        '-q': [],
        '-v': [],
        '-h': [],
      });
    });
    test('value separator', () {
      final result = printResult(parseArgs(
          'a::i|b',
          [
            '-a',
            '1,2,3',
            '-b',
          ],
          valueSeparator: ','));
      expect(result.values, {
        'a': [1, 2, 3],
        'b': []
      });
    });
    test('name/value separator', () {
      final result = printResult(parseArgs(
          'a::i|b:', ['-a="1,2,3"', r'-b="\n"'],
          valueSeparator: ','));
      expect(result.values, {
        'a': [1, 2, 3],
        'b': [r'\n']
      });
    });
    test('multiple lists of values for the same option', () {
      final result = printResult(parseArgs(
          'a::i|b|c:i|::', ['-a', '1,2', '-b', '-c', '3', '-a', '4', '5,6'],
          valueSeparator: ','));
      expect(result.values, {
        'a': [1, 2, 4, 5, 6],
        'b': [],
        'c': [3]
      });
    });
    test('valid sub-options of an option', () {
      final result = printResult(parseArgs(
          'a::i>and,or|b::', ['-a', '1', '-or', '2', '-or', '3', '-b="B,c"'],
          valueSeparator: ','));
      expect(result.values, {
        'a': [1, '-or', 2, '-or', 3],
        'b': ['B', 'c']
      });
    });
    test('valid sub-options of plain arguments', () {
      final result = printResult(parseArgs(
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
          valueSeparator: ','));
      expect(result.values, {
        'a': [1, 2, 3],
        'b': ['B', 'c'],
        '': ['x', '-and', '-not', 'y', '-or', 'z']
      });
    });
    test('undefined option exception', () {
      expect(() => printResult(parseArgs('a|b', ['-x'])),
          throwsA((e) => e is OptNameException));
    });
    test('option value missing exception', () {
      expect(() => printResult(parseArgs('a|b:', ['-b'])),
          throwsA((e) => e is OptValueMissingException));
    });
    test('plain arg not supported exception', () {
      expect(() => printResult(parseArgs('a|b:', ['-b', '1', '2'])),
          throwsA((e) => e is OptPlainArgException));
    });
    test('unexpected option value (for the flag) exception', () {
      expect(() => printResult(parseArgs('a|b', ['-a=1', '-b'])),
          throwsA((e) => e is OptValueUnexpectedException));
    });
    test('sub-option before first option exception', () {
      expect(
          () => printResult(parseArgs('a:i|b>and,or|::', ['-and', '-a', '1'])),
          throwsA((e) => e is SubOptMismatchException));
    });
  });
}

/// Parsed options handler: just prints whatever is passed
///
ParseArgsResult printResult(ParseArgsResult result) {
  print(result.strings);
  return result;
}
