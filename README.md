## AngularDart CLI

[![Pub Package](https://img.shields.io/pub/v/angular_cli.svg)](https://pub.dartlang.org/packages/angular_cli)
[![Build Status](https://travis-ci.org/google/angular_cli.svg?branch=master)](https://travis-ci.org/google/angular_cli)

A command line interface for [AngularDart][webdev_angular].
It can scaffold a skeleton AngularDart project, component, and test with
[page object][page_object].

## Installation

To install:

```bash
pub global activate angular_cli
pub global activate webdev
```

To update:

```bash
pub global activate angular_cli
pub global activate webdev
```

## Usage

```bash
ngdart help
```

For help on specific command, run `ngdart help [command name]`
For example:

```bash
ngdart help generate test
```

will show how to use command `generate test`.

### Generating AngularDart project

```bash
ngdart new project_name
cd project_name
pub get
webdev serve
```

Navigate to `http://localhost:8080` to visit the project you just built.
Command following will assume that you are in the root directory of
the project.

### Generating component

```bash
ngdart generate component AnotherComponent
```
This command will generate component under folder `lib/`.
You can use option `-p` to change the folder.


### Generating test

```bash
ngdart generate test lib/app_component.dart
```

Command above will generate 2 files. One is page object file
and the other one is test file.
Test generated is using [angular_test][pub_angular_test]
and [test][pub_test] package.

Use command

```bash
pub run build_runner test --fail-on-severe -- -p chrome
```

to run generated test with Chrome.

[webdev_angular]: https://webdev.dartlang.org/angular
[page_object]: https://martinfowler.com/bliki/PageObject.html
[pub_angular_test]: https://pub.dartlang.org/packages/angular_test
[pub_test]: https://pub.dartlang.org/packages/test
