import 'dart:js_util';

import 'package:file_system_access_api/src/api/file_system_kind.dart';
import 'package:file_system_access_api/src/api/permissions.dart';
import 'package:file_system_access_api/src/interop/file_system_options.dart';
import 'package:js/js.dart';

@JS()
@staticInterop
abstract class FileSystemHandle {}

/// Represents a file or directory entry. Multiple handles can represent the same entry. For the most part you do not
/// work with [FileSystemHandle] directly but rather its child interfaces [FileSystemFileHandle] and
/// [FileSystemDirectoryHandle].
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/FileSystemHandle)
extension JSFileSystemHandle on FileSystemHandle {
  /// Returns the type of entry. `file` if the associated entry is a file or `directory`.
  FileSystemKind get kind => FileSystemKind.values.byName(getProperty(this, "kind"));

  /// Returns the name of the associated entry (extension included).
  external String get name;

  /// Compares two handles to see if the associated entries (either a file or directory) match.
  Future<bool> isSameEntry(FileSystemHandle other) {
    return promiseToFuture(callMethod(this, "isSameEntry", [other]));
  }

  /// Queries the current permission state of the current handle.
  ///
  /// [mode]: can be either `read` or `readwrite`.
  ///
  /// Returns a [PermissionState] value which is one of `granted`, `denied` or `prompt`.
  ///
  /// If this returns `prompt` the website will have to call [requestPermission] before any operations on the handle
  /// can be done. If this returns `denied` any operations will reject. Usually handles returned by the local file
  /// system handle factories will initially return `granted` for their read permission state. However, other than
  /// through the user revoking permission, a handle retrieved from IndexedDB is also likely to return `prompt`.
  Future<PermissionState> queryPermission({required PermissionMode mode}) async {
    final options = [FileSystemHandlePermissionDescriptor(mode: mode.name)];
    final permission = await promiseToFuture(callMethod(this, "queryPermission", options));

    return PermissionState.values.byName(permission);
  }

  /// Requests `read` or `readwrite` permissions for the file handle.
  ///
  /// Returns a [PermissionState] value which is one of `granted`, `denied` or `prompt`.
  Future<PermissionState> requestPermission({required PermissionMode mode}) async {
    final options = [FileSystemHandlePermissionDescriptor(mode: mode.name)];
    final permission = await promiseToFuture(callMethod(this, "requestPermission", options));

    return PermissionState.values.byName(permission);
  }
}
