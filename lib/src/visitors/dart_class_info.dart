// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';

/// Models a Dart class found during analysis.
class DartClassInfo {
  /// Uri of file that contains this Dart class.
  String uri;

  /// Class name of this class.
  String className;

  /// The Dart type that this class extends.
  ///
  /// If it doesn't extend anything, this will be 'null'
  String extendsType;

  final List<ConstructorParameter> constructorParameters = [];

  final Map<String, DartClassInfo> memberTypes = {};

  final Map<String, List<Annotation>> memberAnnotations = {};

  /// A list of Dart types that this class implements.
  final List<String> implementsTypes = [];

  DartClassInfo(this.className, [this.uri]);

  /// Gets or creates a member type entry.
  DartClassInfo getMemberType(String memberName) =>
      memberTypes.putIfAbsent(memberName, () => null);

  @override
  String toString() => className == 'dynamic' ? '' : className;
}

/// Parameter used in component constructor.
class ConstructorParameter {
  /// Annotations for the parameter.
  ///
  /// Examples include things like @Optional(), @Inject() etc.
  List<String> annotations;

  /// Parameter's type.
  DartClassInfo type;

  /// Parameter's name.
  ///
  /// If the parameter is of form 'this.xxx', [name] will xxx since it's what's
  /// visible to the caller.
  String name;

  String _dependency;

  /// Dependency to be used when building dependency graph.
  ///
  /// This can be the parameter's type or the @Inject token used.
  String get dependency => _dependency ?? type.className;

  ConstructorParameter(this.annotations, this.type, this.name,
      [this._dependency]);
}
