// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';

import '../app_logger.dart';

/// Returns the name of a class declaration.
String className(ClassDeclaration classDeclaration) =>
    classDeclaration.name.name;

/// Extracts name from an Identifier.
///
/// Returns last part if [id] is PrefixedIdentifier, otherwise returns name.
String extractName(Identifier id) {
  if (id is SimpleIdentifier) {
    return id.name;
  } else if (id is PrefixedIdentifier) {
    return id.identifier.name;
  } else {
    AppLogger.log.fine('Unsupported Identifier ${id.runtimeType}');
    return id.name;
  }
}

/// Gets name of the constructor (also the class name).
String extractConstructorName(InstanceCreationExpression instanceCreationExp) {
  var constructorId = instanceCreationExp.constructorName.type.name;
  var constructorName;

  // Work around an issue that constructorName.type.name will
  // return fixed for new Clock.fixed.
  if (constructorId is PrefixedIdentifier) {
    constructorName = constructorId.prefix.name;
  } else {
    constructorName = constructorId.name;
  }
  return constructorName;
}
