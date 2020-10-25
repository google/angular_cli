// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:angular_cli/src/visitors/dart_class_info.dart';
import 'package:angular_cli/src/visitors/dart_class_visitor.dart';
import 'package:test/test.dart';

void main() {
  group('DartClassVisitor', () {
    Map<String, DartClassInfo> visit(String content) {
      var parsed = parseString(content: content);
      var compilationUnit = parsed.unit;
      var out = <String, DartClassInfo>{};
      var visitor = new DartClassVisitor('', out, {});
      compilationUnit.accept(visitor);
      return out;
    }

    test('should collect OpaqueToken', () {
      var classInfo =
          visit("const token = const OpaqueToken('token');")['token'];

      expect(classInfo, isNotNull);
    });

    test('should collect the components constructor types', () {
      var classInfo = visit("""
        library x;

        class Cons {
          Cons(String x, Exotic y);
        }
        """)['Cons'];

      expect(
          classInfo.constructorParameters
              .map((parameter) => parameter.dependency),
          equals(['String', 'Exotic']));
      expect(classInfo.constructorParameters.map((parameter) => parameter.name),
          equals(['x', 'y']));
    });

    test('should collect constructor types which reference this', () {
      var classInfo = visit("""
        library x;

        class Cons {
           final String y;
           Cons(this.y, Exotic z);
        }
        """)['Cons'];

      expect(
          classInfo.constructorParameters
              .map((parameter) => parameter.dependency),
          equals(['String', 'Exotic']));
      expect(classInfo.constructorParameters.map((parameter) => parameter.name),
          equals(['y', 'z']));
    });

    test('should collect member type for field declaration', () {
      var classInfo = visit("""
        class Cons {
           final x = new Clock.fixed();
           List<SomeThing> y;
        }
        """)['Cons'];

      expect(classInfo.memberTypes['x'].className, equals('Clock'));
      expect(classInfo.memberTypes['y'].className, equals('List<SomeThing>'));
    });

    test(
        'should collect constructor types which reference this'
        ' and defined after constructor', () {
      var classInfo = visit("""
        library x;

        class Cons {
           final String y;
           Cons(this.x, this.y, List<Exotic> z);
           SomeClass x;
        }
        """)['Cons'];

      expect(
          classInfo.constructorParameters
              .map((parameter) => parameter.dependency),
          equals(['SomeClass', 'String', 'List<Exotic>']));
      expect(classInfo.constructorParameters.map((parameter) => parameter.name),
          equals(['x', 'y', 'z']));
    });

    test('should collect classes types with implicit constructors', () {
      var classInfo = visit("""
        library x;

        class Cons {
           final String y;
        }
        """)['Cons'];

      expect(classInfo.constructorParameters, equals([]));
    });

    test('shoulde collect extends clauses', () {
      var classInfo = visit("""
        library x;

        class Cons extends SuperAwesomeBase {
        }
        """)['Cons'];

      expect(classInfo.extendsType, equals('SuperAwesomeBase'));
    });

    test('should collect implements clauses', () {
      var classInfo = visit("""
        library x;

        class Cons implements dull.DullInterface, AwesomeInterface {
        }
        """)['Cons'];

      expect(classInfo.implementsTypes,
          equals(['DullInterface', 'AwesomeInterface']));
    });

    test('should skip optional parameter', () {
      var classInfo = visit("""
        library x;

        class Cons {
          Cons(@Optional() String x, @SkipSelf() Exotic y);
        }
        """)['Cons'];

      expect(classInfo.constructorParameters.isEmpty, true);
    });

    test('should get type from @Inject(MyString)', () {
      var classInfo = visit("""
        library x;

        class Cons {
          final String y;
          Cons(@Inject(MyString) String x, @Inject(YString) this.y);
        }
        """)['Cons'];

      expect(
          classInfo.constructorParameters
              .map((parameter) => parameter.dependency),
          equals(['MyString', 'YString']));
      expect(classInfo.constructorParameters.map((parameter) => parameter.name),
          equals(['x', 'y']));
    });

    test("should get type from @Inject('someString')", () {
      var classInfo = visit("""
        library x;

        class Cons {
          final String y;
          Cons(@Inject('someString') String x, @Inject(YString) this.y);
        }
        """)['Cons'];

      expect(
          classInfo.constructorParameters
              .map((parameter) => parameter.dependency),
          equals(['someString', 'YString']));
      expect(classInfo.constructorParameters.map((parameter) => parameter.name),
          equals(['x', 'y']));
    });

    test('should get type from @Inject(const MyString())', () {
      var classInfo = visit("""
        library x;

        class Cons {
          final String y;
          Cons(@Inject(const MyString()) String x,
              @Inject(const YString()) this.y);
        }
        """)['Cons'];

      expect(
          classInfo.constructorParameters
              .map((parameter) => parameter.dependency),
          equals(['MyString', 'YString']));
      expect(classInfo.constructorParameters.map((parameter) => parameter.name),
          equals(['x', 'y']));
    });

    test('should get type from @MyString()', () {
      var classInfo = visit("""
        library x;

        class Cons {
          final String y;
          Cons(@MyString String x,
              @YString this.y);
        }
        """)['Cons'];

      expect(
          classInfo.constructorParameters
              .map((parameter) => parameter.dependency),
          equals(['MyString', 'YString']));
      expect(classInfo.constructorParameters.map((parameter) => parameter.name),
          equals(['x', 'y']));
    });

    test('should get member type for setter', () {
      var classInfo = visit("""
        class Cons {
          var x;
          var y;
          var z;
          Cons();

          set x(String value){x = value;}
          set y(value){y = value;}
          set z(List<String> value){z = value;}
        }
        """)['Cons'];

      expect(classInfo.memberTypes['x'].className, equals('String'));
      expect(classInfo.memberTypes['y'].className, equals('dynamic'));
      expect(classInfo.memberTypes['z'].className, equals('List<String>'));
    });
  });
}
