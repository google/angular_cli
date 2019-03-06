// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import 'package:path/path.dart' as path;

import '../entity_name.dart';
import '../generator.dart';

/// Generator for Angular component.
class ComponentGenerator extends Generator {
  static const _templateFolder = 'component';
  static const List<String> _templateFileNames = const [
    'component.dart.mustache',
    'component.html.mustache',
    'component.less.mustache',
  ];

  /// Class name of this component.
  final String className;

  final String selector;

  /// Component file name without extension.
  final String targetName;

  ComponentGenerator._(
      this.className, this.selector, this.targetName, String destinationFolder)
      : super(destinationFolder);

  factory ComponentGenerator(
    EntityName classEntityName,
    String destinationFolder,
  ) {
    return new ComponentGenerator._(classEntityName.camelCased,
        classEntityName.dashed, classEntityName.underscored, destinationFolder);
  }

  // Gets a map from template file name to target file name.
  Map<String, String> _getTemplateTargetPaths() {
    var results = <String, String>{};
    for (String templateFileName in _templateFileNames) {
      results[path.join(_templateFolder, templateFileName)] =
          '$targetName/$targetName.${templateFileName.split('.')[1]}';
    }

    return results;
  }

  @override
  Future generate() async {
    await renderAndWriteTemplates(_getTemplateTargetPaths());
  }
}
