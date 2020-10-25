// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../app_logger.dart';
import '../exceptions.dart';
import 'binding_helper.dart';
import 'binding_info.dart';
import 'component_info.dart';
import 'dart_class_info.dart';
import 'utils.dart';

/// Visitor to collect value of providers, selector, directives,
/// and templateUrl in @Component or @View.
class AngularComponentVisitor extends RecursiveAstVisitor {
  final Map<String, DartClassInfo> _classes;

  final Map<String, ComponentInfo> _components;

  // Map to save variables that may be used in @Component.
  final Map<String, Expression> _variables = new Map();

  AngularComponentVisitor(this._classes, this._components);

  /// Collects top level variables that may be used in @Component.
  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    if (node.variables.variables.length != 1) return;
    var variable = node.variables.variables[0];
    _variables[variable.name.name] = variable.initializer;
  }

  @override
  void visitAnnotation(Annotation annotation) {
    if (annotation.parent is! ClassDeclaration) return;

    var name = annotation.name.name;
    if (name == 'Component' || name == 'View') {
      visitComponent(annotation);
    }
  }

  void visitComponent(Annotation annotation) {
    final name = className(annotation.parent);

    final component = _getComponent(name);

    for (var arg in annotation.arguments.arguments) {
      if (arg is! NamedExpression) return;
      var namedExpression = arg as NamedExpression;
      var key = namedExpression.name.label.name;
      if (key == 'selector') {
        component.selectorName = _stringValue(namedExpression.expression);
        _components.putIfAbsent(component.classInfo.className, () => component);
      } else if (key == 'providers') {
        if (namedExpression.expression is ListLiteral) {
          component.module = new ModuleInfo();
          extractBindingInfo(namedExpression.expression, component.module);
        } else if (namedExpression.expression is Identifier) {
          component.module = new ModuleInfo();
          processBindingElement(namedExpression.expression, component.module);
        } else {
          throw new InvalidExpressionError(annotation.toString());
        }
      } else if (key == 'directives') {
        _extractDirectives(namedExpression, annotation, component);
      } else if (key == 'templateUrl') {
        component.templatePath = _stringValue(namedExpression.expression);
      } else if (key == 'template') {
        component.inlineTemplate = _stringValue(namedExpression.expression);
      }
    }
  }

  void _extractDirectives(NamedExpression namedExpression,
      Annotation annotation, ComponentInfo component) {
    ListLiteral directives;
    var value = namedExpression.expression;
    if (value is SimpleIdentifier && _variables[value.name] is ListLiteral) {
      directives = _variables[value.name];
    } else if (value is ListLiteral) {
      directives = value;
    } else {
      AppLogger.log.warning('Cannot parse variable used'
          ' in directives in $annotation');
      return;
    }

    for (var node in directives.elements) {
      if (node is SimpleIdentifier || node is PrefixedIdentifier) {
        final templateTypeComponentName = extractName(node);
        final templateTypeComponent = _getComponent(templateTypeComponentName);
        component.templateTypes.add(templateTypeComponent);
      } else {
        throw new InvalidExpressionError(annotation.toString());
      }
    }
  }

  ComponentInfo _getComponent(String name) {
    if (!_components.containsKey(name)) {
      if (!_classes.containsKey(name)) {
        _classes[name] = new DartClassInfo(name);
      }
      _components[name] = new ComponentInfo(_classes[name]);
    }

    return _components[name];
  }

  String _stringValue(Expression expression) {
    String value;
    if (expression is SimpleStringLiteral || expression is AdjacentStrings) {
      value = (expression as StringLiteral).stringValue;
    }
    return value;
  }
}
