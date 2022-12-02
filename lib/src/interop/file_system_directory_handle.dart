import 'package:file_system_access_api/src/interop/file_system_file_handle.dart';
import 'package:file_system_access_api/src/interop/file_system_handle.dart';
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:js/js.dart';

@JS()
class FileSystemDirectoryHandle extends FileSystemHandle {
  external Promise<FileSystemFileHandle> getFileHandle(String name, [FileSystemGetFileOptions? options]);
  external Promise<FileSystemDirectoryHandle> getDirectoryHandle(String name, [FileSystemGetDirectoryOptions? options]);
  external Promise<void> removeEntry(String name, [FileSystemRemoveOptions? options]);
  external Promise<List<String>?> resolve(FileSystemHandle possibleDescendant);
}

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
