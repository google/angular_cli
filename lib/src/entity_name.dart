// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

/// Entity name which can produce multiple formats.
class EntityName {
  static final validPatterns = <RegExp>[
    // abc_bcd
    RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$'),
    // AbcBcd or abcBcd
    RegExp(r'^([A-Za-z][a-z0-9]*)*$'),
    // abc-bcd
    RegExp(r'^[a-z][a-z0-9]*(-[a-z0-9]+)*$')
  ];
  static final splitPattern = RegExp(r'(?=[A-Z])|_|-');

  // Segments for the name.
  //
  // Each segment is a word in the name in its lowercase format.
  final List<String> _segments;

  /// Camel Cased format.
  ///
  /// Example: AbcBcdCde.
  String get camelCased =>
      _segments.map((s) => '${s[0].toUpperCase()}${s.substring(1)}').join('');

  /// Lower Camel Cased format.
  ///
  /// Example: abcBcdCde.
  String get lowerCamelCased =>
      '${camelCased[0].toLowerCase()}${camelCased.substring(1)}';

  /// Underscored format.
  ///
  /// Example: abc_bcd_cde.
  String get underscored => _segments.join('_');

  /// Dashed format.
  ///
  /// Example: abc-bcd-cde.
  String get dashed => _segments.join('-');

  /// Space separated format.
  ///
  /// Example: Abc Bcd Cde.
  String get spaced =>
      _segments.map((s) => '${s[0].toUpperCase()}${s.substring(1)}').join(' ');

  /// Accepts multiple formats of the name.
  ///
  /// Currently patterns like abc_bcd, AbcBcd, abcBcd, abc-bcd are supported.
  factory EntityName(String name) {
    if (!validPatterns.any((pattern) => pattern.hasMatch(name))) {
      throw ArgumentError('$name is not valid. It should be of form "abc_bcd", '
          '"AbcBcd", "abcBcd", or "abc-bcd".');
    }

    final segments =
        name.split(splitPattern).map((s) => s.toLowerCase()).toList();
    return EntityName._(segments);
  }

  EntityName._(this._segments);
}
