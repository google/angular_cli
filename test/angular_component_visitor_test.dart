// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';
import 'package:angular_cli/src/visitors/angular_component_visitor.dart';
import 'package:angular_cli/src/visitors/component_info.dart';
import 'package:angular_cli/src/visitors/dart_class_info.dart';
import 'package:test/test.dart';

void main() {
  group('AngularComponentVisitor', () {
    Map<String, ComponentInfo> visit(
        Map<String, DartClassInfo> classes, String content) {
      var compilationUnit = parseCompilationUnit(content);
      var out = <String, ComponentInfo>{};
      var visitor = AngularComponentVisitor(classes, out);
      compilationUnit.accept(visitor);
      return out;
    }

    test('should parse an Angular component', () {
      final classes = <String, DartClassInfo>{
        'A': DartClassInfo('A'),
        'B': DartClassInfo('B'),
        'TestComponent': DartClassInfo('TestComponent')
      };

      var component = visit(classes, '''
       library a;

       @Component(
         selector: 'test',
         directives: const [A, B],
         templateUrl: 'test.html'
       )
       class TestComponent {}
     ''')['TestComponent'];

      expect(component, isNotNull);
      expect(component.selectorName, equals('test'));
      expect(component.templatePath, equals('test.html'));
      expect(
          component.templateTypes
              .map((templateType) => templateType.classInfo.className),
          equals(['A', 'B']));
    });

    test('should collect inline template', () {
      final classes = <String, DartClassInfo>{
        'TestComponent': DartClassInfo('TestComponent')
      };

      var component = visit(classes, '''
       library a;

       @Component(
         selector: 'test',
         template: '<div></div>'
       )
       class TestComponent {}
     ''')['TestComponent'];

      expect(component, isNotNull);
      expect(component.inlineTemplate, equals('<div></div>'));
    });

    test('can combine component and view tags values', () {
      final classes = <String, DartClassInfo>{
        'A': DartClassInfo('A'),
        'B': DartClassInfo('B'),
        'TestComponent': DartClassInfo('TestComponent')
      };
      var component = visit(classes, '''
        library a;

        @Component(
          selector: 'test'
        )
        @View(
          directives: const [A, B],
          templateUrl: 'test.html'
        )
        class TestComponent {}
      ''')['TestComponent'];

      expect(component, isNotNull);
      expect(component.selectorName, equals('test'));
      expect(component.templatePath, equals('test.html'));
      expect(
          component.templateTypes
              .map((templateType) => templateType.classInfo.className),
          equals(['A', 'B']));
    });

    test('can parse directives which value is a variable', () {
      final classes = <String, DartClassInfo>{
        'A': DartClassInfo('A'),
        'B': DartClassInfo('B'),
        'GtTestComponent': DartClassInfo('TestComponent')
      };
      var component = visit(classes, '''
        const myDirectives = const [A, B];
        @Component(
          selector: 'gt-test',
          directives: myDirectives,
          templateUrl: 'gt_test.html'
        )
        class GtTestComponent {}
      ''')['TestComponent'];

      expect(
          component.templateTypes
              .map((templateType) => templateType.classInfo.className),
          equals(['A', 'B']));
    });

    test('should collect component binding list', () {
      final classes = <String, DartClassInfo>{
        'A': DartClassInfo('A'),
        'B': DartClassInfo('B'),
        'TestComponent': DartClassInfo('TestComponent')
      };

      var component = visit(classes, '''
        library a;

        @Component(
          providers: const [A, B],
          selector: 'test'
        )
        class TestComponent {}
        ''')['TestComponent'];

      expect(component, isNotNull);
      expect(component.module, isNotNull);
      expect(component.module.directChildren, equals(['A', 'B']));
    });

    test('should collect component binding variable', () {
      final classes = <String, DartClassInfo>{
        'A': DartClassInfo('A'),
        'TestComponent': DartClassInfo('TestComponent')
      };
      var component = visit(classes, '''
        library a;

        @Component(
          providers: A,
          selector: 'test'
        )
        class TestComponent {}
        ''')['TestComponent'];
      expect(component, isNotNull);
      expect(component.module, isNotNull);
      expect(component.module.directChildren, equals(['A']));
    });
  });
}
