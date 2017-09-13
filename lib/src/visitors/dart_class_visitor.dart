// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';

import '../app_logger.dart';
import '../exceptions.dart';
import 'dart_class_info.dart';
import 'utils.dart';

/// Visitor to get dependencies of a class.
///
/// Types used in constructor are collected. Type info of some variables in
/// constructor are only available in field definitions, which are collected
/// by visiting field declarations.
class DartClassVisitor extends RecursiveAstVisitor {
  /// Maps class name to class info.
  final Map<String, DartClassInfo> _dartClasses;

  /// Maps an internal URI to a public one.
  final Map<String, String> _publicUris;

  /// Uri of Dart file currently visited.
  String _uri;

  DartClassVisitor(this._uri, this._dartClasses, this._publicUris);

  /// Visits top level variable to collect OpaqueToken.
  ///
  /// Top level OpaqueToken is treated as dart class. It is something we need
  /// to provide bindings.
  @override
  visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    if (node.variables.variables.length != 1) return;

    var variable = node.variables.variables[0];
    if (variable.initializer is! InstanceCreationExpression) return;

    var initializer = variable.initializer as InstanceCreationExpression;
    if (extractName(initializer.constructorName.type.name) == 'OpaqueToken') {
      var tokenInfo = _getClass(variable.name.name);
      tokenInfo.uri = _publicUris[_uri];
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration classDeclaration) {
    var classInfo = _getClass(className(classDeclaration));

    // Only first appeared class is used to get more accurate matching.
    if (classInfo.uri != null) return;

    classInfo.uri = _publicUris[_uri];

    var extendsClause = classDeclaration.extendsClause;
    if (extendsClause != null) {
      classInfo.extendsType = extractName(extendsClause.superclass.name);
    }

    var implementsClause = classDeclaration.implementsClause;
    if (implementsClause != null) {
      for (var typeName in implementsClause.interfaces) {
        classInfo.implementsTypes.add(extractName(typeName.name));
      }
    }

    classDeclaration.visitChildren(this);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration constructor) {
    // Only unnamed constructors.
    if (constructor.name != null) return;
    var classInfo = _classInfo(constructor);

    if (classInfo.constructorParameters.isNotEmpty) {
      AppLogger.log.fine('Duplicate constructor visit: $constructor');
      return;
    }

    for (var parameter in constructor.parameters.parameters) {
      // Annotations like ViewQuery, ViewChild, and ViewChildren
      // will use a type like QueryList<SomeComponent>, such dependency can
      // be handled by angular.
      var isOptional = parameter.metadata.any((annotation) {
        var name = extractName(annotation.name);
        return name == 'Optional' || name == 'SkipSelf';
      });

      if (isOptional) continue;

      if (parameter is SimpleFormalParameter ||
          parameter is FieldFormalParameter) {
        final tokenName = _extractAnnotatedType(parameter.metadata);
        final annotations = parameter.metadata
            .map((annotation) => annotation.toString())
            .toList();

        final parameterType = _getParameterType(parameter, classInfo);

        classInfo.constructorParameters.add(new ConstructorParameter(
            annotations, parameterType, parameter.identifier.name, tokenName));
      } else if (parameter is DefaultFormalParameter ||
          parameter is FunctionTypedFormalParameter) {
        // Defaults are not supported in DI.
      } else {
        throw new UnsupportedError(
            'Unable to handle parameter ${parameter.runtimeType} '
            'for ${className(constructor.parent)} in $_uri.');
      }
    }
  }

  /// Gets parameter type.
  ///
  /// Different types of parameter can have different ways to extract type.
  /// Currently we support [SimpleFormalParameter] and [FieldFormalParameter].
  /// When we can't handle the parameter or the type is implicit, we will return
  /// [DartClassInfo] object that represents 'dynamic'.
  DartClassInfo _getParameterType(
      FormalParameter parameter, DartClassInfo classInfo) {
    if (parameter is SimpleFormalParameter) {
      return _getClassForTypeAnnotation(parameter.type);
    } else if (parameter is FieldFormalParameter) {
      if (parameter.type != null) {
        // Even if this is FieldFormalParameter, it can also have type info.
        return _getClassForTypeAnnotation(parameter.type);
      } else {
        // The actual type will be filled when the corresponding member is
        // visited.
        return classInfo.getMemberType(parameter.identifier.name);
      }
    }

    return _getClass('dynamic');
  }

  @override
  void visitFieldDeclaration(FieldDeclaration field) {
    if (field.parent is! ClassDeclaration) return;
    var classInfo = _classInfo(field);

    var typeOfField = field.fields.type;
    for (var variable in field.fields.variables) {
      bool isReferenced = classInfo.memberTypes.containsKey(variable.name.name);
      if (typeOfField != null) {
        classInfo.memberTypes[variable.name.name] =
            _getClass(typeOfField.toString());
      } else if (variable.initializer is InstanceCreationExpression) {
        classInfo.memberTypes[variable.name.name] =
            _getClass(extractConstructorName(variable.initializer));
      } else {
        classInfo.memberTypes[variable.name.name] = _getClass('dynamic');
      }

      if (isReferenced) {
        for (final parameter in classInfo.constructorParameters) {
          if (parameter.name == variable.name.name) {
            parameter.type = classInfo.memberTypes[variable.name.name];
          }
        }
      }

      classInfo.memberAnnotations[variable.name.name] = field.metadata;
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration method) {
    if (method.parent is! ClassDeclaration) return;
    if (!method.isSetter) return;

    var classInfo = _classInfo(method);

    var parameter = method.parameters.parameters[0];

    if (parameter is! SimpleFormalParameter) {
      AppLogger.log
          .fine('Unimplemented parameter type ${parameter.runtimeType} '
              'from $parameter');
      return;
    }

    var setterParameter = parameter as SimpleFormalParameter;

    // This member won't be referenced in constructor.
    classInfo.memberTypes[method.name.name] =
        _getClassForTypeAnnotation(setterParameter.type);
    classInfo.memberAnnotations[method.name.name] = method.metadata;
  }

  /// Pattern to extract generic class.
  ///
  /// For example, for class 'List<InnerType>', the group 1 of this class will
  /// be 'InnerType'.
  static final RegExp _genericClassPattern =
      new RegExp(r'^[a-zA-Z_0-9]*<(.*)>$');

  /// Gets [DartClassInfo] for [className].
  ///
  /// If the class is generic, the inner most class's library path will be used,
  /// which is more likely to be a special import requirement.
  /// There can be cases where [className] is like 'A, B', which comes from the
  /// type parameters inside a generic class. For now, we simply treat 'A, B' as
  /// a real class.
  DartClassInfo _getClass(String className) {
    if (!_dartClasses.containsKey(className)) {
      final match = _genericClassPattern.firstMatch(className);
      if (match != null) {
        final innerClass = _getClass(match.group(1));
        return _dartClasses[className] =
            new DartClassInfo(className, innerClass.uri);
      }

      _dartClasses[className] = new DartClassInfo(className);
    }
    return _dartClasses[className];
  }

  /// Gets [DartClassInfo] for a [TypeAnnotation].
  DartClassInfo _getClassForTypeAnnotation(TypeAnnotation type) {
    if (type == null) return _getClass('dynamic');

    return _getClass(type.toString());
  }

  DartClassInfo _classInfo(AstNode node) => _getClass(className(node.parent));

  String _extractAnnotatedType(NodeList<Annotation> metadata) {
    if (metadata == null || metadata.length != 1) return null;

    var name = extractName(metadata[0].name);

    // Returns annotation as type if there is one.
    if (name != 'Inject') return name;

    var args = metadata[0].arguments.arguments;
    if (args.length != 1) {
      throw new InvalidExpressionError('$metadata in $_uri.');
    }

    var args0 = args[0];
    if (args0 is Identifier) {
      return extractName(args0);
    } else if (args0 is InstanceCreationExpression) {
      return extractName(args0.constructorName.type.name);
    } else if (args0 is SimpleStringLiteral) {
      return args0.value;
    }

    throw new InvalidExpressionError('$metadata in $_uri.');
  }
}
