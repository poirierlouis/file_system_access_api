import 'package:file_system_access_api/src/api/file_system_directory_handle.dart' as api0;
import 'package:file_system_access_api/src/api/file_system_file_handle.dart' as api1;
import 'package:file_system_access_api/src/api/file_system_handle.dart' as api2;
import 'package:file_system_access_api/src/interop/file_system_directory_handle.dart' as interop0;
import 'package:file_system_access_api/src/interop/file_system_file_handle.dart' as interop1;
import 'package:file_system_access_api/src/interop/file_system_handle.dart' as interop2;
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:file_system_access_api/src/wrapper/file_system_file_handle.dart' as wrapper0;
import 'package:file_system_access_api/src/wrapper/file_system_handle.dart' as wrapper1;
import 'package:js/js_util.dart' as js;

class FileSystemDirectoryHandle extends wrapper1.FileSystemHandle implements api0.FileSystemDirectoryHandle {
  const FileSystemDirectoryHandle(this._handle) : super(_handle);

  final interop0.FileSystemDirectoryHandle _handle;

  @override
  Stream<api2.FileSystemHandle> get values {
    final iterator = js.callMethod(_handle, "values", []);

    return jsAsyncIterator<interop2.FileSystemHandle>(iterator).map((handleInterop) {
      if (handleInterop.kind == "directory") {
        return FileSystemDirectoryHandle(handleInterop as interop0.FileSystemDirectoryHandle);
      }
      return wrapper0.FileSystemFileHandle(handleInterop as interop1.FileSystemFileHandle);
    });
  }

  @override
  Future<api1.FileSystemFileHandle?> getFileHandle(String name, [bool create = false]) async {
    dynamic dataRaw = await js.promiseToFuture(
      _handle.getFileHandle(
        name,
        interop0.FileSystemGetFileOptions(create: create),
      ),
    );

    try {
      return wrapper0.FileSystemFileHandle(dataRaw);
    } catch (error) {
      return null;
    }
  }

  @override
  Future<FileSystemDirectoryHandle?> getDirectoryHandle(String name, [bool create = false]) async {
    dynamic dataRaw = await js.promiseToFuture(
      _handle.getDirectoryHandle(
        name,
        interop0.FileSystemGetDirectoryOptions(create: create),
      ),
    );

    try {
      return FileSystemDirectoryHandle(dataRaw);
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> removeEntry(String name, [bool recursive = false]) {
    return js.promiseToFuture(_handle.removeEntry(name, interop0.FileSystemRemoveOptions(recursive: recursive)));
  }

  @override
  Future<List<String>?> resolve(api2.FileSystemHandle possibleDescendant) async {
    List<dynamic>? dataRaw = await js.promiseToFuture(
      _handle.resolve((possibleDescendant as wrapper1.FileSystemHandle).handle),
    );

    if (dataRaw == null || dataRaw == undefined) {
      return null;
    }
    return List.castFrom(dataRaw);
  }
}
