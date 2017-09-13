// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';
import 'package:angular_cli/src/visitors/binding_info.dart';
import 'package:angular_cli/src/visitors/binding_visitor.dart';
import 'package:test/test.dart';

void main() {
  group('BindingVisitor', () {
    Map<String, ModuleInfo> visit(String content) {
      var compilationUnit = parseCompilationUnit(content);
      var out = <String, ModuleInfo>{};
      var visitor = new BindingVisitor('', out, {}, new Set<String>());
      compilationUnit.accept(visitor);
      return out;
    }

    test('should skip misc variable', () {
      var module = visit('''
        library a;
        const xyz = const [A, B, C];
        ''')['xyz'];
      expect(module, isNull);
    });

    test('should skip empty initializer', () {
      var module = visit('''
        library a;
        dynamic aModule;
        ''')['aModule'];

      expect(module, isNull);
    });

    test('should parse list bindings', () {
      var results = visit('''
        library a;
        const testBinding = const [A, B, C];
        const testModule = D;
        const someBindings = testModule;
        ''');

      ModuleInfo module = results['testBinding'];
      expect(module, isNotNull);
      expect(module.directChildren, equals(['A', 'B', 'C']));
      module = results['testModule'];
      expect(module, isNotNull);
      expect(module.directChildren, equals(['D']));
      module = results['someBindings'];
      expect(module, isNotNull);
      expect(module.directChildren, equals(['testModule']));
    });
  });
}
