// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  var fs = LocalFileSystem();

  group('CliOptList -', () {
    test('isSet', () {
      final result = parseArgs('n,name', [
        '-n',
      ]);
      expect(result.isSet('name'), true);
    });
    test('!isSet - short', () {
      final result = parseArgs('n,name', [
        '+n',
      ]);
      expect(result.isSet('name'), false);
    });
    test('!isSet - long', () {
      final result = parseArgs('n,name', [
        '-no-name',
      ]);
      expect(result.isSet('name'), false);
    });
    test('getStrValue', () {
      final result = parseArgs('n,name:', [
        '-n',
        'abc',
      ]);
      expect(result.getStrValue('name'), 'abc');
    });
    test('getStrValues - single value argument', () {
      final result = parseArgs('n,name:,:', [
        '-n',
        'abc,de,fghi',
      ]);
      expect(result.getStrValues('name'), [
        'abc',
        'de',
        'fghi',
      ]);
    });
    test('getStrValues - multiple value arguments', () {
      final result = parseArgs('n,name::', [
        '-n',
        'abc',
        'de',
        'fghi',
      ]);
      expect(result.getStrValues('name'), [
        'abc',
        'de',
        'fghi',
      ]);
    });
    test('getIntValue', () {
      final result = parseArgs('n,name:', [
        '-n',
        '1234',
      ]);
      expect(result.getIntValue('name'), 1234);
    });
    test('getIntValues - multiple value arguments', () {
      final result = parseArgs('n,name::', [
        '-n',
        '1',
        '23',
        '4567',
      ]);
      expect(result.getIntValues('name'), [
        1,
        23,
        4567,
      ]);
    });
    test('getNumValue', () {
      final result = parseArgs('n,name:', [
        '-n',
        '1.234',
      ]);
      expect(result.getNumValue('name'), 1.234);
    });
    test('getNumValues - multiple value arguments', () {
      final result = parseArgs('n,name::', [
        '-n',
        '1',
        '2.3',
        '0.4567',
      ]);
      expect(result.getNumValues('name'), [
        1,
        2.3,
        0.4567,
      ]);
    });
    test('getDateValue', () {
      final result = parseArgs('f,from,fromdate:', [
        '-f',
        '2022-12-20',
      ]);
      expect(result.getDateValue('from'), DateTime.parse('2022-12-20'));
    });
    test('getDateValues - multiple value arguments', () {
      final result = parseArgs('d,dates::', [
        '-dates',
        '2021-05-20',
        '2022-12-20',
      ]);
      expect(result.getDateValues('dates'), [
        DateTime.parse('2021-05-20'),
        DateTime.parse('2022-12-20'),
      ]);
    });
    test('getGlobValue', () {
      final result = parseArgs('f,file,files::', [
        '--file',
        '*.dart',
      ]);
      final r = result.getGlobValue('file');
      expect(r is Glob, true);
      expect(r?.pattern, Glob('*.dart').pattern);
    });
    test('getGlobValue - with options', () {
      final result = parseArgs('f,file,files::', [
        '--file',
        '*.dart',
      ]);
      final r1 = result.getGlobValue('file',
          options: GlobOpt(fs, caseSensitive: false, recursive: true));
      final r2 = Glob('*.dart', caseSensitive: false, recursive: true);
      expect(r1 is Glob, true);
      expect([r1?.pattern, r1?.caseSensitive, r1?.recursive],
          [r2.pattern, r2.caseSensitive, r2.recursive]);
    });
    test('getGlobValues - multiple value arguments', () {
      final result = parseArgs('f,file,files::', [
        '--file',
        '*.dart',
        '*.js',
      ]);
      final r = result.getGlobValues('f');
      expect(r.map((x) => x.pattern), [
        Glob('*.dart').pattern,
        Glob('*.js').pattern,
      ]);
    });
    test('getRegExpValue', () {
      final result = parseArgs('r,regex,regexp:', [
        '--reg-exp',
        r'^abc$',
      ]);
      final r = result.getRegExpValue('regexp');
      expect(r is RegExp, true);
      expect(r?.pattern, RegExp(r'^abc$').pattern);
    });
    test('getRegExpValue - with options', () {
      final result = parseArgs('r,regex,regexp:', [
        '--reg-exp',
        r'^abc$',
      ]);
      final r1 = result.getRegExpValue('regexp',
          options: RegExpOpt(
              caseSensitive: false,
              dotAll: true,
              multiLine: true,
              unicode: true));
      final r2 = RegExp(r'^abc$',
          caseSensitive: false, dotAll: true, multiLine: true, unicode: true);
      expect(r1 is RegExp, true);
      expect([
        r1?.pattern,
        r1?.isCaseSensitive,
        r1?.isDotAll,
        r1?.isMultiLine,
        r1?.isUnicode
      ], [
        r2.pattern,
        r2.isCaseSensitive,
        r2.isDotAll,
        r2.isMultiLine,
        r2.isUnicode
      ]);
    });
    test('getRegExpValues - multiple value arguments', () {
      final result = parseArgs('r,regex,regexp::', [
        '--reg-exp',
        r'^abc$',
        r'[de]',
      ]);
      final r = result.getRegExpValues('r');
      expect(r.map((x) => x.pattern), [
        RegExp(r'^abc$').pattern,
        RegExp(r'[de]').pattern,
      ]);
    });
  });
}
