import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:file_system_access_api/src/io/fsa_file_stat.dart';

/// Partial implementation of a [FileSystemFileHandle] as a [File] from `dart:io`.
///
/// Only the following asynchronous methods / properties are implemented, others will throw [UnimplementedError]:
/// - [delete]
/// - [exists]
/// - [isAbsolute] will always return false.
/// - [lastModified]
/// - [length]
/// - [readAsBytes]
/// - [readAsLines]
/// - [readAsString]
/// - [rename] will only change the name of the file, current Web API prevents moving the file using only a path-like
/// syntax.
/// - [stat] with partial implementation; including only [mode], [modeString], [modified], [size] and [type].
/// - [writeAsBytes]
/// - [writeAsString]
class FSAFile implements io.File {
  FSAFile(this._file);

  final FileSystemFileHandle _file;

  @override
  io.File get absolute => throw UnimplementedError();

  @override
  Future<io.File> copy(String newPath) {
    throw UnimplementedError();
  }

  @override
  io.File copySync(String newPath) {
    throw UnimplementedError();
  }

  @override
  Future<io.File> create({bool recursive = false, bool exclusive = false}) {
    throw UnimplementedError();
  }

  @override
  void createSync({bool recursive = false, bool exclusive = false}) {
    throw UnimplementedError();
  }

  @override
  Future<io.FileSystemEntity> delete({bool recursive = false}) async {
    await _file.remove();
    return this;
  }

  @override
  void deleteSync({bool recursive = false}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists() async {
    try {
      await _file.getFile();
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
  Future<DateTime> lastAccessed() {
    throw UnimplementedError();
  }

  @override
  DateTime lastAccessedSync() {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> lastModified() async {
    final file = await _file.getFile();

    return file.lastModifiedDate;
  }

  @override
  DateTime lastModifiedSync() {
    throw UnimplementedError();
  }

  @override
  Future<int> length() async {
    final file = await _file.getFile();

    return file.size;
  }

  @override
  int lengthSync() {
    throw UnimplementedError();
  }

  @override
  Future<io.RandomAccessFile> open({io.FileMode mode = io.FileMode.read}) {
    // TODO: implement with FileSystemSyncAccessHandle?
    throw UnimplementedError();
  }

  @override
  Stream<List<int>> openRead([int? start, int? end]) {
    throw UnimplementedError();
  }

  @override
  io.RandomAccessFile openSync({io.FileMode mode = io.FileMode.read}) {
    throw UnimplementedError();
  }

  @override
  io.IOSink openWrite({io.FileMode mode = io.FileMode.write, Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  io.Directory get parent => throw UnimplementedError();

  @override
  String get path => throw UnimplementedError();

  @override
  Future<Uint8List> readAsBytes() async {
    final file = await _file.getFile();
    final reader = FileReader();

    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    return reader.result as Uint8List;
  }

  @override
  Uint8List readAsBytesSync() {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) async {
    final data = await readAsString(encoding: encoding);

    return data.split("\n");
  }

  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    final file = await _file.getFile();
    final reader = FileReader();

    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final data = reader.result as Uint8List;

    return encoding.decode(data);
  }

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  Future<io.File> rename(String newPath) async {
    await _file.rename(newPath);
    return this;
  }

  @override
  io.File renameSync(String newPath) {
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
  Future setLastAccessed(DateTime time) {
    throw UnimplementedError();
  }

  @override
  void setLastAccessedSync(DateTime time) {
    throw UnimplementedError();
  }

  @override
  Future setLastModified(DateTime time) {
    throw UnimplementedError();
  }

  @override
  void setLastModifiedSync(DateTime time) {
    throw UnimplementedError();
  }

  @override
  Future<io.FileStat> stat() async {
    final file = await _file.getFile();
    final canRead = await _file.queryPermission(mode: PermissionMode.read) == PermissionState.granted;
    final canWrite = await _file.queryPermission(mode: PermissionMode.readwrite) == PermissionState.granted;

    return FSAFileStat(file, canRead, canWrite);
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

  @override
  Future<io.File> writeAsBytes(List<int> bytes, {io.FileMode mode = io.FileMode.write, bool flush = false}) async {
    final keepExistingData = (mode == io.FileMode.append || mode == io.FileMode.writeOnlyAppend);
    final stream = await _file.createWritable(keepExistingData: keepExistingData);

    await stream.writeAsArrayBuffer(Uint8List.fromList(bytes));
    await stream.close();
    return this;
  }

  @override
  void writeAsBytesSync(List<int> bytes, {io.FileMode mode = io.FileMode.write, bool flush = false}) {
    throw UnimplementedError();
  }

  @override
  Future<io.File> writeAsString(
    String contents, {
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    final keepExistingData = (mode == io.FileMode.append || mode == io.FileMode.writeOnlyAppend);
    final bytes = encoding.encode(contents);
    final stream = await _file.createWritable(keepExistingData: keepExistingData);

    await stream.writeAsArrayBuffer(Uint8List.fromList(bytes));
    await stream.close();
    return this;
  }

  @override
  void writeAsStringSync(
    String contents, {
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    throw UnimplementedError();
  }
}
