import 'package:file_system_access_api/src/api/permissions.dart';

/// Represents a file or directory entry. Multiple handles can represent the same entry. For the most part you do not
/// work with [FileSystemHandle] directly but rather its child interfaces [FileSystemFileHandle] and
/// [FileSystemDirectoryHandle].
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/FileSystemHandle)
abstract class FileSystemHandle {
  /// Returns the type of entry. This is 'file' if the associated entry is a file or 'directory'.
  String get kind;

  /// Returns the name of the associated entry (extension included).
  String get name;

  /// Compares two handles to see if the associated entries (either a file or directory) match.
  Future<bool> isSameEntry(FileSystemHandle other);

  /// Queries the current permission state of the current handle.
  ///
  /// [mode]: can be either [read] or [readwrite].
  ///
  /// Returns a [PermissionState] value which is one of [granted], [denied] or [prompt].
  ///
  /// If this returns [prompt] the website will have to call [requestPermission] before any operations on the handle
  /// can be done. If this returns [denied] any operations will reject. Usually handles returned by the local file
  /// system handle factories will initially return [granted] for their read permission state. However, other than
  /// through the user revoking permission, a handle retrieved from IndexedDB is also likely to return [prompt].
  Future<PermissionState> queryPermission({required PermissionMode mode});

  /// Requests [read] or [readwrite] permissions for the file handle.
  ///
  /// Returns a [PermissionState] value which is one of [granted], [denied] or [prompt].
  Future<PermissionState> requestPermission({required PermissionMode mode});

  /// Returns underlying JavaScript object to store handle in IndexedDB.
  ///
  /// **Note:** this feature is not working. See this [issue](https://github.com/dart-lang/sdk/issues/50621) to follow
  /// up.
  dynamic toStorage();
}
