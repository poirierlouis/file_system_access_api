import 'dart:async';
import 'dart:html';

import 'package:file_system_access_api/src/api/errors.dart';
import 'package:file_system_access_api/src/api/file_picker_accept_type.dart';
import 'package:file_system_access_api/src/api/file_system_directory_handle.dart';
import 'package:file_system_access_api/src/api/file_system_file_handle.dart';
import 'package:file_system_access_api/src/api/file_system_handle.dart';
import 'package:file_system_access_api/src/api/permissions.dart';
import 'package:file_system_access_api/src/api/well_known_directory.dart';
import 'package:file_system_access_api/src/interop/file_picker_accept_type.dart';
import 'package:file_system_access_api/src/interop/file_picker_options.dart';
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:js/js_util.dart' as js;

extension WindowFileSystemAccess on Window {
  /// Shows a file picker that allows a user to select a file or multiple files and returns a handle for the file(s).
  /// The user has to interact with the page or a UI element in order for this feature to work.
  ///
  /// [multiple]: true to allow multiple files selection, default to false.
  ///
  /// [excludeAcceptAllOption]: true to remove default "All files (.*)" filter, default to false.
  ///
  /// [types]: list of [FilePickerAcceptType] to provide list of accepted filters, default to an empty [List].
  ///
  /// [id]: unique string reference to suggest the directory in which the file picker opens, default to null.
  ///
  /// [startIn]: suggest the directory in which the file picker opens, default to null. It must be a
  /// [WellKnownDirectory] or a [FileSystemHandle] when provided.
  ///
  /// Return a [Future] whose fulfillment handler receives a [List] of [FileSystemFileHandle] objects.
  ///
  /// Throws an [AbortError] if a user dismisses the prompt without making a selection or if a file selected is deemed
  /// too sensitive or dangerous to be exposed to the website.
  /// Throws a [SecurityError] if method is called without prior user gesture (e.g. click event).
  Future<List<FileSystemFileHandle>> showOpenFilePicker({
    bool multiple = false,
    List<FilePickerAcceptType> types = const [],
    bool excludeAcceptAllOption = false,
    String? id,
    dynamic startIn,
  }) async {
    final interopTypes = _toInteropAcceptType(types);
    final args = _assertFilePickerOptions(id: id, startIn: startIn);

    id = args[0];
    startIn = args[1];

    final options = OpenFilePickerOptions(
      multiple: multiple,
      types: interopTypes,
      excludeAcceptAllOption: excludeAcceptAllOption,
      id: id,
      startIn: startIn,
    );
    try {
      final List<dynamic> handles = await js.promiseToFuture(js.callMethod(this, "showOpenFilePicker", [options]));

      return handles.map((handle) => handle as FileSystemFileHandle).toList(growable: false);
    } catch (error) {
      if (jsIsNativeError(error, "AbortError")) {
        throw AbortError();
      } else if (jsIsNativeError(error, "SecurityError")) {
        throw SecurityError();
      } else {
        rethrow;
      }
    }
  }

  /// Shows a file picker that allows a user to save a file. Either by selecting an existing file, or entering a name
  /// for a new file.
  /// The user has to interact with the page or a UI element in order for this feature to work.
  ///
  /// [suggestedName]: the suggested file name, default to null.
  ///
  /// [excludeAcceptAllOption]: true to remove default "All files (.*)" filter, default to false.
  ///
  /// [types]: list of [FilePickerAcceptType] to provide list of accepted filters, default to an empty [List].
  ///
  /// [id]: unique string reference to suggest the directory in which the file picker opens, default to null.
  ///
  /// [startIn]: suggest the directory in which the file picker opens, default to null. It must be a
  /// [WellKnownDirectory] or a [FileSystemHandle] when provided.
  ///
  /// Return a [Future] whose fulfillment handler receives a [FileSystemFileHandle] object.
  ///
  /// Throws an [AbortError] if a user dismisses the prompt without making a selection or if a file selected is deemed
  /// too sensitive or dangerous to be exposed to the website.
  /// Throws a [SecurityError] if method is called without prior user gesture (e.g. click event).
  Future<FileSystemFileHandle> showSaveFilePicker({
    String? suggestedName,
    List<FilePickerAcceptType> types = const [],
    bool excludeAcceptAllOption = false,
    String? id,
    dynamic startIn,
  }) async {
    final interopTypes = _toInteropAcceptType(types);
    final args = _assertFilePickerOptions(id: id, startIn: startIn);

    id = args[0];
    startIn = args[1];
    suggestedName ??= undefined;

    final options = SaveFilePickerOptions(
      suggestedName: suggestedName,
      types: interopTypes,
      excludeAcceptAllOption: excludeAcceptAllOption,
      id: id,
      startIn: startIn,
    );

    try {
      final dynamic handle = await js.promiseToFuture(js.callMethod(this, "showSaveFilePicker", [options]));

      return handle as FileSystemFileHandle;
    } catch (error) {
      if (jsIsNativeError(error, "AbortError")) {
        throw AbortError();
      } else if (jsIsNativeError(error, "SecurityError")) {
        throw SecurityError();
      } else {
        rethrow;
      }
    }
  }

  /// Shows a directory picker which allows the user to select a directory.
  /// The user has to interact with the page or a UI element in order for this feature to work.
  ///
  /// [id]: unique string reference to suggest the directory in which the file picker opens, default to null.
  ///
  /// [startIn]: suggest the directory in which the file picker opens, default to null. It must be a
  /// [WellKnownDirectory] or a [FileSystemHandle] when provided.
  ///
  /// [mode]: [PermissionMode.read] for read-only access or [PermissionMode.readwrite] for read and write access to the
  /// directory, default to [PermissionMode.read].
  ///
  /// Return a [Future] whose fulfillment handler receives a [FileSystemDirectoryHandle] object.
  ///
  /// Throws an [AbortError] if a user dismisses the prompt without making a selection or if the selected content is
  /// deemed too sensitive or dangerous to be exposed to the website.
  /// Throws a [SecurityError] if method is called without prior user gesture (e.g. click event).
  Future<FileSystemDirectoryHandle> showDirectoryPicker({
    String? id,
    dynamic startIn,
    PermissionMode mode = PermissionMode.read,
  }) async {
    final args = _assertFilePickerOptions(id: id, startIn: startIn);

    id = args[0];
    startIn = args[1];

    final options = DirectoryPickerOptions(
      id: id,
      startIn: startIn,
      mode: mode.name,
    );

    try {
      final dynamic handle = await js.promiseToFuture(js.callMethod(this, "showDirectoryPicker", [options]));

      return handle as FileSystemDirectoryHandle;
    } catch (error) {
      if (jsIsNativeError(error, "AbortError")) {
        throw AbortError();
      } else if (jsIsNativeError(error, "SecurityError")) {
        throw SecurityError();
      } else {
        rethrow;
      }
    }
  }

  /// Converts [FilePickerAcceptType] from Dart type to JS equivalent using interoperability.
  static List<FilePickerAcceptTypeOption> _toInteropAcceptType(final List<FilePickerAcceptType> types) {
    return types
        .map((type) => FilePickerAcceptTypeOption(
              description: type.description,
              accept: mapToJsObject(type.accept),
            ))
        .toList(growable: false);
  }

  /// Validates values of [id] and [startIn] as defined in
  /// [W3C Community Group Draft](https://wicg.github.io/file-system-access/#ref-for-dom-filepickeroptions-id)
  static List<dynamic> _assertFilePickerOptions({String? id, dynamic startIn}) {
    id ??= undefined;
    if (id is String) {
      if (id.length > 32) {
        throw "id's length must not be greater than 32.";
      } else if (!RegExp(r"^[A-Za-z0-9_-]+$").hasMatch(id)) {
        throw "id must use alphanumeric, '_' and '-' characters only.";
      }
    }

    startIn ??= undefined;
    if (startIn != undefined && startIn is! FileSystemHandle && startIn is! WellKnownDirectory) {
      throw "startIn must be a WellKnownDirectory or a FileSystemHandle.";
    }
    if (startIn is FileSystemHandle) {
      startIn = startIn as dynamic;
    } else if (startIn is WellKnownDirectory) {
      startIn = startIn.name;
    }
    return [id, startIn];
  }
}
