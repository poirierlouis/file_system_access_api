import 'package:file_system_access_api/src/api/file_system_file_handle.dart';
import 'package:file_system_access_api/src/api/file_system_handle.dart';

/// Provides a handle to a file system directory. The interface is accessed via the
/// [FileSystemAccess.showDirectoryPicker] method.
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/FileSystemDirectoryHandle)
abstract class FileSystemDirectoryHandle implements FileSystemHandle {
  /// Asynchronous iterator of [FileSystemHandle] as found in [this] directory when called.
  ///
  /// Test for the type of an handle using [is] keyword or [kind] such as:
  /// ```dart
  /// final filesOnly = await directory.values
  ///   .where((handle) => handle is FileSystemFileHandle))
  ///   .cast<FileSystemFileHandle>()
  ///   .toList();
  /// final directoriesOnly = directory.values
  ///   .where((handle) => handle.kind == "directory"))
  ///   .cast<FileSystemDirectoryHandle>()
  ///   .toList();
  ///
  /// ```.
  ///
  /// Throws a [NotFoundError] if this requested directory could not be found at the time operation was processed.
  Stream<FileSystemHandle> get values;

  /// Returns a [Future] fulfilled with a [FileSystemFileHandle] for a file with the specified [name], within [this]
  /// directory.
  ///
  /// [name]: a string representing the [FileSystemHandle.name] of the file you wish to retrieve.
  ///
  /// [create]: when set to [true] if the file is not found, one with the specified name will be created and returned.
  /// Default [false].
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted].
  /// Throws a [MalformedNameError] if the name specified is not a valid string or contains characters not allowed on
  /// the file system.
  /// Throws a [TypeMismatchError] if the named entry is a directory and not a file.
  /// Throws a [NotFoundError] if file doesn't exist and the create option is set to [false] or this requested directory
  /// could not be found at the time operation was processed.
  Future<FileSystemFileHandle?> getFileHandle(String name, [bool create = false]);

  /// Returns a [Future] fulfilled with a [FileSystemDirectoryHandle] for a subdirectory with the specified [name],
  /// within [this] directory.
  ///
  /// [name]: a string representing the [FileSystemHandle.name] of the subdirectory you wish to retrieve.
  ///
  /// [create]: when set to [true] if the directory is not found, one with the specified name will be created and
  /// returned. Default [false].
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted].
  /// Throws a [TypeMismatchError] if the returned entry is a file and not a directory.
  /// Throws a [NotFoundError] if directory doesn't exist and the create option is set to [false] or this requested
  /// directory could not be found at the time operation was processed.
  Future<FileSystemDirectoryHandle?> getDirectoryHandle(String name, [bool create = false]);

  /// Attempts to asynchronously remove an entry if the directory handle contains a file or directory called the [name]
  /// specified.
  ///
  /// [recursive]: when set to [true] entries will be removed recursively, default [false].
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted].
  /// Throws a [MalformedNameError] if the name is not a valid string or contains characters not allowed on the file
  /// system.
  /// Throws an [InvalidModificationError] if [recursive] is set to [false] and the entry to be removed has children.
  /// Throws a [NotFoundError] if an entry name is not found or matched, or this requested directory could not be found
  /// at the time operation was processed.
  Future<void> removeEntry(String name, [bool recursive = false]);

  /// Returns a [List] of directory names from the parent handle to the specified child entry, with the name of the
  /// child entry as the last array item or [null] if [possibleDescendant] is not a descendant of this
  /// [FileSystemDirectoryHandle].
  ///
  /// [possibleDescendant]: the [FileSystemHandle.name] of the [FileSystemHandle] from which to return the relative
  /// path.
  ///
  /// Throws a [NotFoundError] if this requested directory could not be found at the time operation was processed.
  Future<List<String>?> resolve(FileSystemHandle possibleDescendant);
}
