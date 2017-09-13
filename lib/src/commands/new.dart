// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import '../generators/project.dart';
import 'command.dart';

/// Handles the `new` ngdart command.
class NewProjectCommand extends NgDartCommand {
  static const _rootComponentOption = 'root_component';
  static const _pathOption = 'path';

  String get name => 'new';
  String get description => 'Create an AngularDart project.';
  String get invocation => '${NgDartCommand.binaryName} new <project_name> '
      '[--path <project/path>] [--root_component <RootComponentName>]';

  String get _rootComponent => argResults[_rootComponentOption];
  String get _projectPath =>
      NgDartCommand.getNormalizedPath(argResults[_pathOption]);

  NewProjectCommand() {
    argParser.addOption(_pathOption,
        abbr: 'p',
        help: 'Project path, '
            'a new folder will be created unde this path for the project.',
        defaultsTo: '.');
    argParser.addOption(_rootComponentOption,
        abbr: 'r',
        help: 'Class name of root component.',
        defaultsTo: 'AppComponent');
  }

  Future run() async {
    await new ProjectGenerator(readArgAsEntityName('Project name is needed.'),
            _projectPath, getEntityName(_rootComponent))
        .generate();
  }
}
