import 'dart:async';
import 'dart:html';
import 'dart:io' as io;

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:file_system_access_api/src/io/fsa_directory.dart';
import 'package:file_system_access_api/src/io/fsa_file.dart';
import 'package:js/js_util.dart' as js;

/// Helpers to bind native JavaScript objects with Dart types of this library.
class FileSystemAccess {
  /// Checks to see if File System Access API is supported on the current browser.
  static bool get supported {
    return js.hasProperty(window, "showOpenFilePicker") &&
        js.hasProperty(window, "showSaveFilePicker") &&
        js.hasProperty(window, "showDirectoryPicker");
  }

  /// Returns a list of [FileSystemHandle] from items of a DragEvent.
  static Future<List<FileSystemHandle>> fromDropEvent(Event event) async {
    final dataTransfer = js.getProperty(event, "dataTransfer");
    final items = js.getProperty(dataTransfer, "items");

    if (items == null || items == undefined) {
      return [];
    }
    // Iterate on each future of [DataTransferItem.getAsFileSystemHandle] first.
    // Awaiting in each iteration provokes an unknown behavior where only one element can be read, all other items
    // becoming null instead of being a [DataTransferItem].
    final List<Future<dynamic>> futures = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.kind == "file") {
        final promise = js.callMethod(item, "getAsFileSystemHandle", []);

        futures.add(js.promiseToFuture(promise));
      }
    }
    return Stream.fromFutures(futures)
        .asyncMap((promise) async {
          final handle = await promise;

          return handle as FileSystemHandle?;
        })
        .where((handle) => handle != null)
        .cast<FileSystemHandle>()
        .toList();
  }

  /// Converts [file] to a [File] from `dart:io` with a partial implementation.
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
  static io.File toFile(final FileSystemFileHandle file) {
    return FSAFile(file);
  }

  /// Converts [directory] to a [Directory] from `dart:io` with a partial implementation.
  ///
  /// Only the following asynchronous methods / properties are implemented, others will throw [UnimplementedError]:
  /// - [delete]
  /// - [exists]
  /// - [isAbsolute] will always return false.
  /// - [list]
  /// - [stat] with partial implementation; including only [mode], [modeString] and [type].
  static io.Directory toDirectory(final FileSystemDirectoryHandle directory) {
    return FSADirectory(directory);
  }
}
