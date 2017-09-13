// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

export 'package:args/command_runner.dart' show UsageException;

/// An exception class for invalid expression when analyzing the dart file.
class InvalidExpressionError extends Error {
  final String message;

  InvalidExpressionError(this.message);

  String toString() => "Invalid expression: $message";
}
