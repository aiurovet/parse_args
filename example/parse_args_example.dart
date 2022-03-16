import 'dart:io';
import 'package:parse_args/parse_args.dart';

////////////////////////////////////////////////////////////////////////////////
// Application options
////////////////////////////////////////////////////////////////////////////////

class Options {
  static const String appName = 'sampleapp';
  static const String appVersion = '2.0.1';

  var _appConfigPath = '';
  get appConfigPath => _appConfigPath;

  var _compression = 6;
  get compression => _compression;

  var _isForced = false;
  get isForced => _isForced;

  var _isQuiet = false;
  get isQuiet => _isQuiet;

  var _isVerbose = false;
  get isVerbose => _isVerbose;

  var _startDirName = '';
  get startDirName => _startDirName;

  final _inputFiles = <String>[];
  get inputFiles => _inputFiles;

  final _outputFiles = <String>[];
  get outputFiles => _outputFiles;
}

////////////////////////////////////////////////////////////////////////////////
// Sample application's command-line parser
////////////////////////////////////////////////////////////////////////////////

void init(Options options, List<String> args) {
  int? intValue;

  parseArgs(args, (optName, values) {
    switch (optName) {
      case '?':
      case 'h':
      case 'help':
        printUsage();
      case 'c':
      case 'appconfig':
        if (values.length != 1) {
          printUsage('Unable to determine application configuration file');
        }
        options._appConfigPath = values[0];
        break;
      case 'd':
      case 'dir':
        if (values.length > 1) {
          printUsage('Unable to determine the directory to start in');
        }
        options._startDirName = values[0];
        break;
      case 'f':
      case 'force':
        options._isForced = true;
        break;
      case 'i':
      case 'in':
      case 'input':
        options._inputFiles.addAll(values);
        break;
      case 'o':
      case 'out':
      case 'output':
        options._outputFiles.addAll(values);
        break;
      case 'p':
      case 'compression':
        if (values.length != 1) {
          printUsage('Unable to determine compression');
        }
        intValue = int.tryParse(values[0]);
        if (intValue == null) {
          printUsage('Invalid compression value: ${values[0]}');
        }
        options._compression = intValue ?? options._compression;
        break;
      case 'q':
      case 'quiet':
      case 'v':
      case 'verbose':
        // All logging options were parsed already
        break;
      default:
        if (optName.isEmpty) {
          printUsage('${Options.appName} does not support plain arguments');
        } else {
          printUsage('Invalid option: "$optName"');
        }
    }
    return true; // continue
  });
}

////////////////////////////////////////////////////////////////////////////////
// Sample application's logging command-line options parser
//
// This needs to be done before the rest of the application options parsing in
// order to ensure all logging complies the options passed
////////////////////////////////////////////////////////////////////////////////

void initLogging(Options options, List<String> args) {
  parseArgs(args, (optName, values) {
    switch (optName) {
      case 'q':
      case 'quiet':
        options._isQuiet = true;
        break;
      case 'v':
      case 'verbose':
        options._isVerbose = true;
        break;
    }
    return true;
  });
}

////////////////////////////////////////////////////////////////////////////////
// Sample application entry point
////////////////////////////////////////////////////////////////////////////////

void main(List<String> args) {
  var options = Options();

  initLogging(options, args);
  init(options, args);

  // the rest of processing
}

////////////////////////////////////////////////////////////////////////////////
// Sample application entry point
////////////////////////////////////////////////////////////////////////////////

Never printUsage([String? error]) {
  stderr.writeln('''

${Options.appName} ${Options.appVersion} (c) My Name 2022

Long description of the application functionality

USAGE:

${Options.appName} [OPTIONS]

OPTIONS (case-insensitive and dash-insensitive):

-?, -h, -help                      - this help screen
-c, --app-config FILE              - configuration file path/name
-d, --dir DIR                      - directory to start in
-f, --force                        - overwrite existing output file
-i, --in[put]  FILE1, [FILE2, ...] - the input file paths/names
-o, --out[put] FILE1, [FILE2, ...] - the output file paths/names
-p, --compression INT              - compression level
-v, --verbose                      - detailed application log

EXAMPLE:

${Options.appName} -AppConfig default.json --dir somedir/Documents -in a*.txt ../Downloads/bb.xml --output ../Uploads/result.txt -- -result_more.txt

${(error == null) || error.isEmpty ? '' : '*** ERROR: $error'}
''');

  exit(1);
}
