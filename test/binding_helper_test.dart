// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';
import 'package:angular_cli/src/visitors/binding_helper.dart';
import 'package:angular_cli/src/visitors/binding_info.dart';
import 'package:test/test.dart';

void main() {
  group('TestBedBindingVisitor', () {
    _BindingVisitorForTest visitor;

    setUp(() {
      visitor = new _BindingVisitorForTest();
    });

    parse(String contents) {
      parseCompilationUnit(contents).accept(visitor);
    }

    test('should parse simple binding', () {
      parse('const x = A;');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren, equals(['A']));
    });

    test('should parse list bindings', () {
      parse('const x = [p.A, B];');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren, equals(['B']));
    });

    test('should parse "const Provider(A)"', () {
      parse('const x = const Provider(A);');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, isEmpty);
    });

    test('should parse "const Provider(const A())"', () {
      parse('const x = const Provider(const A());');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, isEmpty);
    });

    test('should throw error for "const Provider([A])"', () {
      expect(() => parse('const x = const Provider([A]);'),
          throwsUnsupportedError);
    });

    test('should parse "provide(A, useClass: B)"', () {
      parse('dynamic x = provide(A, useClass: B);');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, equals(new Set.from(['B'])));
    });

    test('should parse "provide(const A(), useExisting: B)"', () {
      parse('dynamic x = provide(const A(), useExisting: B);');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, equals(new Set.from(['B'])));
    });

    // May need to add support for this scenario.
    test('should throw error for "provide(A(), toAlias: B)"', () {
      expect(() => parse('dynamic x = provide(A(), toAlias: B);'),
          throwsUnsupportedError);
    });

    test('should parse const Provider(A, useClass: B)', () {
      var bindingStr = 'const Provider(A, useClass: B)';
      parse('const x = $bindingStr;');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, equals(new Set.from(['B'])));
      expect(binding.creationExpression, bindingStr);
    });

    test('should parse const Provider(A, useFactory: f, deps: const [B, C])',
        () {
      var bindingStr = 'const Provider(A, useFactory: f, deps: const [B, C])';
      parse('const x = $bindingStr;');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, equals(new Set.from(['B', 'C'])));
      expect(binding.creationExpression, bindingStr);
    });

    test('should parse const Provider(A, useValue: new B())', () {
      parse('const x = const Provider(A, useValue: new B());');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, equals(new Set.from(['B'])));
    });

    test("should parse const Provider('someThing', useValue: new B())", () {
      parse("const x = const Provider('someThing', useValue: new B());");

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'someThing');
      expect(binding.referencedClasses, equals(new Set.from(['B'])));
    });

    test('should parse list in deps', () {
      parse('''
        const x = const Provider(A,
            useFactory: f,
            deps: const [ const [B, const C()]]);
      ''');

      expect(visitor.modules['x'], isNotNull);
      expect(visitor.modules['x'].directChildren.length, 1);
      var binding = visitor.modules['x'].directChildren[0] as BindingInstance;
      expect(binding.className, 'A');
      expect(binding.referencedClasses, equals(new Set.from(['B'])));
    });
  });

  group('ModuleInfo', () {
    _BindingVisitorForTest visitor;

    setUp(() {
      visitor = new _BindingVisitorForTest();
    });

    parse(String contents) {
      parseCompilationUnit(contents).accept(visitor);
    }

    void checkExpandedModule(
        List<BindingInstance> allBindingInstances, List<String> expected) {
      expect(allBindingInstances, isNotNull);
      var actual = [];
      for (var binding in allBindingInstances) {
        actual.add(binding.className);
      }

      expect(actual, equals(expected));
    }

    test('should expand bindings', () {
      parse('''
        const a = A;
        const b = [
            a,
            B1,
            const Provider(B2, useClass: X)
        ];

        dynamic c = [
            provide(C, useClass: X),
            b
        ];
      ''');

      expect(visitor.modules['a'], isNotNull);
      expect(visitor.modules['b'], isNotNull);
      expect(visitor.modules['c'], isNotNull);

      checkExpandedModule(
          visitor.modules['a'].getAllBindingInstances(visitor.modules), ['A']);
      checkExpandedModule(
          visitor.modules['b'].getAllBindingInstances(visitor.modules),
          ['A', 'B1', 'B2']);
      checkExpandedModule(
          visitor.modules['c'].getAllBindingInstances(visitor.modules),
          ['C', 'A', 'B1', 'B2']);
    });
  });
}

class _BindingVisitorForTest extends RecursiveAstVisitor {
  Map<String, ModuleInfo> modules = {};

  _BindingVisitorForTest();

  @override
  visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    var variable = node.variables.variables[0];
    var name = variable.name.name;
    var initializer = variable.initializer;

    var module = modules.putIfAbsent(name, () => new ModuleInfo());
    module.name = name;

    if (initializer is ListLiteral) {
      extractBindingInfo(initializer, module);
    } else {
      processBindingElement(initializer, module);
    }
  }
}
