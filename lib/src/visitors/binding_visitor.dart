// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';

import 'binding_helper.dart';
import 'binding_info.dart';

/// Collects all binding info declared as top level variable.
class BindingVisitor extends RecursiveAstVisitor {
  /// Maps module name to module info.
  final Map<String, ModuleInfo> _bindingInfo;

  /// Maps an internal URI to a public one.
  final Map<String, String> _publicUris;

  /// All binding variables used as providers in @Component
  final Set<String> _bindingVariablesInComponents;

  // Uri of Dart file currently visited.
  final String _uri;

  BindingVisitor(this._uri, this._bindingInfo, this._publicUris,
      this._bindingVariablesInComponents);

  @override
  visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    if (node.variables.variables.length != 1) return;

    var variable = node.variables.variables[0];
    var name = variable.name.name;
    if (!_bindingVariablesInComponents.contains(name) &&
        !name.endsWith('Bindings') &&
        !name.endsWith('Binding') &&
        !name.endsWith('Module')) {
      return;
    }

    var initializer = variable.initializer;
    if (initializer is! SimpleIdentifier &&
        initializer is! PrefixedIdentifier &&
        initializer is! ListLiteral &&
        initializer is! InstanceCreationExpression &&
        initializer is! MethodInvocation) {
      return;
    }

    var module = _bindingInfo.putIfAbsent(name, () => new ModuleInfo());
    module.name = name;
    module.uri = _publicUris[_uri];

    if (initializer is ListLiteral) {
      extractBindingInfo(initializer, module);
    } else {
      processBindingElement(initializer, module);
    }
  }
}
