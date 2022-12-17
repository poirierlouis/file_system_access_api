import 'dart:js_util';

import 'package:file_system_access_api/src/api/errors.dart';
import 'package:file_system_access_api/src/api/file_system_file_handle.dart';
import 'package:file_system_access_api/src/api/file_system_handle.dart';
import 'package:file_system_access_api/src/interop/file_system_options.dart';
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:js/js.dart';

@JS()
@staticInterop
class FileSystemDirectoryHandle extends FileSystemHandle {}

/// Provides a handle to a file system directory. The interface is accessed via the [window.showDirectoryPicker] method.
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/FileSystemDirectoryHandle)
extension JSFileSystemDirectoryHandle on FileSystemDirectoryHandle {
  /// Asynchronous iterator of [FileSystemHandle] as found in [this] directory when called.
  ///
  /// Test for the type of an handle using [FileSystemHandle.kind] such as:
  /// ```dart
  /// final filesOnly = await directory.values
  ///   .where((handle) => handle.kind == FileSystemKind.file))
  ///   .cast<FileSystemFileHandle>()
  ///   .toList();
  /// final directoriesOnly = directory.values
  ///   .where((handle) => handle.kind == FileSystemKind.directory))
  ///   .cast<FileSystemDirectoryHandle>()
  ///   .toList();
  /// ```
  ///
  /// Throws a [NotFoundError] if this requested directory could not be found at the time operation was processed.
  Stream<FileSystemHandle> get values {
    final iterator = callMethod(this, "values", []);

    return jsAsyncIterator<FileSystemHandle>(iterator).cast<FileSystemHandle>().handleError((error) {
      if (jsIsNativeError(error, "NotFoundError")) {
        throw NotFoundError();
      } else {
        throw error;
      }
    });
  }

  /// Returns a [Future] fulfilled with a [FileSystemFileHandle] for a file with the specified [name], within [this]
  /// directory.
  ///
  /// [name]: a string representing the [FileSystemHandle.name] of the file you wish to retrieve.
  ///
  /// [create]: when set to true if the file is not found, one with the specified name will be created and returned.
  /// Default false.
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted].
  /// Throws a [MalformedNameError] if the name specified is not a valid string or contains characters not allowed on
  /// the file system.
  /// Throws a [TypeMismatchError] if the named entry is a directory and not a file.
  /// Throws a [NotFoundError] if file doesn't exist and the create option is set to false or this requested directory
  /// could not be found at the time operation was processed.
  Future<FileSystemFileHandle> getFileHandle(String name, {bool create = false}) async {
    try {
      final options = [name, FileSystemGetFileOptions(create: create)];
      dynamic handle = await promiseToFuture(callMethod(this, "getFileHandle", options));

      return handle as FileSystemFileHandle;
    } catch (error) {
      if (jsIsNativeError(error, "NotAllowedError")) {
        throw NotAllowedError();
      } else if (jsIsNativeError(error, "TypeError")) {
        throw MalformedNameError();
      } else if (jsIsNativeError(error, "TypeMismatchError")) {
        throw TypeMismatchError();
      } else if (jsIsNativeError(error, "NotFoundError")) {
        throw NotFoundError();
      } else {
        rethrow;
      }
    }
  }

  /// Returns a [Future] fulfilled with a [FileSystemDirectoryHandle] for a subdirectory with the specified [name],
  /// within [this] directory.
  ///
  /// [name]: a string representing the [FileSystemHandle.name] of the subdirectory you wish to retrieve.
  ///
  /// [create]: when set to true if the directory is not found, one with the specified name will be created and
  /// returned. Default false.
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted].
  /// Throws a [TypeMismatchError] if the returned entry is a file and not a directory.
  /// Throws a [NotFoundError] if directory doesn't exist and the create option is set to false or this requested
  /// directory could not be found at the time operation was processed.
  Future<FileSystemDirectoryHandle> getDirectoryHandle(String name, {bool create = false}) async {
    try {
      final options = [name, FileSystemGetDirectoryOptions(create: create)];
      dynamic handle = await promiseToFuture(callMethod(this, "getDirectoryHandle", options));

      return handle as FileSystemDirectoryHandle;
    } catch (error) {
      if (jsIsNativeError(error, "NotAllowedError")) {
        throw NotAllowedError();
      } else if (jsIsNativeError(error, "TypeMismatchError")) {
        throw TypeMismatchError();
      } else if (jsIsNativeError(error, "NotFoundError")) {
        throw NotFoundError();
      } else {
        rethrow;
      }
    }
  }

  /// Attempts to asynchronously remove an entry if the directory handle contains a file or directory called the [name]
  /// specified.
  ///
  /// [recursive]: when set to true entries will be removed recursively, default false.
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted].
  /// Throws a [MalformedNameError] if the name is not a valid string or contains characters not allowed on the file
  /// system.
  /// Throws an [InvalidModificationError] if [recursive] is set to false and the entry to be removed has children.
  /// Throws a [NotFoundError] if an entry name is not found or matched, or this requested directory could not be found
  /// at the time operation was processed.
  Future<void> removeEntry(String name, {bool recursive = false}) {
    try {
      final options = [name, FileSystemRemoveOptions(recursive: recursive)];

      return promiseToFuture(callMethod(this, "removeEntry", options));
    } catch (error) {
      if (jsIsNativeError(error, "NotAllowedError")) {
        throw NotAllowedError();
      } else if (jsIsNativeError(error, "TypeError")) {
        throw MalformedNameError();
      } else if (jsIsNativeError(error, "InvalidModificationError")) {
        throw InvalidModificationError();
      } else if (jsIsNativeError(error, "NotFoundError")) {
        throw NotFoundError();
      } else {
        rethrow;
      }
    }
  }

  /// Returns a [List] of directory names from the parent handle to the specified child entry, with the name of the
  /// child entry as the last array item or null if [possibleDescendant] is not a descendant of this
  /// [FileSystemDirectoryHandle].
  ///
  /// [possibleDescendant]: the [FileSystemHandle.name] of the [FileSystemHandle] from which to return the relative
  /// path.
  ///
  /// Throws a [NotFoundError] if this requested directory could not be found at the time operation was processed.
  Future<List<String>?> resolve(FileSystemHandle possibleDescendant) async {
    try {
      List<dynamic>? paths = await promiseToFuture(callMethod(this, "resolve", [possibleDescendant]));

      if (paths == null || paths == undefined) {
        return null;
      }
      return List.castFrom(paths);
    } catch (error) {
      if (jsIsNativeError(error, "NotFoundError")) {
        throw NotFoundError();
      } else {
        rethrow;
      }
    }
  }
}
