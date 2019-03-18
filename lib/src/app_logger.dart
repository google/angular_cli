// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

class AppLogger {
  static AppLogger log = AppLogger._('AngularDartCli');

  final Logger _logger;

  AppLogger._(String name) : _logger = Logger(name) {
    final pens = {
      Level.FINE: AnsiPen()..blue(),
      Level.INFO: AnsiPen()..green(),
      Level.WARNING: AnsiPen()..magenta(),
      Level.SEVERE: AnsiPen()..red(bold: true)
    };

    Logger.root.onRecord.listen((record) {
      for (final line in record.message.split('\n')) {
        stderr
            .writeln('${pens[record.level]('${record.level.name}:')} ${line}');
      }
    });
  }

  /// Configures the log level.
  ///
  /// By default, FINE log will not be printed.
  /// Sets [isVerbose] to print FINE logs also.
  set isVerbose(bool value) {
    Logger.root.level = value ? Level.FINE : Level.INFO;
  }

  void fine(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.FINE, message, error, stackTrace);

  void info(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.INFO, message, error, stackTrace);

  void warning(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.WARNING, message, error, stackTrace);

  void severe(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.SEVERE, message, error, stackTrace);
}
