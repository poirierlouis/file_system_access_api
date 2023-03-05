import 'dart:io' as io;

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:file_system_access_api/src/io/fsa_directory_stat.dart';

/// Partial implementation of a [FileSystemDirectoryHandle] as a [Directory] from `dart:io`.
///
/// Only the following asynchronous methods / properties are implemented, others will throw [UnimplementedError]:
/// - [delete]
/// - [exists]
/// - [isAbsolute] will always return false.
/// - [list]
/// - [stat] with partial implementation; including only [mode], [modeString] and [type].
class FSADirectory implements io.Directory {
  FSADirectory(this._directory);

  final FileSystemDirectoryHandle _directory;

  @override
  io.Directory get absolute => throw UnimplementedError();

  @override
  Future<io.Directory> create({bool recursive = false}) {
    throw UnimplementedError();
  }

  @override
  void createSync({bool recursive = false}) {
    throw UnimplementedError();
  }

  @override
  Future<io.Directory> createTemp([String? prefix]) {
    throw UnimplementedError();
  }

  @override
  io.Directory createTempSync([String? prefix]) {
    throw UnimplementedError();
  }

  @override
  Future<io.FileSystemEntity> delete({bool recursive = false}) async {
    await _directory.remove(recursive: recursive);
    return this;
  }

  @override
  void deleteSync({bool recursive = false}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists() async {
    try {
      await _directory.values.first;
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  bool existsSync() {
    throw UnimplementedError();
  }

  @override
  bool get isAbsolute => false;

  @override
  Stream<io.FileSystemEntity> list({bool recursive = false, bool followLinks = true}) {
    return _directory.values.asyncExpand((entry) {
      if (entry.kind == FileSystemKind.file) {
        return Stream.value(FileSystemAccess.toFile(entry as FileSystemFileHandle));
      } else if (entry.kind == FileSystemKind.directory) {
        final handle = entry as FileSystemDirectoryHandle;
        final directory = FileSystemAccess.toDirectory(handle);

        if (recursive) {
          return directory.list(recursive: true);
        }
        return Stream.value(directory);
      }
      throw Error();
    });
  }

  @override
  List<io.FileSystemEntity> listSync({bool recursive = false, bool followLinks = true}) {
    throw UnimplementedError();
  }

  @override
  io.Directory get parent => throw UnimplementedError();

  @override
  String get path => throw UnimplementedError();

  @override
  Future<io.Directory> rename(String newPath) {
    throw UnimplementedError();
  }

  @override
  io.Directory renameSync(String newPath) {
    throw UnimplementedError();
  }

  @override
  Future<String> resolveSymbolicLinks() {
    throw UnimplementedError();
  }

  @override
  String resolveSymbolicLinksSync() {
    throw UnimplementedError();
  }

  @override
  Future<io.FileStat> stat() async {
    final canRead = await _directory.queryPermission(mode: PermissionMode.read) == PermissionState.granted;
    final canWrite = await _directory.queryPermission(mode: PermissionMode.readwrite) == PermissionState.granted;

    return FSADirectoryStat(canRead, canWrite);
  }

  @override
  io.FileStat statSync() {
    throw UnimplementedError();
  }

  @override
  Uri get uri => throw UnimplementedError();

  @override
  Stream<io.FileSystemEvent> watch({int events = io.FileSystemEvent.all, bool recursive = false}) {
    throw UnimplementedError();
  }
}
