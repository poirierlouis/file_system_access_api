import 'dart:html' as html show File, Blob;
import 'dart:typed_data';

import 'package:file_system_access_api/src/api/errors.dart';
import 'package:file_system_access_api/src/api/file_system_file_handle.dart' as api0;
import 'package:file_system_access_api/src/interop/file_system_file_handle.dart' as interop0;
import 'package:file_system_access_api/src/wrapper/file_system_handle.dart' as wrapper0;
import 'package:js/js_util.dart' as js;

class FileSystemFileHandle extends wrapper0.FileSystemHandle implements api0.FileSystemFileHandle {
  const FileSystemFileHandle(this._handle) : super(_handle);

  final interop0.FileSystemFileHandle _handle;

  @override
  Future<html.File> getFile() async {
    try {
      dynamic file = await js.promiseToFuture(_handle.getFile());

      return file as html.File;
    } catch (error) {
      throw NotAllowedError();
    }
  }

  @override
  Future<FileSystemWritableFileStream> createWritable({bool keepExistingData = false}) async {
    final interopOptions = interop0.FileSystemCreateWritableOptions(keepExistingData: keepExistingData);

    try {
      dynamic stream = await js.promiseToFuture(_handle.createWritable(interopOptions));

      return FileSystemWritableFileStream(stream);
    } catch (error) {
      throw NotAllowedError();
    }
  }
}

class FileSystemWritableFileStream extends WritableStream implements api0.FileSystemWritableFileStream {
  FileSystemWritableFileStream(this._stream) : super(_stream);

  final interop0.FileSystemWritableFileStream _stream;

  @override
  Future<void> writeAsArrayBuffer(Uint8List data) {
    return _write(data);
  }

  @override
  Future<void> writeAsBlob(html.Blob data) {
    return _write(data);
  }

  @override
  Future<void> writeAsText(String data) {
    return _write(data);
  }

  @override
  Future<void> seek(int position) {
    assert(position >= 0, "The byte position must be positive.");

    try {
      return js.promiseToFuture(_stream.seek(position));
    } catch (error) {
      throw NotAllowedError();
    }
  }

  @override
  Future<void> truncate(int size) {
    assert(size >= 0, "The size must be positive.");

    try {
      return js.promiseToFuture(_stream.truncate(size));
    } catch (error) {
      throw NotAllowedError();
    }
  }

  Future<void> _write(dynamic data) {
    try {
      return js.promiseToFuture(_stream.write(data));
    } catch (error) {
      throw NotAllowedError();
    }
  }
}

abstract class WritableStream implements api0.WritableStream {
  const WritableStream(this.__stream);

  final interop0.WritableStream __stream;

  @override
  bool get locked => __stream.locked;

  @override
  Future<void> abort([String? reason]) {
    try {
      return js.promiseToFuture(__stream.abort(reason));
    } catch (error) {
      throw Error();
    }
  }

  @override
  Future<void> close() {
    return js.promiseToFuture(__stream.close());
  }

  @override
  WritableStreamDefaultWriter getWriter() {
    return WritableStreamDefaultWriter(__stream.getWriter());
  }
}

class WritableStreamDefaultWriter implements api0.WritableStreamDefaultWriter {
  const WritableStreamDefaultWriter(this._writer);

  final interop0.WritableStreamDefaultWriter _writer;

  @override
  Future<void> get closed => js.promiseToFuture(_writer.closed);
  @override
  double? get desiredSize => _writer.desiredSize;
  @override
  Future<void> get ready => js.promiseToFuture(_writer.ready);

  @override
  Future<void> abort([String? reason]) {
    return js.promiseToFuture(_writer.abort(reason));
  }

  @override
  Future<void> close() {
    return js.promiseToFuture(_writer.close());
  }

  @override
  void releaseLock() {
    _writer.releaseLock();
  }

  @override
  Future<void> write(Uint8List chunk) {
    return js.promiseToFuture(_writer.write(chunk));
  }
}
