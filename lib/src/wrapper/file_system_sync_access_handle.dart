import 'dart:typed_data';

import 'package:file_system_access_api/src/api/errors.dart';
import 'package:file_system_access_api/src/api/file_system_sync_access_handle.dart' as api0;
import 'package:file_system_access_api/src/interop/file_system_sync_access_handle.dart' as interop0;
import 'package:file_system_access_api/src/interop/interop_utils.dart';

class FileSystemSyncAccessHandle implements api0.FileSystemSyncAccessHandle {
  const FileSystemSyncAccessHandle(this._handle);

  final interop0.FileSystemSyncAccessHandle _handle;

  @override
  void close() {
    _handle.close();
  }

  @override
  void flush() {
    _handle.flush();
  }

  @override
  int getSize() {
    try {
      return _handle.getSize();
    } catch (error) {
      if (jsIsNativeError(error, "InvalidStateError")) {
        throw InvalidStateError();
      } else {
        rethrow;
      }
    }
  }

  @override
  int read(Uint8List buffer, {int? offset}) {
    try {
      if (offset == null) {
        return _handle.read(buffer);
      }
      final options = interop0.FileSystemReadWriteOptions(offset: offset);

      return _handle.read(buffer, options);
    } catch (error) {
      if (jsIsNativeError(error, "InvalidStateError")) {
        throw InvalidStateError();
      } else {
        rethrow;
      }
    }
  }

  @override
  void truncate(int newSize) {
    try {
      _handle.truncate(newSize);
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

  @override
  int write(Uint8List buffer, {int? offset}) {
    try {
      if (offset == null) {
        return _handle.write(buffer);
      }
      final options = interop0.FileSystemReadWriteOptions(offset: offset);

      return _handle.write(buffer, options);
    } catch (error) {
      if (jsIsNativeError(error, "InvalidStateError")) {
        throw InvalidStateError();
      } else {
        rethrow;
      }
    }
  }
}
