// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import '../generators/component.dart';
import '../path_util.dart';
import 'command.dart';

/// Handles the `generate component` ngdart command.
class GenerateComponentCommand extends NgDartCommand {
  static const _pathOption = 'path';

  String get name => 'component';
  String get description => 'Generate AngularDart component.';
  String get invocation => '${NgDartCommand.binaryName} generate component '
      '<ComponentName> [--path <component/file/path>]';

  String get _componentPath => getNormalizedPath(argResults[_pathOption]);

  GenerateComponentCommand() {
    argParser.addOption(_pathOption,
        abbr: 'p', help: 'Component file path', defaultsTo: 'lib/src');
  }

  Future run() async {
    await new ComponentGenerator(
            readArgAsEntityName('Component name is needed.'), _componentPath)
        .generate();
  }
}
