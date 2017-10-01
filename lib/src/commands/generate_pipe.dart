import 'dart:async';

import '../generators/pipe.dart';
import '../path_util.dart';
import 'command.dart';

/// Handles the `generate pipe` ngdart command.
class GeneratePipeCommand extends NgDartCommand {
  static const _pathOption = 'path';

  String get name => 'pipe';
  String get description => 'Generate AngularDart pipe.';
  String get invocation => '${NgDartCommand.binaryName} generate pipe '
      '<PipeName> [--path <pipe/file/path>]';

  String get _pipePath => getNormalizedPath(argResults[_pathOption]);

  GeneratePipeCommand() {
    argParser.addOption(_pathOption,
        abbr: 'p', help: 'Pipe file path', defaultsTo: 'lib');
  }

  Future run() async {
    await new PipeGenerator(
            readArgAsEntityName('Pipe name is needed.'), _pipePath)
        .generate();
  }
}
