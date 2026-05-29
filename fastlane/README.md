fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Generate Xcode project from project.yml

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run SwiftLint

### ios ci

```sh
[bundle exec] fastlane ios ci
```

Lint + Build + Unit Tests — runs on every push

### ios full

```sh
[bundle exec] fastlane ios full
```

Lint + Build + Unit Tests + UI Tests — runs on main

### ios build

```sh
[bundle exec] fastlane ios build
```

Build the app

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```

Run unit tests

### ios ui_tests

```sh
[bundle exec] fastlane ios ui_tests
```

Run UI tests

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
