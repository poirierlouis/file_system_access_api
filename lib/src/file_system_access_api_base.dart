import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:file_system_access_api/src/interop/file_picker_accept_type.dart' as interop0;
import 'package:file_system_access_api/src/interop/file_picker_options.dart' as interop1;
import 'package:file_system_access_api/src/interop/interop_utils.dart';
import 'package:file_system_access_api/src/wrapper/file_system_directory_handle.dart' as wrapper1;
import 'package:file_system_access_api/src/wrapper/file_system_file_handle.dart' as wrapper0;
import 'package:file_system_access_api/src/wrapper/file_system_handle.dart' as wrapper2;
import 'package:js/js_util.dart' as js;

extension WindowFileSystemAccess on Window {
  /// Checks if the File System Access API is supported on the current browser.
  bool get fileSystemAccess {
    return js.hasProperty(window, "showOpenFilePicker") &&
        js.hasProperty(window, "showSaveFilePicker") &&
        js.hasProperty(window, "showDirectoryPicker");
  }

  /// Shows a file picker that allows a user to select a file or multiple files and returns a handle for the file(s).
  /// The user has to interact with the page or a UI element in order for this feature to work.
  ///
  /// [multiple]: [true] to allow multiple files selection, default to [false].
  ///
  /// [excludeAcceptAllOption]: [true] to remove default "All files (.*)" filter, default to [false].
  ///
  /// [types]: list of [FilePickerAcceptType] to provide list of accepted filters, default to an empty [List].
  ///
  /// [id]: unique string reference to suggest the directory in which the file picker opens, default to
  /// [null].
  ///
  /// [startIn]: suggest the directory in which the file picker opens, default to [null]. It must be a
  /// [WellKnownDirectory] or a [FileSystemHandle] when provided.
  ///
  /// Return a [Future] whose fulfillment handler receives a [List] of [FileSystemFileHandle] objects.
  ///
  /// Throws an [AbortError] if a user dismisses the prompt without making a selection or if a file selected is deemed
  /// too sensitive or dangerous to be exposed to the website.
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

    final options = interop1.OpenFilePickerOptions(
      multiple: multiple,
      types: interopTypes,
      excludeAcceptAllOption: excludeAcceptAllOption,
      id: id,
      startIn: startIn,
    );
    try {
      final List<dynamic> handles = await js.promiseToFuture(js.callMethod(this, "showOpenFilePicker", [options]));

      return handles.map((handle) => wrapper0.FileSystemFileHandle(handle)).toList(growable: false);
    } catch (error) {
      throw AbortError();
    }
  }

  /// Shows a file picker that allows a user to save a file. Either by selecting an existing file, or entering a name
  /// for a new file.
  /// The user has to interact with the page or a UI element in order for this feature to work.
  ///
  /// [suggestedName]: the suggested file name, default to [null].
  ///
  /// [excludeAcceptAllOption]: [true] to remove default "All files (.*)" filter, default to [false].
  ///
  /// [types]: list of [FilePickerAcceptType] to provide list of accepted filters, default to an empty [List].
  ///
  /// [id]: unique string reference to suggest the directory in which the file picker opens, default to
  /// [null].
  ///
  /// [startIn]: suggest the directory in which the file picker opens, default to [null]. It must be a
  /// [WellKnownDirectory] or a [FileSystemHandle] when provided.
  ///
  /// Return a [Future] whose fulfillment handler receives a [FileSystemFileHandle] object.
  ///
  /// Throws an [AbortError] if a user dismisses the prompt without making a selection or if a file selected is deemed
  /// too sensitive or dangerous to be exposed to the website.
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

    final interopOptions = interop1.SaveFilePickerOptions(
      suggestedName: suggestedName,
      types: interopTypes,
      excludeAcceptAllOption: excludeAcceptAllOption,
      id: id,
      startIn: startIn,
    );

    try {
      final dynamic handle = await js.promiseToFuture(js.callMethod(this, "showSaveFilePicker", [interopOptions]));

      return wrapper0.FileSystemFileHandle(handle);
    } catch (error) {
      throw AbortError();
    }
  }

  /// Shows a directory picker which allows the user to select a directory.
  /// The user has to interact with the page or a UI element in order for this feature to work.
  ///
  /// [id]: unique string reference to suggest the directory in which the file picker opens, default to
  /// [null].
  ///
  /// [startIn]: suggest the directory in which the file picker opens, default to [null]. It must be a
  /// [WellKnownDirectory] or a [FileSystemHandle] when provided.
  ///
  /// [mode]: [PermissionMode.read] for read-only access or [PermissionMode.readwrite] for read and write access to the
  /// directory, default to [PermissionMode.read].
  ///
  /// Return a [Future] whose fulfillment handler receives a [FileSystemDirectoryHandle] object.
  ///
  /// Throws an [AbortError] if a user dismisses the prompt without making a selection or if the selected content is
  /// deemed too sensitive or dangerous to be exposed to the website.
  Future<FileSystemDirectoryHandle> showDirectoryPicker({
    String? id,
    dynamic startIn,
    PermissionMode mode = PermissionMode.read,
  }) async {
    final args = _assertFilePickerOptions(id: id, startIn: startIn);

    id = args[0];
    startIn = args[1];

    final options = interop1.DirectoryPickerOptions(
      id: id,
      startIn: startIn,
      mode: mode.name,
    );

    try {
      final dynamic handle = await js.promiseToFuture(js.callMethod(this, "showDirectoryPicker", [options]));

      return wrapper1.FileSystemDirectoryHandle(handle);
    } catch (error) {
      throw AbortError();
    }
  }

  FileSystemHandle? fromStorage(dynamic handle) {
    if (handle == null) {
      return null;
    }
    if (!js.instanceOfString(handle, "FileSystemFileHandle") &&
        !js.instanceOfString(handle, "FileSystemDirectoryHandle")) {
      return null;
    }
    if (handle.kind == "file") {
      return wrapper0.FileSystemFileHandle(handle);
    } else if (handle.kind == "directory") {
      return wrapper1.FileSystemDirectoryHandle(handle);
    }
    return null;
  }

  /// Converts [FilePickerAcceptType] from Dart type to JS equivalent using interoperability.
  static List<interop0.FilePickerAcceptType> _toInteropAcceptType(final List<FilePickerAcceptType> types) {
    return types
        .map((type) => interop0.FilePickerAcceptType(
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
      startIn = (startIn as wrapper2.FileSystemHandle).handle;
    } else if (startIn is WellKnownDirectory) {
      startIn = startIn.name;
    }
    return [id, startIn];
  }
}
