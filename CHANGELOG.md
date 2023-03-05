# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- partial implementation of a `File` from *dart:io* with `FileSystemFileHandle`.
- partial implementation of a `Directory` from *dart:io* with `FileSystemDirectoryHandle`.
- partial implementation of a `FileStat` from *dart:io* with `FileSystemFileHandle` / `FileSystemDirectoryHandle`.
- method `FileSystemAccess.toFile` to convert a `FileSystemFileHandle` to a `File`.
- method `FileSystemAccess.toDirectory` to convert a `FileSystemDirectoryHandle` to a `Directory`.

------------------------

## [1.1.0] - 2023-02-13
### Added
- js-interop binding to support experimental and non-standard method `FileSystemHandle.remove`.

------------------------

## [1.0.3] - 2022-12-17
### Fixed
- downgrade package 'js' from v0.6.5 to v0.6.4 to be compatible with `flutter_web_plugins` in Flutter projects.

------------------------

## [1.0.2] - 2022-12-17
### Changed
- nullable return type of `getFileHandle` and `getDirectoryHandle` in `FileSystemDirectoryHandle` to be non-nullable. 
Methods throw `NotFoundError` instead of returning `null`. ([issue #1])
- bump package 'js' from v0.6.4 to v0.6.5.

------------------------

## [1.0.1] - 2022-12-16
### Fixed
- update CHANGELOG with the latest release.

------------------------

## [1.0.0] - 2022-12-16
Due to internal refactoring, expect breaking changes with this version. See below to migrate from [0.2.0].

### Fixed
- call to read/write methods of a FileSystemSyncAccessHandle now correctly sends 'offset' option to native method.
- API documentation using Dart Doc styles.

### Removed
- `FileSystemAccess.fromNative` and `FileSystemHandle.toNative` methods as it is now obsolete.

### Added
- documentation on how to check if browser supports API.

### Changed
- internal structure to use plain js-interop extensions instead of custom wrappers.

### Migration
> toNative() removed:
```dart
final storage; // IndexedDB storage
final handle; // a file handle

/// Call to:
await storage.put("key", handle.toNative());

/// Replace with:
await storage.put("key", handle);
```

> fromNative() removed:
```dart
final storage; // IndexedDB storage
final data = await storage.get("key"); // get file/directory handle

/// Call to:
final handle = FileSystemAccess.fromNative(data);

/// Replace with:
final handle = data as FileSystemHandle;
```

> `is` keyword will always return `false`:
```dart
FileSystemHandle handle;

/// Call to:
if (handle is FileSystemFileHandle) {}

/// Replace with:
if (handle.kind == FileSystemKind.file) {}
```

------------------------

## [0.2.0] - 2022-12-14
### Added
- js-interop bindings for `createSyncAccessHandle` and `FileSystemSyncAccessHandle` object.
- example to demonstrate usage of Synchronous Access in Web Workers.
- minimal code samples in `example.dart` to be shown in pub.dev.

------------------------

## [0.1.0] - 2022-12-10
### Added
- js-interop bindings for `showOpenFilePicker`, `showSaveFilePicker` and `showDirectoryPicker` on Window.
- js-interop bindings for File System Access API objects.
- js-interop binding for Origin Private File System on Storage Manager object.
- examples to demonstrate usage of this library.
- Dart typed errors to replace vague DomException errors.
- README and CHANGELOG.

<!-- Table of releases -->
[Unreleased]: https://github.com/poirierlouis/file_system_access_api/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/poirierlouis/file_system_access_api/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/poirierlouis/file_system_access_api/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/poirierlouis/file_system_access_api/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/poirierlouis/file_system_access_api/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/poirierlouis/file_system_access_api/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/poirierlouis/file_system_access_api/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/poirierlouis/file_system_access_api/releases/tag/v0.1.0

<!-- Table of issues -->
[issue #1]: https://github.com/poirierlouis/file_system_access_api/issues/1
