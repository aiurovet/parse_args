// Copyright (c) 2022, Alexander Iurovetski
// All rights reserved under MIT license (see LICENSE file)

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:parse_args/parse_args.dart';

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

  /// Directory to start in (switch to at the beginning)
  ///
  get startDirName => _startDirName;
  var _startDirName = '';

  /// The list of input files
  ///
  get inputFiles => _inputFiles;
  final _inputFiles = <String>[];

  /// The list of output files
  ///
  get outputFiles => _outputFiles;
  final _outputFiles = <String>[];

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
    parseArgs('''
+|q,quiet|v,verbose|?,h,help|d,dir:|c,app-config:|f,force
 |i,inp,inp-files::|o,out,out-files::|p,compression:i|::
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
-i, -[-]inp[-files] FILE1 [FILE2...] - the input file paths/names
-o, -[-]out[-files] FILE1 [FILE2...] - the output file paths/names
-p, -[-]compression INT              - compression level
-v, -[-]verbose                      - detailed application log

EXAMPLE:

${Options.appName} -AppConfig default.json --dir somedir/Documents -inp a*.txt ../Downloads/bb.xml --out-files ../Uploads/result.txt -- -result_more.txt

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
