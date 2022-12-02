import 'package:file_system_access_api/src/api/file_system_handle.dart' as api0;
import 'package:file_system_access_api/src/api/permissions.dart';
import 'package:file_system_access_api/src/interop/file_system_handle.dart' as interop2;
import 'package:js/js_util.dart' as js;

class FileSystemHandle implements api0.FileSystemHandle {
  const FileSystemHandle(this.handle);

  final interop2.FileSystemHandle handle;

  @override
  String get kind => handle.kind;
  @override
  String get name => handle.name;

  @override
  Future<bool> isSameEntry(api0.FileSystemHandle other) {
    return js.promiseToFuture(handle.isSameEntry((other as FileSystemHandle).handle));
  }

  @override
  Future<PermissionState> queryPermission({required PermissionMode mode}) async {
    final interopDescriptor = interop2.FileSystemHandlePermissionDescriptor(mode: mode.name);
    final permission = await js.promiseToFuture(handle.queryPermission(interopDescriptor));

    return PermissionState.values.byName(permission);
  }

  @override
  Future<PermissionState> requestPermission({required PermissionMode mode}) async {
    final interopDescriptor = interop2.FileSystemHandlePermissionDescriptor(mode: mode.name);
    final permission = await js.promiseToFuture(handle.requestPermission(interopDescriptor));

    return PermissionState.values.byName(permission);
  }

  @override
  dynamic toStorage() {
    return handle;
  }
}
