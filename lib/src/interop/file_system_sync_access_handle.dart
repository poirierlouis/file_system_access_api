import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
class FileSystemSyncAccessHandle {
  external void close();
  external void flush();
  external int getSize();
  external int read(Uint8List buffer, [FileSystemReadWriteOptions? options]);
  external void truncate(int newSize);
  external int write(Uint8List buffer, [FileSystemReadWriteOptions? options]);
}

@JS()
@anonymous
class FileSystemReadWriteOptions {
  external int get offset;

  external factory FileSystemReadWriteOptions({int offset = 0});
}
