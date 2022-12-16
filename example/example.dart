import 'dart:html';
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js;

void main() async {
  // Check current browser supports API.
  if (!FileSystemAccess.supported) {
    return;
  }
  await pickFiles();
  await pickDirectory();
  await pickNewFile();
  await originPrivateFileSystem();
  await webWorker();
}

/// Pick files and append text in each file.
Future<void> pickFiles() async {
  List<FileSystemFileHandle> handles = await window.showOpenFilePicker(
    multiple: true,
    startIn: WellKnownDirectory.documents,
  );

  for (final handle in handles) {
    File file = await handle.getFile();

    print("file: ${handle.name}\t${file.size} bytes");
    // Read file with a FileReader like any other File from 'dart:html'.
    // ...

    // Write in each file, with appending mode
    FileSystemWritableFileStream stream = await handle.createWritable(keepExistingData: true);

    await stream.writeAsText("This is the way");
    await stream.close();
  }
}

/// Pick directory and remove all its entries.
Future<void> pickDirectory() async {
  FileSystemDirectoryHandle directory = await window.showDirectoryPicker(mode: PermissionMode.readwrite);

  // Iterable values might differ between calls depending on directory's content.
  await for (final handle in directory.values) {
    await directory.removeEntry(handle.name, recursive: handle.kind == FileSystemKind.directory);
  }
}

/// Pick new file and write content.
Future<void> pickNewFile() async {
  FileSystemFileHandle handle = await window.showSaveFilePicker(suggestedName: "dummy.js");

  final stream = await handle.createWritable();

  await stream.writeAsText("console.log('This is the way');");
  await stream.close();
}

/// Origin Private File System
Future<void> originPrivateFileSystem() async {
  FileSystemDirectoryHandle? root = await window.navigator.storage?.getDirectory();

  if (root == null) {
    return;
  }
  // Create file and directory in "root" of OPFS
  final handle = await root.getFileHandle("pubspec.yaml", create: true);
  final directory = await root.getDirectoryHandle("lib", create: true);

  if (handle == null || directory == null) {
    return;
  }
  // Rename file
  await handle.rename("main.dart");

  // Move to lib/
  await handle.move(directory);

  // Move back and rename
  await handle.move(root, name: "pubspec.yaml");
}

/// Declare navigator like in a Web Worker context.
@JS()
external dynamic get navigator;

/// Web Worker, copies a file to another one within Origin Private File System.
Future<void> webWorker() async {
  // Cast to use library's extension, when building in a Web Worker.
  StorageManager? storage = js.getProperty(navigator, "storage") as StorageManager?;
  FileSystemDirectoryHandle? root = await storage?.getDirectory();

  if (root == null) {
    return;
  }
  final source = await root.getFileHandle("linux.iso");
  final destination = await root.getFileHandle("xunil.iso", create: true);

  if (source == null || destination == null) {
    return;
  }
  FileSystemSyncAccessHandle src = await source.createSyncAccessHandle();
  FileSystemSyncAccessHandle dst = await destination.createSyncAccessHandle();
  Uint8List buffer = Uint8List(src.getSize());

  src.read(buffer);
  dst.write(buffer);
  dst.flush();

  src.close();
  dst.close();
}
