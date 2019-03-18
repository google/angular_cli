// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import '../generators/test.dart';
import '../path_util.dart';
import 'command.dart';

/// Handles the `generate test` ngdart command.
class GenerateTestCommand extends NgDartCommand {
  static const _classOption = 'class';
  static const _testPathOption = 'path';
  static const _tagOption = 'tag';

  String get name => 'test';
  String get description => 'Generate AngularDart component test, '
      'this command should be run under root directory of the project.';
  String get invocation => '${NgDartCommand.binaryName} generate test '
      '<component/file/path> [--class <class name>] [--path <test/file/path>] '
      '[--tag <test tag>]';

  String get _classUnderTest => argResults[_classOption];
  String get _testPath => getNormalizedPath(argResults[_testPathOption]);
  String get _testTag => argResults[_tagOption];

  GenerateTestCommand() {
    argParser.addOption(_classOption,
        abbr: 'c',
        help: 'Angular component class to be tested. '
            'Will select one from the specified file if it is null.',
        defaultsTo: null);
    argParser.addOption(_testPathOption,
        abbr: 'p', help: 'Test file path', defaultsTo: 'test');
    argParser.addOption(_tagOption,
        help: 'Tag for the test', defaultsTo: 'aot');
  }

  Future run() async {
    await TestGenerator(
            _testTag,
            readArg('path for Angular component file is needed.'),
            _classUnderTest,
            _testPath)
        .generate();
  }
}
