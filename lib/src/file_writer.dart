// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:io';

import 'app_logger.dart';

class FileWriter {
  static FileWriter writer = new FileWriter._();

  FileWriter._();

  /// Writes content to [destination]. Throws StateError if
  /// destination exists. Folder will be created if not exists.
  void write(String destination, String content) {
    var file = new File(destination);

    if (file.existsSync()) {
      throw new StateError('File $destination already exists');
    }

    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    AppLogger.log.info('Saving $destination');
    file.writeAsStringSync(content);
  }
}
