// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import '../generators/directive.dart';
import '../path_util.dart';
import 'command.dart';

/// Handles the `generate directive` ngdart command.
class GenerateDirectiveCommand extends NgDartCommand {
  static const _pathOption = 'path';

  String get name => 'directive';
  String get description => 'Generate AngularDart directive.';
  String get invocation => '${NgDartCommand.binaryName} generate directive '
      '<DirectiveName> [--path <directive/file/path>]';

  String get _directivePath => getNormalizedPath(argResults[_pathOption]);

  GenerateDirectiveCommand() {
    argParser.addOption(_pathOption,
        abbr: 'p', help: 'Directive file path', defaultsTo: 'lib');
  }

  Future run() async {
    await new DirectiveGenerator(
            readArgAsEntityName('Directive name is needed.'), _directivePath)
        .generate();
  }
}
