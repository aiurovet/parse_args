// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/parse_args.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  final caseMode = CliOptCaseMode.exact;

  group('Constructor -', () {
    test('empty', () {
      final optDef = CliOptDef('', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        [''],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        false,
        false,
        ''
      ]);
    });
    test('single short', () {
      final optDef = CliOptDef('a', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        ['a'],
        [],
        [],
        [],
        [],
        [],
        ['a'],
        [],
        true,
        false,
        ''
      ]);
    });
    test('single long', () {
      final optDef = CliOptDef('abc', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        ['abc'],
        [],
        ['abc'],
        ['noabc'],
        [],
        [],
        [],
        [],
        true,
        false,
        ''
      ]);
    });
    test('mix', () {
      final optDef = CliOptDef('a,abc', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        ['a', 'abc'],
        [],
        ['abc'],
        ['noabc'],
        [],
        [],
        ['a'],
        [],
        true,
        false,
        ''
      ]);
    });
    test('with sub-names', () {
      final optDef = CliOptDef('a,abc>d,def', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        ['a', 'abc'],
        ['d', 'def'],
        ['abc'],
        ['noabc'],
        ['def'],
        ['nodef'],
        ['a'],
        ['d'],
        true,
        false,
        ''
      ]);
    });
    test('with a single value', () {
      final optDef = CliOptDef('a,abc:', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        ['a', 'abc'],
        [],
        ['abc'],
        [],
        [],
        [],
        ['a'],
        [],
        false,
        false,
        ''
      ]);
    });
    test('with multiple values', () {
      final optDef = CliOptDef('a,abc::', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        ['a', 'abc'],
        [],
        ['abc'],
        [],
        [],
        [],
        ['a'],
        [],
        false,
        true,
        ''
      ]);
    });
    test('with multiple values and separator', () {
      final optDef = CliOptDef('a,abc:,:', caseMode);
      expect([
        optDef.names,
        optDef.subNames,
        optDef.longNames,
        optDef.negLongNames,
        optDef.longSubNames,
        optDef.negLongSubNames,
        optDef.shortNames,
        optDef.shortSubNames,
        optDef.isFlag,
        optDef.hasManyValues,
        optDef.valueSeparator
      ], [
        ['a', 'abc'],
        [],
        ['abc'],
        [],
        [],
        [],
        ['a'],
        [],
        false,
        true,
        ','
      ]);
    });
  });
}
