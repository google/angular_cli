// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parseFragment;

import 'visitors/dart_class_info.dart';

/// Data for generating page object.
class PageObjectData {
  static const pageLoaderDependency = 'package:pageloader/objects.dart';
  static const asyncDependency = 'dart:async';

  /// Common dependencies for page object classes.
  List<String> get commonDependencies => [pageLoaderDependency]
    ..addAll(variables.isNotEmpty ? [asyncDependency] : []);

  final List<_Variable> variables;
  final DocumentFragment document;

  factory PageObjectData(String templateFileContent) {
    var document = parseFragment(templateFileContent);

    var variables = document
        .querySelectorAll('*')
        .map((element) => new _Variable.fromElement(element))
        .where((variable) => variable != null)
        .toList(growable: false)
          ..sort();

    return new PageObjectData._internal(document, variables);
  }

  PageObjectData._internal(this.document, this.variables);
}

class _Selector {
  static const ignoredTags = const [
    'a',
    'p',
    'b',
    'i',
    'small',
    'strong',
    'object',
    'canvas',
    'table',
    'span',
    'img',
    'form',
    'fieldset',
    'li',
    'center',
    'label',
    'br',
    'legend',
    'ul',
    'ng-content'
  ];

  final String type;
  final String name;
  final String value;

  factory _Selector.fromElement(Element element) {
    if (ignoredTags.contains(element.localName)) {
      return null;
    }

    if (element.id.isNotEmpty) {
      return new _Selector('ById', element.id);
    }

    if (element.classes.isNotEmpty) {
      return new _Selector('ByClass', element.classes.first);
    }

    return new _Selector('ByTagName', element.localName);
  }

  _Selector(this.type, this.name, [this.value]);

  @override
  String toString() => "@$type('${value ?? name}')";
}

class _Variable implements Comparable<_Variable> {
  static final wordReg = new RegExp(r'(^|[\-._])(\w)');

  final Element element;
  final _Selector selector;
  final bool isList;
  final bool isOptional;
  final DartClassInfo type;
  final String name;

  factory _Variable.fromElement(Element element) {
    var selector = new _Selector.fromElement(element);
    if (selector == null) {
      return null;
    }

    var type = new DartClassInfo(
        'PageLoaderElement', 'package:pageloader/objects.dart');

    return new _Variable(element, _getCamelCasedName(selector.name), selector,
        type, _isElementInList(element), _isElementInIf(element));
  }

  _Variable(this.element, this.name, this.selector, this.type,
      [this.isList = false, this.isOptional = false]);

  static bool _isElementInList(Element element) {
    while (element != null) {
      if (element.attributes.keys.any((a) => ['*ngfor'].contains(a))) {
        return true;
      }
      element = element.parent;
    }

    return false;
  }

  static bool _isElementInIf(Element element) {
    while (element != null) {
      if (element.attributes.keys.contains('*ngif') ||
          element.localName == 'template' &&
              element.attributes.keys.contains('[ngif]')) {
        return true;
      }
      element = element.parent;
    }

    return false;
  }

  static String _getCamelCasedName(String name) =>
      name.replaceAllMapped(wordReg, (m) => m[2].toUpperCase());

  String get internalString => '${_getOptionalString()}'
      '$selector\n'
      '  Lazy<${_getTypeString()}> _get$name;';

  String get getterString =>
      'Future<${_getTypeString()}> get $_getFirstCharacterLoweredName'
      ' => _get$name();';

  String _getOptionalString() => isOptional ? '@optional\n' : '';

  String _getTypeString() {
    var s = type.className;
    if (isList) {
      s = 'List<$s>';
    }

    return s;
  }

  String get _getFirstCharacterLoweredName =>
      name.replaceFirstMapped(new RegExp('^(.)'), (m) => m[1].toLowerCase());

  @override
  int compareTo(_Variable other) => name.compareTo(other.name);
}
