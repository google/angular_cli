// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import 'package:path/path.dart' as path;

import 'file_writer.dart';
import 'template_file.dart';

/// An abstract class defines a template generator.
abstract class Generator {
  final String _destinationFolder;

  Generator(this._destinationFolder);

  /// Renders templates and writes to target files.
  Future renderAndWriteTemplates(Map<String, String> templateTargets) async {
    for (final template in templateTargets.keys) {
      final content = await TemplateFile(template, this).renderString();
      FileWriter.writer.write(
          path.join(_destinationFolder, templateTargets[template]), content);
    }
  }

  /// Generates files defined for this generator.
  Future generate();
}
