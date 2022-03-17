import 'dart:io';
import 'package:parse_args/parse_args.dart';

/// Application options

class Options {
  static const appName = 'sampleapp';
  static const appVersion = '2.0.1';
  static const optDefStr = '?,h,help|q,quiet|v,verbose||c,appconfig:|d,dir:|f,force|i,inp,input::|o,out,output::|p,compression:i';

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

  /// Sample application's command-line parser

  void parse(List<String> args) {
    parseArgs(optDefStr, args, (optName, values) {
      switch (optName) {
        case '':
          if (optName.isEmpty) {
            printUsage('${Options.appName} does not support plain arguments');
          }
          break;
        case '?':
        case 'h':
        case 'help':
          printUsage();
        case 'c':
        case 'appconfig':
          _appConfigPath = values[0];
          break;
        case 'd':
        case 'dir':
          _startDirName = values[0];
          break;
        case 'f':
        case 'force':
          _isForced = true;
          break;
        case 'i':
        case 'inp':
        case 'input':
          _inputFiles.addAll(values as List<String>);
          break;
        case 'o':
        case 'out':
        case 'output':
          _outputFiles.addAll(values as List<String>);
          break;
        case 'p':
        case 'compression':
          _compression = values[0];
          break;
        case 'q':
        case 'quiet':
          _isQuiet = true;
          break;
        case 'v':
        case 'verbose':
          _isVerbose = true;
          break;
        default:
          break;
      }
    });
  }

  /// Displaying the help and optionally, an error message

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
}

/// Sample application entry point

void main(List<String> args) {
  try {
    var o = Options();
    o.parse(args);

    // the rest of processing
  } on OptException catch (e) {
    e.print();
  } on Exception catch (e) {
    stderr.writeln(e.toString());
  } on Error catch (e) {
    stderr.writeln(e.toString());
  }
}
