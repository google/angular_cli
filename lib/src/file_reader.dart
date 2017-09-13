// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:convert';
import 'dart:io';

class FileReader {
  static FileReader reader = new FileReader._();

  FileReader._();

  String readAsString(uri, {Encoding encoding: UTF8}) {
    if (uri is String) {
      return new File(uri).readAsStringSync(encoding: encoding);
    } else if (uri is Uri) {
      return new File.fromUri(uri).readAsStringSync(encoding: encoding);
    }

    return null;
  }

  List<String> readAsLines(uri, {Encoding encoding: UTF8}) {
    if (uri is String) {
      return new File(uri).readAsLinesSync(encoding: encoding);
    } else if (uri is Uri) {
      return new File.fromUri(uri).readAsLinesSync(encoding: encoding);
    }

    return null;
  }
}
