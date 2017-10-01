import 'dart:async';

import 'package:path/path.dart' as path;

import '../entity_name.dart';
import '../generator.dart';

/// Generator for Angular pipe.
class PipeGenerator extends Generator {
  static const _templateFolder = 'pipe';
  static const _templateFileName = 'pipe.dart.mustache';

  /// Class name of this pipe.
  final String className;

  final String pipeName;

  /// Pipe file name without extension.
  final String targetName;

  PipeGenerator._(
      this.className, this.pipeName, this.targetName, String destinationFolder)
      : super(destinationFolder);

  factory PipeGenerator(
      EntityName classEntityName,
      String destinationFolder,
      ) {
    return new PipeGenerator._(classEntityName.camelCased,
        classEntityName.lowerCamelCased, classEntityName.underscored, destinationFolder);
  }

  // Gets a map from template file name to target file name.
  Map<String, String> _getTemplateTargetPaths() {
    var results = <String, String>{};

    results[path.join(_templateFolder, _templateFileName)] = "$targetName.dart";

    return results;
  }

  @override
  Future generate() async {
    await renderAndWriteTemplates(_getTemplateTargetPaths());
  }
}
