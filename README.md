A getopts-like Dart package to parse command-line options simple way and in a portable style (bash/find/java/PowerShell).

## Features

Comprises a single function `parseArgs` which does the only thing: it recognises options, i.e. any word prefixed with а dash `-`, then accumulates all possible values (every arg until the next option), validates against the user-defined format and calls a user-defined function handler.

The rest is imposed on the application. You don't need to define every option separately (either as a member attribute or as some collection element), you can specify as many names for each option as you like, you can specify the type of each option value.

Every option name is passed lowercased as well as stripped off any leading or trailing space and dash. This allows specifying option names either as `-i` or `--inp-files` (default bash-like), `-inpfiles` (find- and java-like) or as `-InpFiles` (PowerShell-like).

The function allows a bit 'weird' and even 'incorrect' way of passing multiple option values. This, however, simplifies the case and makes obsolete the need to have plain arguments (the ones without an option). You can still have plain arguments, but you should place those in front of the first option.

The function does not allow bundling for short (single-character) option names, but this generally encourages the use of long option names.

The function also does not support negation by the use of plus `+` rather than dash `-`.

## Special features

You are guaranteed the arguments will be processed in the order of appearance in the option definitions (i.e. the outer loop is through the option definitions, and the inner one is through the actual arguments).

It comes in handy if you allow passing an option for the logging mode (like _quiet_ or _verbose_), as it might impact even the process of parsing options itself. So you simply define those before the others.

Or you'd like to ensure that the start-in directory will be processed before the filenames/subpaths.

## Usage

The same can be found in the `example` folder of the GitHub repository.

```
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:parse_args/parse_args.dart';

/// Application options

class Options {
  static const appName = 'sampleapp';
  static const appVersion = '2.0.1';

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

  /// General-purpose method to add file paths to destinaltion list

  void addPaths(List<String> to, List from) {
    for (var x in from) {
      to.add(p.isAbsolute(x) ? x : p.join(_startDirName, x));
    }
  }

  /// Sample application's command-line parser

  void parse(List<String> args) {
    parseArgs('+|q,quiet|v,verbose|?,h,help|c,appconfig:|d,dir:|f,force|i,inp,input::|o,out,output::|p,compression:i',
              args, (isFirstRun, optName, values) {
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
            break;
          case 'quiet':
            _isQuiet = true;
            return;
          case 'verbose':
            _isVerbose = true;
            return;
          default:
            return;
        }
      }
      else {
        printVerbose('Parsing $optName => $values');

        // No need to assign any option value here if it does not depend on another option value
        // In this case, just print the info

        switch (optName) {
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
            break;
          case 'input':
            addPaths(_inputFiles, values);
            printInfo('...inp file(s): $_inputFiles');
            return;
          case 'output':
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

  void printInfo(String line) { if (!_isQuiet) { print(line); } }

  /// A very simple verbose logger

  void printVerbose(String line) { if (!_isQuiet && _isVerbose) { print(line); } }

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
```
