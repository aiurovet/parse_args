// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:file/local.dart';
import 'package:parse_args/parse_args.dart';
import 'package:thin_logger/thin_logger.dart';

/// Pretty basic singleton for simple FileSystem
///
final _fs = LocalFileSystem();

/// Pretty basic singleton for simple logging
///
final _logger = Logger();

/// Application options
///
class Options {
  /// Flag indicating Dart CDK
  ///
  late final bool isLangDart;

  /// Flag indicating Golang CDK
  ///
  late final bool isLangGo;

  /// Flag indicating Python CDK
  ///
  late final bool isLangPython;

  /// Flag indicating Rust CDK
  ///
  late final bool isLangRust;

  /// Flag indicating Typescript CDK
  ///
  late final bool isLangTS;

  /// Flag indicating AWS deployment
  ///
  late final bool isToAws;

  /// Flag indicating Azure deployment
  ///
  late final bool isToAzure;

  /// Flag indicating Google Cloud deployment
  ///
  late final bool isToGoogle;

  /// Flag indicating Oracle Cloud deployment
  ///
  late final bool isToOracle;

  /// Directory where the source files located
  ///
  late final String srcDirName;

  /// Parse sub-commands and their arguments
  ///
  void parse(List<String> args) => parseSubCmd(args, map: {
        'language': parseArgsLanguage,
        'publish': parseArgsPublish,
      });

  /// Parse sub-command `language` and its arguments
  ///
  void parseArgsLanguage(List<String> args) {
    final result = parseArgs(
        '?,h,help|d,dart|D,dir:|g,go,golang|p,py,python|r,rs,rust|t,ts', args,
        validate: true);

    if (result.isSet('help')) {
      usageLanguage();
    }

    isLangDart = result.isSet('dart');
    isLangGo = !isLangDart && result.isSet('golang');
    isLangPython = !isLangGo && result.isSet('python');
    isLangRust = !isLangPython && result.isSet('rust');
    isLangTS = !isLangRust && result.isSet('ts');

    if (!isLangDart && !isLangGo && !isLangPython && !isLangRust && !isLangTS) {
      usageLanguage('Undefined language');
    }

    srcDirName = result.getStrValue('dir') ?? _fs.currentDirectory.path;

    _logger.out('''

Launch program written in ${isLangDart ? 'Dart' : isLangGo ? 'Go' : isLangPython ? 'Python' : isLangRust ? 'Rust' : isLangTS ? 'TypeScript' : 'Unknown language'}
Directory:  ${srcDirName.isEmpty ? '(none)' : '"$srcDirName"'}
''');
  }

  /// Parse sub-command `publish` and its arguments
  ///
  void parseArgsPublish(List<String> args) {
    final result = parseArgs(
        '?,h,help|a,amazon,aws|A,azure|g,gcp|o,ora,oracle', args,
        validate: true);

    if (result.isSet('help')) {
      usagePublish();
    }

    isToAws = result.isSet('aws');
    isToAzure = result.isSet('azure');
    isToGoogle = result.isSet('gcp');
    isToOracle = result.isSet('oracle');

    if (!isToAws && !isToAzure && !isToGoogle && !isToOracle) {
      usagePublish('Unable to figure out the platform to publish to');
    }

    var platforms = ((isToAws ? ', AWS' : '') +
            (isToAzure ? ', Azure' : '') +
            (isToGoogle ? ', GCP' : '') +
            (isToOracle ? ', Oracle' : ''))
        .substring(2);

    _logger.out('\nPublish to: $platforms');
  }

  /// Displaying the help and optionally, an error message
  ///
  Never usageLanguage([String? error]) => throw Exception('''

OPTIONS for publish (case-insensitive and dash-insensitive):

-?, -h, -[-]help         - this help screen
-d, -[-]dart             - write in Dart
-g, -[-]go, -[-]golang   - write in Go
-r, -[-]rs, -[-]rust     - write in Rust
-D, -[-]dir              - source directory

EXAMPLE:

<exe> language -dart
<exe> language -rD lib/src

${(error == null) || error.isEmpty ? '' : '*** ERROR: $error'}
''');

  /// Displaying the help and optionally, an error message
  ///
  Never usagePublish([String? error]) => throw Exception('''

OPTIONS for publish (case-insensitive and dash-insensitive):

-?, -h, -[-]help         - this help screen
-a, -[-]amazon, -[-]aws  - publish to AWS
-A, -[-]azure            - publish to Microsoft Azure
-g, -[-]gcp, -[-]google  - publish to Google Cloud
-o, -[-]ora, -oracle     - publish to Oracle Cloud

EXAMPLE:

<exe> publish -aws
<exe> publish -A

${(error == null) || error.isEmpty ? '' : '*** ERROR: $error'}
''');
}

/// Sample application entry point
///
Future main(List<String> args) async {
  try {
    var o = Options();
    o.parse(args);
  } on Exception catch (e) {
    _logger.error(e.toString());
  } on Error catch (e) {
    _logger.error(e.toString());
  }
}
