// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:parse_args/parse_args.dart';

/// Simple filtering class
///
class Filter {
  bool isCaseSensitive;
  bool isPositive;
  String pattern;

  Filter(this.pattern, this.isPositive, this.isCaseSensitive);

  @override
  String toString() =>
      '${isPositive ? '' : '!'}${isCaseSensitive ? '' : 'i'}"$pattern"';
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

  /// Application configuration path
  ///
  get appConfigPath => _appConfigPath;
  var _appConfigPath = '';

  /// Compression level
  ///
  get compression => _compression;
  var _compression = 6;

  /// List of lists of filters
  ///
  get filterLists => _filterLists;
  final _filterLists = <List<Filter>>[];

  /// Force otherwise incremental processing
  ///
  get isForced => _isForced;
  var _isForced = false;

  /// Quiet mode (no print)
  ///
  get isQuiet => _isQuiet;
  var _isQuiet = false;

  /// Verbose mode (print extra detailed info)
  ///
  var _isVerbose = false;
  get isVerbose => _isVerbose;

  /// List of input files
  ///
  get inputFiles => _inputFiles;
  final _inputFiles = <String>[];

  /// List of output files
  ///
  get outputFiles => _outputFiles;
  final _outputFiles = <String>[];

  /// Directory to start in (switch to at the beginning)
  ///
  get startDirName => _startDirName;
  var _startDirName = '';

  /// Add next filter with the appropriate pattern and flags
  ///
  void addFilter(
      String pattern, bool isPositive, bool isCaseSensitive, bool isNew) {
    final filter = Filter(pattern, isPositive, isCaseSensitive);

    if (isNew || _filterLists.isEmpty) {
      _filterLists.add(<Filter>[filter]);
    } else {
      _filterLists[filterLists.length - 1].add(filter);
    }
  }

  /// Add all filters with the appropriate pattern and flags
  ///
  void addFilters(List values) {
    var isCaseSensitive = true;
    var isNew = true;
    var isPositive = true;

    for (var value in values) {
      switch (value) {
        case '-and':
          isNew = false;
          break;
        case '-case':
          isCaseSensitive = true;
          break;
        case '-i':
        case '-nocase':
          isCaseSensitive = false;
          break;
        case '-not':
        case '-^':
          isPositive = false;
          break;
        case '-or':
          isNew = true;
          break;
        default:
          addFilter(value, isPositive, isCaseSensitive, isNew);
          isPositive = true; // applies to a single (the next) value only
      }
    }
  }

  /// General-purpose method to add file paths to destinaltion list
  ///
  void addPaths(List<String> to, List from) {
    for (var x in from) {
      to.add(p.isAbsolute(x) ? x : p.join(_startDirName, x));
    }
  }

  /// Sample application's command-line parser
  ///
  void parse(List<String> args) {
    final ops = 'and,c,-case,--no-case,^,not, or ';

    parseArgs('''
+|q,quiet|v,verbose|?,h,help|d,dir:|c,app-config:|f,force|p,compression:i
 |l,filter:: > $ops
 |i,inp,inp-files::
 |o,out,out-files::
''', args, (isFirstRun, optName, values) {
      if (isFirstRun) {
        switch (optName) {
          case 'compression':
            _compression = values[0];
            return;
          case 'help':
            printUsage();
          case 'dir':
            _startDirName = values[0];
            return;
          case 'force':
            _isForced = true;
            return;
          case 'quiet':
            _isQuiet = true;
            return;
          case 'verbose':
            _isVerbose = true;
            return;
          default:
            return;
        }
      } else {
        printVerbose('Parsing $optName => $values');

        // No need to assign any option value which does not depend on another one, just
        // printing the info. Essentially, these cases can be omitted for the second run
        //
        switch (optName) {
          case '':
            printInfo('...plain arg count: ${values.length}');
            return;
          case 'appconfig':
            _appConfigPath = p.join(_startDirName, values[0]);
            printInfo('...appConfigPath: $_appConfigPath');
            return;
          case 'compression':
            printInfo('...compression: $_compression');
            return;
          case 'dir':
            printInfo('...startDirName: $_startDirName');
            return;
          case 'force':
            printInfo('...isForced: $_isForced');
            return;
          case 'filter':
            addFilters(values);
            printInfo('...filter(s): $_filterLists');
            return;
          case 'inpfiles':
            addPaths(_inputFiles, values);
            printInfo('...inp file(s): $_inputFiles');
            return;
          case 'outfiles':
            addPaths(_outputFiles, values);
            printInfo('...out file(s): $_outputFiles');
            return;
          case 'quiet':
            printInfo('...quiet: $_isQuiet');
            return;
          case 'verbose':
            printInfo('...verbose: $_isVerbose');
            return;
          default:
            return;
        }
      }
    });
  }

  /// A very simple info logger
  ///
  void printInfo(String line) {
    if (!_isQuiet) {
      print(line);
    }
  }

  /// A very simple verbose logger
  ///
  void printVerbose(String line) {
    if (!_isQuiet && _isVerbose) {
      print(line);
    }
  }

  /// Displaying the help and optionally, an error message
  ///
  Never printUsage([String? error]) {
    stderr.writeln('''

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

    exit(1);
  }
}

/// Sample application entry point
///
void main(List<String> args) {
  try {
    var o = Options();
    o.parse(args);
    // the rest of processing
  } on Exception catch (e) {
    stderr.writeln(e.toString());
  } on Error catch (e) {
    stderr.writeln(e.toString());
  }
}
