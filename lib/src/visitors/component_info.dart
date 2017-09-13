// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'binding_info.dart';
import 'dart_class_info.dart';

/// Information about a component.
class ComponentInfo {
  /// Underlying class.
  DartClassInfo classInfo;

  /// Selector name, same as tag name.
  String selectorName;

  /// Template (html) path.
  String templatePath;

  /// HTML template that is set inline in @Component.
  String inlineTemplate;

  /// For component types, this is a list of all directive classes used
  /// in the component's template.
  List<ComponentInfo> templateTypes = [];

  /// Value of providers in @Component.
  ModuleInfo module;

  ComponentInfo(this.classInfo);
}
