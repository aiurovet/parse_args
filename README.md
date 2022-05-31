A getopts-like Dart package to parse command-line options simple way and in a portable style (bash, find, java, PowerShell), plus, sub-options (see below)

## Features

- Comprises a function `parseArgs` and several custom exception classes.

- The function recognises options, i.e. any word starting with dashes `-` followed by an English letter. It then accumulates all possible values (every arg until the next option), validates against the user-defined format and executes a caller-defined function.

- It might either accept any option and treat all its possible values as strings (compatibility with the older versions) or validate those using an options definitions string (the first parameter). This string can be multi-line, as all blank characters will get removed. Let's have a look at an example of such string:

```
+|q,quiet|v,verbose|?,h,help|d,dir:|c,app-config:|f,force|p,compression:i
 |l,filter:: > and,c,-case,--no-case,^,not, or 
 |i,inp,inp-files::
 |o,out,out-files::
 ```

- Every option definition is separated by the pipe `|` character.
- If the whole string starts with `+|`, it means we need an extra run through the list of arguments. For instance, getting a list of input files, you'd like to know what is the start-in directory (if you allow that as an option too).
- You can pass multiple option names: as many as you wish. The user-defined handler called in a loop for every option with its values detected in the arguments. The handler is guaranteed to be called for every option in the order of their appearance in the definitions string. It will be receiving the last name of each option (most likely, it will be the longest and the most descriptive one). That name will be normalized: all spaces and dashes removed, the rest converted to lowercase.
- At the end of the name list for a given option add a single colon `:` if you expect a value. And in the case of one or more values, double that.
- The value indicator list might be followed by the value type: `b` - binary int, `f` - double-precision float, `h` - hexadecimal int, `i` - decimal int, `o` - octal int. The default is string.
- If an option definition contains `>`, the rest (until the next `|` or the end of string) will be considered as a comma-separated list of _sub-options_. For instance, you need to pass multiple filter strings as values of some option. Some filters might require case-sensitive comparison, and some - case-insensitive, some might require straight match, and some - the opposite match (not found):

  `myapp -filter -case "Ab" "Cd" --no-case "xyz" -not "uvw"`

  The array of values for the option "filter" will be: \["-case", "Ab", "Cd", "-nocase", "xyz", "-not", "uvw"\]. This allows you to traverse through the list elements and turn some flags on or off when a sub-option encountered (a string which starts with a single dash folloowed by an English letter). Certainly, one can argue that it is possible to introduce 4 different options and achieve the same result. But firstly, this is a simple example. And secondly, in the latter case, you'll also have to deal with the sequence of "extras" like: --filter-case-not should be equivalent to --filter-not-case, etc. Things can get really ugly without sub-options.

- The function allows a 'weird' and even an 'incorrect' way of passing multiple option values. However, this simplifies the case and makes obsolete the need to have plain arguments (the ones without an option). You can override this behaviour by passing the value separator. It will force to split just the next argument after an option instead of accumulating all arguments before the next option. You can pass plain arguments, but you should place those in front of the first option.

- The function allows specifying values for the same option in multiple places as follows: -a 1 2 -b -c 3 -a 4 5 6 (an option -a will get an array of values \[1, 2, 4, 5, 6\])

- The function allows an equal sign: -name=\["'\]value\["'\] or -name=\["'\]value1,value2,...\["'\]. And still, the separate plain arguments straight after will be considered as additional values of that option.

- The function interprets double-dash `--` as a flag meaning that any argument beyond this point will be treated as plain argument under no option.

- The function interprets triple-dash `---` as a flag meaning that no more argument should be treated as an option name, but rather added as a value to the last option.

- The function does not allow bundling for short (single-character) option names, but this generally encourages the use of long option names for better clarity.

- The function also does not support negation by the use of plus `+` rather than dash `-`.

## Usage

The same can be found in the `example` folder of the GitHub repository.

```dart
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
        case '-a':
        case '-and':
          isNew = false;
          break;
        case '-c':
        case '-case':
          isCaseSensitive = true;
          break;
        case '-i':
        case '-nocase':
          isCaseSensitive = false;
          break;
        case '-n':
        case '-not':
          isPositive = false;
          break;
        case '-o':
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
    final ops = 'a,and,c,-case, i,--no-case,n,not, o,  or ';

    parseArgs('''
+|q,quiet|v,verbose|?,h,help|d,dir:|c,app-config:|f,force|p,compression:i
 |l,filter:: > $ops
 |i,inp,inp-files::
 |o,out,out-files::
 |::> $ops
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
```
