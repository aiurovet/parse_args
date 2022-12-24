// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  group('parseArgs -', () {
    final caseMode = CliOptCaseMode.smart;

    test('empty', () {
      parseArgs('', [], caseMode: caseMode);
      final map = printResult(parseArgs(
        '',
        [],
      ));
      expect(map, {});
    });
    test('start with plain args', () {
      final map = printResult(parseArgs('h|::', ['a', 'bc', '-h']));
      expect(map, {
        '-h': [],
        '': ['a', 'bc']
      });
    });
    test('start with a sub-option of a plain arg', () {
      final map =
          printResult(parseArgs('h|::>not', ['--not', 'a', 'bc', '-h']));
      expect(map, {
        '': ['-not', 'a', 'bc'],
        '-h': [],
      });
    });
    test('similar options', () {
      final map = printResult(parseArgs('verbose|appconfig', [
        '-appconfig',
        '--appconfig',
        '-app-config',
        '--app-config',
        '-AppConfig'
      ]));
      expect(map, {'-appconfig': []});
    });
    test('multiple names', () {
      final map = printResult(parseArgs('a|b:|e,exp,expect:|f', ['-e', '1']));
      expect(map, {
        '-expect': ['1']
      });
    });
    test('plain args after a flag option', () {
      final map = printResult(parseArgs('a|::', ['-a', '1', '2']));
      expect(map, {
        '': ['1', '2'],
        '-a': [],
      });
    });
    test('plain args after an option with a single value', () {
      final map = printResult(parseArgs('a:|::', ['-a', 'x', '1', '2']));
      expect(map, {
        '': ['1', '2'],
        '-a': ['x'],
      });
    });
    test('plain args after a multi-value option having a single value', () {
      final map = printResult(parseArgs('a:,:|:,:', ['-a', 'x', 'y', 'z']));
      expect(map, {
        '': ['y', 'z'],
        '-a': ['x'],
      });
    });
    test('plain args after an option with multiple values', () {
      final map = printResult(parseArgs('a:,:|:,:', ['-a', 'x,y,z', '1', '2']));
      expect(map, {
        '': ['1', '2'],
        '-a': ['x', 'y', 'z'],
      });
    });
    test('plain args after an option with glued values', () {
      final map = printResult(parseArgs('a::|::', ['-a=1', '2']));
      expect(map, {
        '': ['2'],
        '-a': ['1'],
      });
    });
    test('opt name: last', () {
      final map = printResult(parseArgs('opt1:|opt2::|::',
          ['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '---', '-v23']));
      expect(map, {
        '-opt1': ['v11'],
        '-opt2': ['v21', '-', 'v22', '-v23']
      });
    });
    test('opt name: stop', () {
      final map = printResult(parseArgs('opt1:|opt2::|::',
          ['-opt1', 'v11', '--opt2', 'v21', '-', 'v22', '--', '-v23']));
      expect(map, {
        '': ['-v23'],
        '-opt1': ['v11'],
        '-opt2': ['v21', '-', 'v22'],
      });
    });
    test('primary and secondary', () {
      final map = printResult(parseArgs(
          '?,h,help|q,quiet|v,verbose|f,force|o,out:|i,inp::',
          ['-f', '-o', 'o1', '-i', 'i1', 'i2', '-q', '+v', '-h']));
      expect(map, {
        '-force': [],
        '-out': ['o1'],
        '-inp': ['i1', 'i2'],
        '-quiet': [],
        '+verbose': [],
        '-help': [],
      });
    });
    test('value separator', () {
      final map = printResult(parseArgs('a:,:|b', [
        '-a',
        '1,2,3',
        '-b',
      ]));
      expect(map, {
        '-a': ['1', '2', '3'],
        '-b': []
      });
    });
    test('name/value separator', () {
      final map = printResult(parseArgs('a:,:|b:', ['-a="1,2,3"', r'-b="\n"']));
      expect(map, {
        '-a': ['1', '2', '3'],
        '-b': [r'\n']
      });
    });
    test('multiple lists of values for the same option', () {
      final map = printResult(parseArgs(
          'a:,:|b|c:|::', ['-a', '1,2', '-b', '-c', '3', '-a', '4', '5,6']));
      expect(map, {
        '': ['4', '5,6'],
        '-a': ['1', '2'],
        '-b': [],
        '-c': ['3']
      });
    });
    test('valid sub-options of an option', () {
      final map = printResult(parseArgs(
          'a::>and,or|b:,:', ['-a', '1', '-or', '2', '-or', '3', '-b="B,c"']));
      expect(map, {
        '-a': ['1', '-or', '2', '-or', '3'],
        '-b': ['B', 'c']
      });
    });
    test('valid sub-options of plain arguments', () {
      final map = printResult(parseArgs('a::|b:,:|::>and,or', [
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
      ]));
      expect(map, {
        '': ['x', '-and', '-not', 'y', '-or', 'z'],
        '-a': ['1', '2', '3'],
        '-b': ['B', 'c'],
      });
    });
    test('undefined option exception', () {
      expect(() => printResult(parseArgs('a|b', ['-x'])),
          throwsA((e) => e is CliOptUndefinedNameException));
    });
    test('undefined plain arguments exception', () {
      expect(() => printResult(parseArgs('a|b:', ['-b', '1', '2'])),
          throwsA((e) => e is CliOptUndefinedNameException));
    });
    test('option value missing exception', () {
      expect(() => printResult(parseArgs('a|b:', ['-b'])),
          throwsA((e) => e is CliOptValueMissingException));
    });
    test('plain arg not supported exception', () {
      expect(() => printResult(parseArgs('a|b:', ['-b=1', '2'])),
          throwsA((e) => e is CliOptUndefinedNameException));
    });
    test('unexpected option value (for the flag) exception', () {
      expect(() => printResult(parseArgs('a|b', ['-a=1', '-b'])),
          throwsA((e) => e is CliOptValueUnexpectedException));
    });
  });
}

/// Parsed options handler: just prints whatever is passed
///
Map<String, List<String>> printResult(List<CliOpt> result) {
  final map = result.toSimpleMap();
  print(map);
  return map;
}
