/// A Dart library to expose the File System Access API from web platform.
///
/// The web API is experimental and is only supported on Chrome, Edge and Opera browsers for now (as of 2022-11).
///
/// It provides access to user's local file system to pick files and directories through a dialog.
///
/// It returns file entries as a [List] of [FileSystemFileHandle] per file selected. A file handle provide a
/// [getFile] method to read from a [File] (from 'dart:html' package). It also provide a [createWritable] method to
/// write in a [File], as long as user granted permission.
///
/// # Permission state and mode.
///
/// A file handle provide a [queryPermission] method to test which permission is granted on file. It's also possible to
/// [requestPermission] from user to access file handle with [PermissionMode.read] or [PermissionMode.readwrite].
/// Both methods returns a [PermissionState] upon completion following user's response, which can be: [granted],
/// [denied] or [prompt].
///
/// # Open file picker
/// TODO: describe showOpenFilePicker()
///
/// ## Example
///
/// ```dart
/// void main() async {
///   try {
///     // options: default to one file selection, with all types accepted.
///     final handles = await FileSystemAccess.showOpenFilePicker(/*...options*/);
///     final handle = handles.single;
///     final file = await handle.getFile();
///     final reader = FileReader();
///
///     log("${handle.kind} name='${handle.name}' size='${file.size} bytes'");
///
///     reader.readAsText(file);
///     await reader.onLoad.first;
///     log(reader.result as String);
///
///     // I'm not using queryPermission to keep example short... but it could be used first.
///     final state = await handle.requestPermission(mode: PermissionMode.readwrite);
///
///     if (state != PermissionMode.granted) {
///       log("User did not grant read / write access on file (either denied access or dismissed prompt).");
///       return;
///     }
///     final stream = await handle.createWritable(keepExistingData: true);
///
///     await stream.write("This message will be appended at the end of the file.");
///     await stream.write("File's content will be written on disk only after close() completed.");
///     await stream.close();
///   } on AbortError {
///     log("User dismissed dialog, or picked a file deemed too sensitive or dangerous to be exposed to the website.");
///     return;
///   }
/// }
/// ```
///
/// # Save file picker
/// TODO: describe showSaveFilePicker()
///
/// ## Example
///
/// ```dart
/// void main() async {
///
/// }
/// ```
///
/// # Directory file picker
/// TODO: describe showDirectoryFilePicker()
///
/// ## Example
///
/// ```dart
/// void main() async {
///   final directory = await FileSystemAccess.showDirectoryPicker();
///
///   await ls(directory);
/// }
///
/// Future<void> ls(final FileSystemDirectoryHandle directory, [int indent = 0]) async {
///   final align = "  " * indent;
///
///   await for (final handle in directory.values) {
///     if (handle is FileSystemFileHandle) {
///       log("$align${handle.name}");
///     } else if (handle is FileSystemDirectoryHandle) {
///       log("$align${handle.name}/");
///       await ls(handle, indent + 1);
///     }
///   }
/// }
/// ```
///
/// # See also
///
/// Introduction to the web API with examples on [web.dev](https://web.dev/file-system-access/)
///
/// Documentation on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/File_System_Access_API)
///
/// Specification on [W3C Community Group Draft Report](https://wicg.github.io/file-system-access/)
///
library file_system_access_api;

export 'src/api/errors.dart';
export 'src/api/file_picker_accept_type.dart';
export 'src/api/file_system_directory_handle.dart';
export 'src/api/file_system_file_handle.dart';
export 'src/api/file_system_handle.dart';
export 'src/api/permissions.dart';
export 'src/api/well_known_directory.dart';
export 'src/file_system_access_api_base.dart';
