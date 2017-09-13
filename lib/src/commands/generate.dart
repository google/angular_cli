// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'command.dart';
import 'generate_component.dart';
import 'generate_test.dart';

/// Handles the `generate` ngdart command.
class GenerateCommand extends NgDartCommand {
  String get name => 'generate';
  String get description => 'Generate component or test.';
  String get invocation => '${NgDartCommand.binaryName} generate <subcommand>';

  GenerateCommand() {
    addSubcommand(new GenerateComponentCommand());
    addSubcommand(new GenerateTestCommand());
  }
}
