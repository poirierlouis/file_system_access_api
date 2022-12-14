import 'dart:html' as html show File;

import 'package:file_system_access_api/src/interop/file_system_handle.dart';
import 'package:file_system_access_api/src/interop/file_system_sync_access_handle.dart';
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:js/js.dart';

@JS()
class FileSystemFileHandle extends FileSystemHandle {
  external Promise<html.File> getFile();
  external Promise<FileSystemWritableFileStream> createWritable([FileSystemCreateWritableOptions? options]);
  external Promise<FileSystemSyncAccessHandle> createSyncAccessHandle();
  external Promise<void> move(dynamic nameOrDirectory, [String? name]);
}

@JS()
@anonymous
class FileSystemCreateWritableOptions {
  external bool get keepExistingData;

  external factory FileSystemCreateWritableOptions({bool keepExistingData = false});
}

@JS()
class FileSystemWritableFileStream extends WritableStream {
  external Promise<void> write(dynamic data);
  external Promise<void> seek(num position);
  external Promise<void> truncate(num size);
}

@JS()
abstract class WritableStream {
  external bool get locked;

  external Promise<void> abort([Object? reason]);
  external Promise<void> close();
  external WritableStreamDefaultWriter getWriter();
}

@JS()
class WritableStreamDefaultWriter {
  external Promise<void> get closed;
  external double? get desiredSize;
  external Promise<void> get ready;

  external Promise<void> abort([Object? reason]);
  external Promise<void> close();
  external void releaseLock();
  external Promise<void> write([dynamic chunk]);
}
