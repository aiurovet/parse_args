// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:parse_args/parse_args.dart';
import 'package:thin_logger/thin_logger.dart';

/// Pretty basic singleton for simple FileSystem
///
final _fs = LocalFileSystem();

/// Pretty basic singleton for simple logging
///
final _logger = Logger();

/// Simple filtering class
///
class Filter {
  bool isPositive;
  Glob glob;

  Filter(this.glob, this.isPositive);

  @override
  String toString() => '${isPositive ? glob : '!($glob)'}';
}

/// Application options
///
class Options {
  /// Application name
  ///
  static const appName = 'sampleapp';

  /// Application version
  ///
  static const appVersion = '0.1.2';

  /// Access (octal)
  ///
  int get access => _access;
  var _access = 0;

  /// Application configuration path
  ///
  String get appConfigPath => _appConfigPath;
  var _appConfigPath = '';

  /// Compression level
  ///
  int get compression => _compression;
  var _compression = 6;

  /// List of lists of filters
  ///
  List<List<Filter>> get filterLists => _filterLists;
  final _filterLists = <List<Filter>>[];

  /// Force otherwise incremental processing
  ///
  bool get isForced => _isForced;
  var _isForced = false;

  /// List of input files
  ///
  List<String> get inputFiles => _inputFiles;
  final _inputFiles = <String>[];

  /// List of output files
  ///
  List<String> get outputFiles => _outputFiles;
  final _outputFiles = <String>[];

  /// Directory to start in (switch to at the beginning)
  ///
  List<String> get plainArgs => _plainArgs;
  var _plainArgs = <String>[];

  /// Directory to start in (switch to at the beginning)
  ///
  get startDirName => _startDirName;
  var _startDirName = '';

  /// Sample application's command-line parser
  ///
  Future parse(List<String> args) async {
    final ops = 'and,not,or,case';

    final optDefStr = '''
|q,quiet|v,verbose|?,h,help|access:,:|d,dir:|app-config:|f,force|p,compression:
|l,filter::>$ops
|i,inp,inp-files:,:
|o,out,out-files:,:
|::>$ops
''';

    final result = parseArgs(optDefStr, args, validate: true);

    if (result.isSet('help')) {
      usage();
    }

    if (result.isSet('quiet')) {
      _logger.level = Logger.levelQuiet;
    } else if (result.isSet('verbose')) {
      _logger.level = Logger.levelVerbose;
    }

    _logger.out('Parsed ${result.toString()}\n');

    _appConfigPath =
        _fs.path.join(_startDirName, result.getStrValue('appconfig'));
    _access = result.getIntValue('access', radix: 8) ?? 420 /* octal 644 */;
    _compression = result.getIntValue('compression') ?? 6;
    _isForced = result.isSet('force');
    _plainArgs = result.getStrValues('');

    setFilters(result.getStrValues('filter'));

    final optName = '-case';

    switch (optName) {
      case '-pattern':
        break;
      case '-case':
        break;
      case '+case':
        break;
    }

    await setStartDirName(result.getStrValue('dir') ?? '');
    await setPaths(_inputFiles, result.getStrValues('inpfiles'));
    await setPaths(_outputFiles, result.getStrValues('outfiles'));

    _logger.out('''
AppCfgPath: $_appConfigPath
Compress:   $_compression
isForced:   $_isForced
PlainArgs:  $_plainArgs
StartDir:   $_startDirName
Filters:    $_filterLists
InpFiles:   $_inputFiles
OutFiles:   $_outputFiles
''');
  }

  /// Add all filters with the appropriate pattern and flags
  ///
  void setFilters(List values) {
    var isNew = true;
    var isPositive = true;
    var isCaseSensitive = true;

    for (var value in values) {
      switch (value) {
        case '-and':
          isNew = false;
          isPositive = true;
          continue;
        case '+and':
          isNew = false;
          isPositive = false;
          continue;
        case '-not':
          isPositive = false;
          continue;
        case '-or':
          isNew = true;
          isPositive = true;
          continue;
        case '+or':
          isNew = true;
          isPositive = false;
          continue;
        case '-case':
          isCaseSensitive = true;
          continue;
        case '+case':
          isCaseSensitive = false;
          continue;
        default:
          final glob = Glob(value, caseSensitive: isCaseSensitive);
          final filter = Filter(glob, isPositive);

          if (isNew || _filterLists.isEmpty) {
            _filterLists.add([filter]);
          } else {
            _filterLists[filterLists.length - 1].add(filter);
          }
          isPositive = true; // applies to a single (the next) value only
      }
    }
  }

  /// General-purpose method to add file paths to destinaltion list and check the existence immediately
  ///
  Future setPaths(List<String> to, List from, {bool isRequired = false}) async {
    for (var x in from) {
      final path = _fs.path.isAbsolute(x) ? x : _fs.path.join(_startDirName, x);
      to.add(path);

      if (isRequired && !(await _fs.file(path).exists())) {
        _logger.error('*** ERROR: Input file not found: "$path"');
      }
    }
  }

  /// General-purpose method to set start directory and check its existence immediately
  ///
  Future setStartDirName(String value, {bool isRequired = false}) async {
    _startDirName = value;

    if (isRequired && !(await _fs.directory(_startDirName).exists())) {
      _logger.error('*** ERROR: Invalid startup directory: "$_startDirName"');
    }
  }

  /// Displaying the help and optionally, an error message
  ///
  Never usage([String? error]) {
    throw Exception('''

${Options.appName} ${Options.appVersion} (c) 2022 My Name

Long description of the application functionality

USAGE:

${Options.appName} [OPTIONS]

OPTIONS (case-insensitive and dash-insensitive):

-?, -h, -[-]help                     - this help screen
-c, -[-]app[-]config FILE            - configuration file path/name
-d, -[-]dir DIR                      - directory to start in
-f, -[-]force                        - overwrite existing output file
-l, -[-]filter F1 [op] F2 [op] ...   - a list of filters with operations
                                       (-and, -not, -or, -case, -nocase)
-i, -[-]inp[-files] FILE1 [FILE2...] - the input file paths/names
-o, -[-]out[-files] FILE1 [FILE2...] - the output file paths/names
-p, -[-]compression INT              - compression level
-v, -[-]verbose                      - detailed application log

EXAMPLE:

${Options.appName} -AppConfig default.json -filter "abc" --dir somedir/Documents -inp a*.txt ../Downloads/bb.xml --out-files ../Uploads/result.txt -- -result_more.txt
${Options.appName} -AppConfig default.json -filter "abc" -and "de" -or -not "fghi" -inp b*.txt ../Downloads/c.xml --out-files ../Uploads/result.txt -- -result_more.txt

${(error == null) || error.isEmpty ? '' : '*** ERROR: $error'}
''');
  }
}

/// Sample application entry point
///
Future main(List<String> args) async {
  try {
    var o = Options();
    await o.parse(args);
    // the rest of processing
  } on Exception catch (e) {
    _logger.error(e.toString());
  } on Error catch (e) {
    _logger.error(e.toString());
  }
}
