// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../entity_name.dart';

/// Base class for commands for ngdart executable.
abstract class NgDartCommand extends Command {
  static const binaryName = 'ngdart2';
  ArgParser get argParser => _argParser;
  final _argParser = new ArgParser(allowTrailingOptions: true);

  /// Reads argument for current command.
  String readArg(String errorMessage) {
    var args = argResults.rest;

    if (args == null || args.length == 0) {
      // Usage is provided by command runner.
      throw new UsageException(errorMessage, '');
    }

    var arg = args.first;
    args = args.skip(1).toList();

    if (args.length > 0) {
      throw new UsageException('Unexpected argument $args', '');
    }

    return arg;
  }

  /// Reads argument for current command and create an EntityName.
  EntityName readArgAsEntityName(String errorMessage) =>
      getEntityName(readArg(errorMessage));

  EntityName getEntityName(String entity) {
    EntityName entityName;

    try {
      entityName = new EntityName(entity);
    } on ArgumentError catch (error) {
      throw new UsageException(error.message, '');
    }

    return entityName;
  }
}
