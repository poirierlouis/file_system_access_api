import 'dart:html' as html show File, Blob;
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';

/// Represents a handle to a file system entry.
/// The interface is accessed through the [FileSystemAccess.showOpenFilePicker] method.
///
/// Note that read and write operations depend on file-access permissions that do not persist after a page refresh if
/// no other tabs for that origin remain open. The [queryPermission] method of the [FileSystemHandle] interface can be
/// used to verify permission state before accessing a file.
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/FileSystemFileHandle)
abstract class FileSystemFileHandle implements FileSystemHandle {
  /// Returns a [Future] which resolves to a [File] object representing the state on disk of the entry represented by
  /// the handle.
  ///
  /// If the file on disk changes or is removed after this method is called, the returned [File] object will likely be
  /// no longer readable.
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted] in read mode.
  /// Throws a [NotFoundError] if this requested file could not be found at the time operation was processed.
  Future<html.File> getFile();

  /// Returns a [Future] which resolves to a newly created [FileSystemWritableFileStream] object that can be used to
  /// write to a file.
  ///
  /// [keepExistingData]: if false or not specified, the temporary file starts out empty, otherwise the existing file is
  /// first copied to this temporary file.
  ///
  /// Any changes made through the stream won't be reflected in the file represented by the file handle until the stream
  /// has been closed. This is typically implemented by writing data to a temporary file, and only replacing the file
  /// represented by file handle with the temporary file when the writable filestream is closed.
  ///
  /// Throws a [NotAllowedError] if the state for the handle is not [PermissionState.granted] in readwrite mode.
  /// Throws a [NotFoundError] if this requested file could not be found at the time operation was processed.
  Future<FileSystemWritableFileStream> createWritable({bool keepExistingData = false});
}

/// A [WritableStream] object with additional convenience methods, which operates on a single file on disk. The
/// interface is accessed through the [FileSystemFileHandle.createWritable] method.
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/FileSystemWritableFileStream)
abstract class FileSystemWritableFileStream implements WritableStream {
  /// Writes content into the file, at the current file cursor offset.
  ///
  /// No changes are written to the actual file on disk until the stream has been closed. Changes are typically written
  /// to a temporary file instead. This method can also be used to seek to a byte point within the stream and truncate
  /// to modify the total bytes the file contains.
  ///
  /// Throws a [NotAllowedError] if [PermissionState] is not granted.
  Future<void> writeAsArrayBuffer(Uint8List data);

  /// Writes content into the file, at the current file cursor offset.
  ///
  /// No changes are written to the actual file on disk until the stream has been closed. Changes are typically written
  /// to a temporary file instead. This method can also be used to seek to a byte point within the stream and truncate
  /// to modify the total bytes the file contains.
  ///
  /// Throws a [NotAllowedError] if [PermissionState] is not granted.
  Future<void> writeAsBlob(html.Blob data);

  /// Writes content into the file, at the current file cursor offset.
  ///
  /// No changes are written to the actual file on disk until the stream has been closed. Changes are typically written
  /// to a temporary file instead. This method can also be used to seek to a byte point within the stream and truncate
  /// to modify the total bytes the file contains.
  ///
  /// Throws a [NotAllowedError] if [PermissionState] is not granted.
  Future<void> writeAsText(String data);

  /// Updates the file cursor offset to the [position] (in bytes) specified. The byte position starts from the top
  /// (beginning) of the file and must be positive.
  ///
  /// Throws a [NotAllowedError] if [PermissionState] is not granted.
  Future<void> seek(int position);

  /// Resizes the file associated with the stream to be the specified [size] in bytes.
  ///
  /// If the size specified is larger than the current file size this pads the file with null bytes, otherwise it
  /// truncates the file.
  ///
  /// The file cursor is also updated when [truncate] is called. If the offset is smaller than the size, it remains
  /// unchanged. If the offset is larger than size, the offset is set to that size. This ensures that subsequent writes
  /// do not error.
  ///
  /// No changes are written to the actual file on disk until the stream has been closed. Changes are typically written
  /// to a temporary file instead.
  ///
  /// Throws a [NotAllowedError] if [PermissionState] is not granted.
  Future<void> truncate(int size);
}

/// Provides a standard abstraction for writing streaming data to a destination, known as a sink. This object comes with
/// built-in backpressure and queuing.
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/WritableStream)
abstract class WritableStream {
  /// Indicates whether or not the writable stream is locked.
  bool get locked;

  /// Aborts the stream, signaling that the producer can no longer successfully write to the stream and it is to be
  /// immediately moved to an error state, with any queued writes discarded.
  ///
  /// [reason]: a string providing a human-readable reason for the abort.
  ///
  /// Throws an [Error] when the stream you are trying to abort is locked.
  Future<void> abort([String? reason]);

  /// Closes the stream.
  Future<void> close();

  /// Returns a new instance of [WritableStreamDefaultWriter] and locks the stream to that instance. While the stream is
  /// locked, no other writer can be acquired until this one is released.
  WritableStreamDefaultWriter getWriter();
}

/// Is the object returned by [WritableStream.getWriter] and once created locks the writer to the [WritableStream]
/// ensuring that no other streams can write to the underlying sink.
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/WritableStreamDefaultWriter)
abstract class WritableStreamDefaultWriter {
  /// Allows you to write code that responds to an end to the streaming process. Returns a [Future] that fulfills if the
  /// stream becomes closed, or rejects if the stream errors or the writer's lock is released.
  Future<void> get closed;

  /// Returns the desired size required to fill the stream's internal queue. Note that this can be negative if the queue
  /// is over-full.
  ///
  /// The value will be [null] if the stream cannot be successfully written to (due to either being errored, or having
  /// an abort queued up), and zero if the stream is closed.
  double? get desiredSize;

  /// Returns a [Future] that resolves when the desired size of the stream's internal queue transitions from
  /// non-positive to positive, signaling that it is no longer applying backpressure.
  Future<void> get ready;

  /// Aborts the stream, signaling that the producer can no longer successfully write to the stream and it is to be
  /// immediately moved to an error state, with any queued writes discarded.
  ///
  /// [reason]: a string providing a human-readable reason for the abort.
  ///
  /// Throws an [Error] when the stream you are trying to abort is locked.
  Future<void> abort([String? reason]);

  /// Closes the associated writable stream.
  ///
  /// Returns a [Future], which fulfills if all remaining chunks were successfully written before the close, or throws
  /// an error if a problem was encountered during the process.
  Future<void> close();

  /// Releases the writer's lock on the corresponding stream. After the lock is released, the writer is no longer
  /// active. If the associated stream is errored when the lock is released, the writer will appear errored in the same
  /// way from now on; otherwise, the writer will appear closed.
  void releaseLock();

  /// Writes a passed chunk of data to a [WritableStream] and its underlying sink.
  ///
  /// Returns a [Future] that resolves or throws to indicate the success or failure of the write operation.
  ///
  /// Note that what "success" means is up to the underlying sink; it might indicate that the chunk has been accepted,
  /// and not necessarily that it is safely saved to its ultimate destination.
  Future<void> write(Uint8List chunk);
}
