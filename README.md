## AngularDart CLI

A command line interface for [AngularDart][webdev_angular].
It can scaffold a skeleton AngularDart project, component, and test with
[page object][page_object].

## Installation

To install:

```bash
pub global activate angular_cli
```

To update:

```bash
pub global activate angular_cli
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
pub serve
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
and [`test` package][pub_test]

Use command

```bash
pub run angular_test --test-arg=--tags=aot --test-arg=--platform=dartium  --test-arg=--reporter=expanded
```

to run generated test with [Dartium][webdev_dartium].

[webdev_angular]: https://webdev.dartlang.org/angular
[webdev_dartium]: https://webdev.dartlang.org/tools/dartium
[page_object]: https://martinfowler.com/bliki/PageObject.html
[pub_angular_test]: https://pub.dartlang.org/packages/angular_test
[pub_test]: https://pub.dartlang.org/packages/test
