import 'dart:async';

import 'package:path/path.dart' as path;

import '../entity_name.dart';
import '../generator.dart';

/// Generator for Angular directive.
class DirectiveGenerator extends Generator {
  static const _templateFolder = 'directive';
  static const _templateFileName = 'directive.dart.mustache';

  /// Class name of this directive.
  final String className;

  final String selector;

  /// Directive file name without extension.
  final String targetName;

  DirectiveGenerator._(
      this.className, this.selector, this.targetName, String destinationFolder)
      : super(destinationFolder);

  factory DirectiveGenerator(
    EntityName classEntityName,
    String destinationFolder,
  ) {
    return new DirectiveGenerator._(
        classEntityName.camelCased,
        classEntityName.lowerCamelCased,
        classEntityName.underscored,
        destinationFolder);
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
