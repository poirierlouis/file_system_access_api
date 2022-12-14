import 'package:js/js.dart';

//
// FileSystemDirectoryHandle options:
//

@JS()
@anonymous
class FileSystemGetFileOptions {
  external bool get create;

  external factory FileSystemGetFileOptions({bool create = false});
}

@JS()
@anonymous
class FileSystemGetDirectoryOptions {
  external bool get create;

  external factory FileSystemGetDirectoryOptions({bool create = false});
}

@JS()
@anonymous
class FileSystemRemoveOptions {
  external bool get recursive;

  external factory FileSystemRemoveOptions({bool recursive = false});
}

//
// FileSystemFileHandle options:
//

@JS()
@anonymous
class FileSystemCreateWritableOptions {
  external bool get keepExistingData;

  external factory FileSystemCreateWritableOptions({bool keepExistingData = false});
}

//
// FileSystemHandle options:
//

@JS()
@anonymous
class FileSystemHandlePermissionDescriptor {
  external String get mode;

  external factory FileSystemHandlePermissionDescriptor({String mode});
}

//
// FileSystemSyncAccessHandle options:
//

@JS()
@anonymous
class FileSystemReadWriteOptions {
  external int get at;

  external factory FileSystemReadWriteOptions({required int at});
}
