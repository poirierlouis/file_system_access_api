import 'dart:async';
import 'dart:html';

import 'package:file_system_access_api/src/api/errors.dart';
import 'package:file_system_access_api/src/api/file_system_directory_handle.dart';
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:js/js_util.dart' as js;

extension StorageManagerOriginPrivateFileSystem on StorageManager {
  /// Returns the root directory of the origin private file system. Creates root directory when it does not exist. Root
  /// directory shall always return [PermissionState.granted] on query and request access.
  ///
  /// Throws a [SecurityError] if method is called outside of a safe file system environment.
  ///
  /// See specification on [WHATWG's File System](https://fs.spec.whatwg.org/#sandboxed-filesystem)
  Future<FileSystemDirectoryHandle> getDirectory() async {
    try {
      final handle = await js.promiseToFuture(js.callMethod(this, "getDirectory", []));

      return handle as FileSystemDirectoryHandle;
    } catch (error) {
      if (jsIsNativeError(error, "SecurityError")) {
        throw SecurityError();
      } else {
        rethrow;
      }
    }
  }
}
