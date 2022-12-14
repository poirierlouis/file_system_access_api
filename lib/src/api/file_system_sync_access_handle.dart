import 'dart:typed_data';

import 'package:file_system_access_api/src/api/errors.dart';
import 'package:file_system_access_api/src/interop/file_system_options.dart';
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS()
@staticInterop
class FileSystemSyncAccessHandle {}

/// Represents a synchronous handle to a file system entry. The synchronous nature of the file reads and writes allows
/// for higher performance for critical methods in contexts where asynchronous operations come with high overhead, e.g.
/// WebAssembly.
///
/// This class is only accessible inside dedicated Web Workers for files within the origin private file system.
/// The interface is accessed through the [FileSystemFileHandle.createSyncAccessHandle] method.
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/FileSystemSyncAccessHandle)
extension JSFileSystemSyncAccessHandle on FileSystemSyncAccessHandle {
  /// Closes an open synchronous file handle, disabling any further operations on it and releasing the exclusive lock
  /// previously put on the file associated with the file handle.
  external void close();

  /// Persists any changes made to the file associated with the handle via the [write] method to disk.
  ///
  /// Bear in mind that you only need to call this method if you need the changes committed to disk at a specific time,
  /// otherwise you can leave the underlying operating system to handle this when it sees fit, which should be OK in
  /// most cases.
  external void flush();

  /// Returns the size of the file associated with the handle in bytes.
  ///
  /// Throws an [InvalidStateError] if the associated access handle is already closed.
  int getSize() {
    try {
      return callMethod(this, "getSize", []);
    } catch (error) {
      if (jsIsNativeError(error, "InvalidStateError")) {
        throw InvalidStateError();
      } else {
        rethrow;
      }
    }
  }

  /// Reads the content of the file associated with the handle into a specified [buffer], optionally starting to read
  /// at a given [offset]. The file cursor is updated when [read] is called to point to the byte after the last byte
  /// read.
  ///
  /// Returns the number of bytes read from the file.
  ///
  /// Throws an [InvalidStateError] if the associated access handle is already closed.
  int read(Uint8List buffer, {int? offset}) {
    try {
      final options = (offset == null) ? [buffer] : [buffer, FileSystemReadWriteOptions(at: offset)];

      return callMethod(this, "read", options);
    } catch (error) {
      if (jsIsNativeError(error, "InvalidStateError")) {
        throw InvalidStateError();
      } else {
        rethrow;
      }
    }
  }

  /// Resizes the file associated with the handle to a specified number of bytes.
  ///
  /// Throws an [InvalidStateError] if the associated access handle is already closed, or if the modification of the
  /// file's binary data otherwise fails.
  /// Throws a [QuotaExceededError] if the [newSize] is larger than the original size of the file, and exceeds the
  /// browser's storage quota.
  void truncate(int newSize) {
    try {
      return callMethod(this, "truncate", [newSize]);
    } catch (error) {
      if (jsIsNativeError(error, "InvalidStateError")) {
        throw InvalidStateError();
      } else if (jsIsNativeError(error, "QuotaExceededError")) {
        throw QuotaExceededError();
      } else {
        rethrow;
      }
    }
  }

  /// Writes the content of a specified [buffer] to the file associated with the handle, optionally writing at a given
  /// [offset] from the start of the file. The file cursor is updated when [write] is called to point to the byte after
  /// the last byte written.
  ///
  /// Returns the number of bytes written to the file.
  ///
  /// Throws an [InvalidStateError] if the associated access handle is already closed.
  int write(Uint8List buffer, {int? offset}) {
    try {
      final options = (offset == null) ? [buffer] : [buffer, FileSystemReadWriteOptions(at: offset)];

      return callMethod(this, "write", options);
    } catch (error) {
      if (jsIsNativeError(error, "InvalidStateError")) {
        throw InvalidStateError();
      } else {
        rethrow;
      }
    }
  }
}
