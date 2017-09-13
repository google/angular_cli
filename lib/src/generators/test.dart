// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import 'package:angular_cli/src/project_model.dart';
import 'package:path/path.dart' as path;

import '../generator.dart';
import 'po.dart';

/// Generator for component test.
class TestGenerator extends Generator {
  static const _templateFolder = 'test';
  static const _templateFileName = 'test.dart.mustache';

  static final _suffixPattern = new RegExp(r'(Component|View|PO|UnitTestPO)*$');

  final String tag;
  final String componentPath;
  final ProjectModel projectModel;

  final PoGenerator poGenerator;

  TestGenerator._(this.tag, this.componentPath, this.projectModel,
      this.poGenerator, String destinationFolder)
      : super(destinationFolder);

  factory TestGenerator(String tag, String componentPath, String className,
      String destinationFolder) {
    var projectModel =
        new ProjectModel('.packages', 'pubspec.yaml', componentPath, className);
    var poClassName =
        projectModel.componentClassName.replaceAll(_suffixPattern, '') + 'PO';
    var poGenerator = new PoGenerator(
        projectModel.components[projectModel.componentClassName],
        componentPath,
        poClassName,
        destinationFolder);

    return new TestGenerator._(
        tag, componentPath, projectModel, poGenerator, destinationFolder);
  }

  // Gets a map from template file name to target file name.
  Map<String, String> _getTemplateTargetPaths() {
    var results = <String, String>{};

    results[path.join(_templateFolder, _templateFileName)] =
        '${path.basenameWithoutExtension(componentPath)}_test.dart';

    return results;
  }

  @override
  Future generate() async {
    await renderAndWriteTemplates(_getTemplateTargetPaths());
    await poGenerator.generate();
  }
}
