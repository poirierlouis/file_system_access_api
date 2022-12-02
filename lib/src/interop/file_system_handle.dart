import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:js/js.dart';

@JS()
abstract class FileSystemHandle {
  external String get kind;
  external String get name;

  external Promise<bool> isSameEntry(FileSystemHandle other);

  external Promise<String> queryPermission([FileSystemHandlePermissionDescriptor? descriptor]);
  external Promise<String> requestPermission([FileSystemHandlePermissionDescriptor? descriptor]);
}

@JS()
@anonymous
class FileSystemHandlePermissionDescriptor {
  external String get mode;

  external factory FileSystemHandlePermissionDescriptor({String mode});
}
