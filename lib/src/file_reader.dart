// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:convert';
import 'dart:io';

class FileReader {
  static FileReader reader = FileReader._();

  FileReader._();

  String readAsString(String filePath, {Encoding encoding = utf8}) =>
      File(filePath).readAsStringSync(encoding: encoding);

  List<String> readAsLines(String filePath, {Encoding encoding = utf8}) =>
      File(filePath).readAsLinesSync(encoding: encoding);
}
