A getopts-like Dart package to parse command-line options simple way and in a portable style (bash, find, java, PowerShell), plus, sub-options (see below)

## Features

- Comprises functions `parseArgs` and `parseSubCmd` as well as several helper classes including custom exceptions.

- The function `parseSubCmd` takes a list of command-line arguments and a map `<String, Function>{}`. It checks the first command-line argument only. If that one is a plain argument (i.e. does not start with a dash `-` or plus `+`), it will be treated as a key in the map, and the associated function will be executed. Every such function will receive the list of the rest arguments, and typically will call `parseArgs` to parse secific set of options and their values.

- The function `parseArgs` recognises options, i.e. any words starting with one or more dashes `-` or pluses `+` followed by an English letter, then by other characters. It accumulates all possible values (every arg until the next option), validates against the user-defined format and creates result collections for further consume.

- It validates user-specified options and values using an options definitions string (the first parameter). This string can be multi-line, as all blank characters will get removed. Let's have a look at an example of such string:

```
|q,quiet|v,verbose|?,h,help|d,dir:|c,app-config:|f,force|p,compression:
|l,filter:: >and,c,case   not,  or 
|i,inp,inp-files:,:
|o,out,out-files:,:
|::
```

- Every option definition is separated by the pipe `|` character.

- Plain arguments are treated as values of an option with an empty name.

- If a command-line argument starts with plus `+` or with `-no`, it will be treated as a negative option, unless you define the long one as an option like `north`. In that case, it will not be converted to the negatve `rth`. Please note that only flags (options without values) can be negative.

- By specifying a colon `:` you require the respective option to have a single argument

- By specifying a double-colon `::` you require the respective option to have one or more arguments: `-inp-file abc.txt de.lst fghi.docx`

- By specifying a double-colon with a comma `:,:` inside, you require the following argument to represent a list of values which should be split by comma. The absense of comma means a single value. No more value will be linked to this option. You can use any other character instead of a comma except a pipe and a colon. Example: `-inp-file abc.txt,de.lst fghi.docx` results in two values for the option `-inp-file` followed by one plain argument. The same is achieved by `-inp-file=abc.txt,de.lst fghi.docx`. But `-inp-file abc.txt de.lst,fghi.docx` results in one value for the option `-inp-file` followed by one or two plain arguments depending on whether plain arguments have a value separator too. This discourages mixed lists where sometimes option values are passed as separate arguments, and sometimes as a list of delimited values. However, the list of plain arguments will grow regardless the presence of a value separator.

- You can specify multiple option names.

- Every option name gets normalized: all possible spaces, dashes `-` and pluses `+` (for the negative flags) are removed, all letters converted to the desired case: `exact` (no conversion), `lower` (lowercase, i.e. case-insensitive) or `smart` (exact for short options, and lower for the long ones).

- Short options and sub-options can be bundled: `-c -l -i` is the same as `-cli`, the order of appearance doesn't matter for options, but does matter for sub-options.

- The function `parseArgs` returns an object of the type `List<CliOpt>`. The methods of the extension class `CliOptList` are used to retrieve one or more values and convert those to the required data type: `isSet(optName)`, `getIntValues(optName, {radix})`, `getDateValues(optName)`, `getStrValues(optName)`

- If an option definition contains `>`, the rest (up to the next `|` or the end of the string) will be considered as a comma-separated list of _sub-options_. These will be treated as plain values relying on the caller's interpretation. For instance, you need to pass multiple filter strings as values of some option. Some filters might require case-sensitive comparison, and some - case-insensitive, some might require straight match, and some - the opposite match (not found):

  `myapp -filter -case "Ab" "Cd" --no-case "xyz" -not "uvw"`

The array of values for the option `-filter` will be: `["-case", "Ab", "Cd", "+case", "xyz", "-not", "uvw"]`. This allows you to traverse through the elements and turn some flags on or off when a sub-option encountered. Certainly, one can argue that it is possible to introduce 4 different options and achieve the same result. But firstly, this is a simple example. And secondly, in the latter case, you'll also have to deal with the sequence of permutation extras like: --filter-case-not should be equivalent to --filter-not-case, etc. Things can get really ugly without sub-options.

- The function allows a 'weird' (or even 'incorrect') way of passing multiple option values. However, this simplifies the case and makes obsolete the need to have plain arguments (the ones without an option). You can override this behaviour by the use of the value separator or by the use of an equal sign: `-a="1,2" 3 4 -b -c 5` (option `-a` gets `["1", "2"]`, `-c` gets `["5"]`, and `["3", "4"]` will be considered as plain arguments.

- If you wish to pass plain arguments, you should specify that in the options definition string explicitly. The format is the same as for options, but the  option name should be empty: `|:`, `|::`, `|::>and,or` (the latter allows sub-options for plain arguments).

- The function allows an equal sign: `-name="value"` or `-name='value'`. However, the separate plain arguments straight after this one will NOT be considered as additional values of that option, but rather as plain arguments. Even if an option is defined as the one allowing multiple values, and no value separator is defined.

- The function interprets a standalone double-dash `--` as a flag meaning that any argument beyond this point will be treated as plain argument (no option).

- The function interprets triple-dash `---` as a flag meaning that no more argument should be treated as an option name, but rather added as a value to the last encountered option.

- The function allows bundling for short (single-character) option names. There is a method `testNames` of `CliOptDef` and of `CliOptDefList` which can be called from unit tests to ensure all option and sub-option names are unique as well as no long option name can be treated as a combination of short options names.

## Usage

The same can be found in the `example/parse_args_example.dart` (there is also another example on the use of sub-commands).

```dart
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
```
