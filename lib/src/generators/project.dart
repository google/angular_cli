// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import 'package:path/path.dart' as path;

import '../entity_name.dart';
import '../generator.dart';
import 'component.dart';

/// Generator for sample Angular project.
class ProjectGenerator extends Generator {
  static const _templateFolder = 'project';
  static final List<String> _templateFilePaths = [
    path.join('web', 'index.html.mustache'),
    path.join('web', 'main.dart.mustache'),
    path.join('web', 'styles.css.mustache'),
    'analysis_options.yaml',
    '.gitignore',
    'pubspec.yaml.mustache',
  ];

  /// Project name in format abc_bcd.
  final String name;
  final String description;

  /// Root component of this project.
  final ComponentGenerator component;

  ProjectGenerator._(
      this.name, this.description, this.component, String destinationFolder)
      : super(destinationFolder);

  factory ProjectGenerator(EntityName projectEntityName,
      String destinationFolder, EntityName componentClassEntityName) {
    destinationFolder =
        path.join(destinationFolder, projectEntityName.underscored);
    var component = new ComponentGenerator(
        componentClassEntityName, path.join(destinationFolder, 'lib'));

    return new ProjectGenerator._(projectEntityName.underscored,
        projectEntityName.spaced, component, destinationFolder);
  }

  // Gets a map from template file name to target file name.
  Map<String, String> _getTemplateTargetPaths() {
    var results = <String, String>{};
    for (final templatePath in _templateFilePaths) {
      results[path.join(_templateFolder, templatePath)] =
          templatePath.replaceAll('.mustache', '');
    }
    return results;
  }

  @override
  Future generate() async {
    await renderAndWriteTemplates(_getTemplateTargetPaths());
    await component.generate();
  }
}
