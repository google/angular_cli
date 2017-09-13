// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

/// Base class for binding information.
abstract class BindingInfo {
  /// String representation of this binding.
  String get expression;
}

/// Expression that creates a Provider.
class BindingInstance extends BindingInfo {
  final String className;
  final String creationExpression;

  /// Classes used in [creationExpression].
  final Set<String> referencedClasses = new Set();

  BindingInstance(this.className, this.creationExpression);

  @override
  String toString() => creationExpression;

  @override
  String get expression => creationExpression;
}

/// Models binding information.
class ModuleInfo extends BindingInfo {
  /// Uri of file that contains this binding module.
  String uri;

  /// Name of this module, null if there is no name.
  String name;

  /// Raw data of bindings in this module.
  ///
  /// Elements in this list have the same order where the module/bindings
  /// was defined. Elements in this list can only be
  ///   1. String
  ///   2. BindingInstance
  /// If element is String, it may be a
  ///   a. class name
  ///   b. another binding variable
  ///   c. an OpaqueToken
  List<Object> directChildren = [];

  // All binding instances of this module.
  List<BindingInstance> _allBindingInstances;

  /// Expands binding information in this module.
  List<BindingInstance> getAllBindingInstances(
      Map<String, ModuleInfo> allModules) {
    if (_allBindingInstances != null) {
      return _allBindingInstances;
    }

    _allBindingInstances = [];

    for (var binding in directChildren) {
      if (binding is String) {
        if (allModules[binding] == null) {
          // This is a class or an OpaqueToken.
          _allBindingInstances.add(new BindingInstance(binding, binding));
        } else {
          _allBindingInstances
              .addAll(allModules[binding].getAllBindingInstances(allModules));
        }
      } else if (binding is BindingInstance) {
        _allBindingInstances.add(binding);
      }
    }

    return _allBindingInstances;
  }

  @override
  String get expression => name;
}
