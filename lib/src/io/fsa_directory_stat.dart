import 'dart:io' as io;

import 'package:file_system_access_api/file_system_access_api.dart';

/// Partial implementation of a [FileSystemDirectoryHandle] as a [FileStat] from `dart:io`.
///
/// Only the following asynchronous methods / properties are implemented, others will throw [UnimplementedError]:
/// - [mode]
/// - [modeString]
/// - [type]
class FSADirectoryStat implements io.FileStat {
  const FSADirectoryStat(this._readAccess, this._writeAccess);

  final bool _readAccess;
  final bool _writeAccess;

  @override
  DateTime get accessed => throw UnimplementedError();

  @override
  DateTime get changed => throw UnimplementedError();

  @override
  int get mode {
    int permissions = 0;

    if (_readAccess) {
      permissions += 4;
    }
    if (_writeAccess) {
      permissions += 2;
    }
    return permissions;
  }

  @override
  String modeString() {
    String r = "-";
    String w = "-";

    if (_readAccess) {
      r = "r";
    }
    if (_writeAccess) {
      w = "w";
    }
    return "$r$w-";
  }

  @override
  DateTime get modified => throw UnimplementedError();

  @override
  int get size => throw UnimplementedError();

  @override
  io.FileSystemEntityType get type => io.FileSystemEntityType.directory;
}
