// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:path/path.dart' as path;

import 'exceptions.dart';
import 'file_reader.dart';
import 'package_uri_resolver.dart';
import 'path_util.dart';
import 'visitors/angular_component_visitor.dart';
import 'visitors/ast_cache.dart';
import 'visitors/binding_info.dart';
import 'visitors/binding_visitor.dart';
import 'visitors/component_info.dart';
import 'visitors/dart_class_info.dart';
import 'visitors/dart_class_visitor.dart';
import 'visitors/visit_resources.dart';

/// Project model built from AST cache.
///
/// The project model built will contains all referenced Dart classes,
/// all Angular component classes, and all binding modules.
class ProjectModel {
  final String projectName;

  /// Name of component class to be tested.
  final String componentClassName;

  /// Service classes needed when construct the component
  /// class [componentClassName].
  final List<String> serviceClasses;

  /// Package URI of [componentClassName].
  final String componentClassUri;

  /// Map from type name to info for each Dart class.
  final Map<String, DartClassInfo> dartClasses;

  /// Map from type name to info of each Angular component.
  final Map<String, ComponentInfo> components;

  /// Map from var name to info of bindings.
  final Map<String, ModuleInfo> modules;

  ProjectModel._(this.projectName, this.componentClassName, this.serviceClasses,
      this.componentClassUri, this.dartClasses, this.components, this.modules);

  /// Whether providers are needed when generating test.
  bool get needProviders => serviceClasses != null && serviceClasses.isNotEmpty;

  /// Uris for service classes used.
  List<String> get referencedUris => serviceClasses
      .map((className) => dartClasses[className].uri)
      .toList(growable: false);

  factory ProjectModel(String dotPackagesFilePath, String pubspecFilePath,
      String componentPath, String className) {
    var projectName = _getProjectName(pubspecFilePath);
    var libPrefix = 'lib${path.separator}';
    var componentClassUri = componentPath.startsWith(libPrefix)
        ? fixUri(
            'package:$projectName/${componentPath.substring(libPrefix.length)}')
        : fixUri('package:$projectName/$componentPath');

    var uriResolver = new PackageUriResolver(dotPackagesFilePath);
    var asts = new AstCache(componentClassUri, uriResolver);
    asts.build();

    var dartClasses = <String, DartClassInfo>{};
    dartClasses.addAll(visitUris(asts,
            (file, out) => new DartClassVisitor(file, out, asts.publicUris))
        as Map<String, DartClassInfo>);

    var components = <String, ComponentInfo>{};
    components.addAll(visitUris(
            asts, (_, out) => new AngularComponentVisitor(dartClasses, out))
        as Map<String, ComponentInfo>);

    var modules = <String, ModuleInfo>{};
    modules.addAll(visitUris(
            asts,
            (file, out) => new BindingVisitor(
                file, out, asts.publicUris, _getBindingVariables(components)))
        as Map<String, ModuleInfo>);

    var componentClassName = className;
    if (componentClassName == null) {
      componentClassName =
          _getComponentClassName(componentClassUri, components);
    }

    var serviceClasses = _getServiceClasses(
        componentClassName, dartClasses, components, modules);

    return new ProjectModel._(projectName, componentClassName, serviceClasses,
        componentClassUri, dartClasses, components, modules);
  }
}

/// Gets project name from pubsepc [pubspecFilePath].
String _getProjectName(String pubspecFilePath) {
  List<String> lines;
  try {
    lines = FileReader.reader.readAsLines(pubspecFilePath);
  } catch (e) {
    throw new UsageException(
        'Error happened when reading pubspec.yaml. '
        'Command generate test should be run '
        'under root directory of the project.',
        '');
  }
  var namePrefix = 'name:';
  for (var line in lines) {
    line = line.trim();
    if (line.startsWith(namePrefix)) {
      return line.substring(namePrefix.length).trim();
    }
  }

  throw new FormatException('Invalid pubspec.yaml: cannot find project name');
}

/// Gets binding variables used in providers of @Component.
Set<String> _getBindingVariables(Map<String, ComponentInfo> components) {
  var result = new Set<String>();

  for (var component in components.values) {
    if (component.module == null) continue;

    for (var binding in component.module.directChildren) {
      if (binding is String) result.add(binding);
    }
  }

  return result;
}

/// Gets one component class name from [componentClassUri].
String _getComponentClassName(
    String componentClassUri, Map<String, ComponentInfo> components) {
  for (var component in components.values) {
    if (component.classInfo.uri == componentClassUri) {
      return component.classInfo.className;
    }
  }

  throw new UsageException(
      'Cannot find a component class in specified path.', '');
}

/// Gets all service classes used in [componentClassName] that need binding.
///
/// Should return an empty list if no service class is used.
List<String> _getServiceClasses(
    String componentClassName,
    Map<String, DartClassInfo> dartClasses,
    Map<String, ComponentInfo> components,
    Map<String, ModuleInfo> modules) {
  var dependencies = <String>[];
  for (var parameter in dartClasses[componentClassName].constructorParameters) {
    var service = parameter.dependency;
    if (dartClasses[service].uri == null) continue;

    dependencies.add(service);
  }

  var module = components[componentClassName].module;
  if (module != null) {
    for (var binding in module.getAllBindingInstances(modules)) {
      if (dependencies.contains(binding.className)) {
        dependencies.remove(binding.className);
      }
    }
  }

  var serviceClasses = <String>[]..addAll(dependencies);

  return serviceClasses;
}
