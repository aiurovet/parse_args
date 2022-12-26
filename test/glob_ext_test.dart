// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:file/local.dart';
import 'package:parse_args/src/glob_ext.dart';
import 'package:test/test.dart';

/// The main entry point for tests
///
void main() {
  var fs = LocalFileSystem();

  group('create -', () {
    test('null', () {
      var g = GlobExt.create(fs, null);
      expect(g.pattern, '*');
    });
    test('empty', () {
      var g = GlobExt.create(fs, '');
      expect(g.pattern, '*');
    });
    test('case-sensitivity', () {
      var g = GlobExt.create(fs, 'A');
      expect(g.caseSensitive, !fs.path.equals('A', 'a'));
    });
    test('recursive #1', () {
      var g = GlobExt.create(fs, '**');
      expect(g.recursive, true);
    });
    test('recursive #2', () {
      var g = GlobExt.create(fs, '*/');
      expect(g.recursive, true);
    });
    test('recursive #3', () {
      var g = GlobExt.create(fs, '?/');
      expect(g.recursive, true);
    });
  });
}
