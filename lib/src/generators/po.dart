// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';

import 'package:path/path.dart' as path;

import '../file_reader.dart';
import '../generator.dart';
import '../page_object_data.dart';
import '../visitors/component_info.dart';

/// Generator for page object.
class PoGenerator extends Generator {
  static const _templateFolder = 'pageobject';
  static const _templateFileName = 'po.dart.mustache';

  final String componentPath;
  final String poClassName;
  final String poFileName;
  final PageObjectData pageObjectData;

  PoGenerator._(this.componentPath, this.poClassName, this.poFileName,
      this.pageObjectData, String destinationFolder)
      : super(destinationFolder);

  factory PoGenerator(ComponentInfo componentInfo, String componentPath,
      String poClassName, String destinationFolder) {
    PageObjectData pageObjectData;

    if (componentInfo.inlineTemplate == null) {
      // componentInfo.templatePath is not null here

      var componentTemplateFilePath =
          path.join(path.dirname(componentPath), componentInfo.templatePath);

      pageObjectData = new PageObjectData(
          FileReader.reader.readAsString(componentTemplateFilePath));
    } else {
      pageObjectData = new PageObjectData(componentInfo.inlineTemplate);
    }

    return new PoGenerator._(
        componentPath,
        poClassName,
        '${path.basenameWithoutExtension(componentPath)}_po.dart',
        pageObjectData,
        destinationFolder);
  }

  // Gets a map from template file name to target file name.
  Map<String, String> _getTemplateTargetPaths() {
    var results = <String, String>{};

    results[path.join(_templateFolder, _templateFileName)] = poFileName;

    return results;
  }

  @override
  Future generate() async {
    await renderAndWriteTemplates(_getTemplateTargetPaths());
  }
}
