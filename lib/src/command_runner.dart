// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import 'package:args/command_runner.dart';

import 'app_logger.dart';
import 'commands/generate.dart';
import 'commands/new.dart';

class NgDartCommanderRunner extends CommandRunner {
  static const _verboseOption = 'verbose';

  NgDartCommanderRunner()
      : super('ngdart2', 'Ngdart is a command line interface for AngularDart.') {
    argParser.addFlag(_verboseOption,
        abbr: 'v',
        help: 'Output extra logging information.',
        defaultsTo: false);

    addCommand(new NewProjectCommand());
    addCommand(new GenerateCommand());
  }

  Future run(Iterable<String> args) async {
    var option = super.parse(args);
    AppLogger.log.isVerbose = option[_verboseOption];

    await runCommand(option);
  }
}
