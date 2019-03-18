// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:angular_cli/src/page_object_data.dart';
import 'package:test/test.dart';

void main() {
  group('PageObjectData', () {
    test('should generate items.', () {
      var po = PageObjectData(
        '<action-button class="good"></action-button>',
      );
      expect(po.variables.first.getterString,
          'Future<PageLoaderElement> get good => _getGood();');
      expect(po.variables.first.internalString,
          "@ByClass('good')\n  Lazy<PageLoaderElement> _getGood;");
      expect(po.variables.first.type.uri, 'package:pageloader/objects.dart');
    });

    test('should generate items in list', () {
      var po = PageObjectData(
        '<action-button class="good" *ngFor="xxx"></action-button>',
      );
      expect(po.variables.first.getterString,
          'Future<List<PageLoaderElement>> get good => _getGood();');
      expect(po.variables.first.internalString,
          "@ByClass('good')\n  Lazy<List<PageLoaderElement>> _getGood;");
    });

    test('should generate items in parents list', () {
      var po = PageObjectData(
        '<p *ngFor="xxx"><action-button class="good">'
            '</action-button></p>',
      );
      expect(po.variables.first.getterString,
          'Future<List<PageLoaderElement>> get good => _getGood();');
      expect(po.variables.first.internalString,
          "@ByClass('good')\n  Lazy<List<PageLoaderElement>> _getGood;");
    });

    test('should generate items with default type', () {
      var po = PageObjectData('<some-widget class="cool"></some-widget>');
      expect(po.variables.first.getterString,
          'Future<PageLoaderElement> get cool => _getCool();');
      expect(po.variables.first.internalString,
          "@ByClass('cool')\n  Lazy<PageLoaderElement> _getCool;");
      expect(po.variables.first.type.uri, 'package:pageloader/objects.dart');
    });

    test('should sort generated items', () {
      var po1 = PageObjectData(
        '<action-button class="good"></action-button>'
            '<action-button class="bad"></action-button>',
      );
      expect(po1.variables.first.name, 'Bad');
      expect(po1.variables.last.name, 'Good');
      var po2 = PageObjectData(
        '<action-button class="good"></action-button>'
            '<action-button class="bad"></action-button>',
      );
      expect(po2.variables.first.name, 'Bad');
      expect(po2.variables.last.name, 'Good');
    });

    test('should ignore some tags.', () {
      var po = PageObjectData('<p>123</p>');
      expect(po.variables.isEmpty, true);
    });

    test('should add optional annotation.', () {
      var po = PageObjectData('<some-widget *ngIf="1"></some-widget>');
      expect(po.variables[0].internalString, startsWith('@optional'));
    });

    test('should add optional annotation when parent is optional.', () {
      var po =
          PageObjectData('<div *ngIf="1"><some-widget></some-widget></div>');
      expect(po.variables[0].internalString, startsWith('@optional'));
    });

    test('should add optional annotation when in <template [ngIf]>', () {
      var po = PageObjectData(
        '<template [ngIf]="1"><some-widget></some-widget></template>',
      );
      expect(po.variables[0].internalString, startsWith('@optional'));
    });

    test('should choose correct selector.', () {
      var po = PageObjectData(
        '<some-widget class="cool"></some-widget>'
            '<some-widget class="cool" id="cooler"></some-widget>'
            '<some-widget></some-widget>',
      );
      expect(po.variables.length, 3);
      expect(po.variables[0].selector.toString(), "@ByClass('cool')");
      expect(po.variables[1].selector.toString(), "@ById('cooler')");
      expect(po.variables[2].selector.toString(), "@ByTagName('some-widget')");
    });

    test('should work with selectors with attributes', () {
      var po = PageObjectData(
        '<some-cell class="field-class"></some-cell>'
            '<some-cell id="fieldWithId"></some-cell>',
      );
      expect(po.variables[0].selector.toString(), "@ByClass('field-class')");
      expect(po.variables[1].selector.toString(), "@ById('fieldWithId')");

      expect(po.variables[0].name, 'FieldClass');
      expect(po.variables[1].name, 'FieldWithId');
    });

    test('should produce correct commonDependencies.', () {
      var po1 = PageObjectData('');
      expect(po1.commonDependencies, [PageObjectData.pageLoaderDependency]);
      var po3 = PageObjectData('<some-widget></some-widget>');
      expect(po3.commonDependencies, [
        PageObjectData.pageLoaderDependency,
        PageObjectData.asyncDependency
      ]);
    });
  });
}
