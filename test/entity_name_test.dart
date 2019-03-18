// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:angular_cli/src/entity_name.dart';
import 'package:test/test.dart';

void main() {
  group('Entity name', () {
    test('should produce correct formats of names', () {
      final name = EntityName('abc_bcd_cde');
      expect(name.spaced, 'Abc Bcd Cde');
      expect(name.camelCased, 'AbcBcdCde');
      expect(name.lowerCamelCased, 'abcBcdCde');
      expect(name.dashed, 'abc-bcd-cde');
      expect(name.underscored, 'abc_bcd_cde');
    });
    test('should be handle to handle different types of input', () {
      final camelCasedName1 = EntityName('AbcBcdCde');
      expect(camelCasedName1.underscored, 'abc_bcd_cde');
      final camelCasedName2 = EntityName('abcBcdCde');
      expect(camelCasedName2.underscored, 'abc_bcd_cde');
      final dashedName = EntityName('abc-bcd-cde');
      expect(dashedName.underscored, 'abc_bcd_cde');
    });
    test('should throw for incorrect formats', () {
      expect(() => EntityName('Abc-bcd'), throwsArgumentError);
      expect(() => EntityName('abc-bcd_cde'), throwsArgumentError);
      expect(() => EntityName('_abc'), throwsArgumentError);
    });
  });
}
