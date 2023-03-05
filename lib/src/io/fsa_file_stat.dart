import 'dart:html';
import 'dart:io' as io;

/// Partial implementation of a [FileSystemFileHandle] as a [FileStat] from `dart:io`.
///
/// Only the following asynchronous methods / properties are implemented, others will throw [UnimplementedError]:
/// - [mode]
/// - [modeString]
/// - [modified]
/// - [size]
/// - [type]
class FSAFileStat implements io.FileStat {
  const FSAFileStat(this._file, this._readAccess, this._writeAccess);

  final File _file;
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
  DateTime get modified => _file.lastModifiedDate;

  @override
  int get size => _file.size;

  @override
  io.FileSystemEntityType get type => io.FileSystemEntityType.file;
}
