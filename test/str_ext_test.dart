// Copyright (c) 2022-2023, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:parse_args/src/str_ext.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  group('unquote -', () {
    test('empty', () {
      expect(''.unquote(), '');
    });
    test('empty single-quoted', () {
      expect("''".unquote(), '');
    });
    test('empty double-quoted', () {
      expect('""'.unquote(), '');
    });
    test('non-empty single-quoted', () {
      expect(r"'ab\ncd'".unquote(), r'ab\ncd');
    });
    test('non-empty double-quoted', () {
      expect(r'"ab\ncd"'.unquote(), r'ab\ncd');
    });
  });
}
