import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../light_storage.dart';
import 'abstract_tab.dart';

class TextEditorTab extends Tab {
  TextEditorTab(final LightStorage storage) : super(storage: storage, name: "editor");

  late final ButtonElement $btnNew = $view.querySelector("button#new") as ButtonElement;
  late final ButtonElement $btnOpen = $view.querySelector("button#open") as ButtonElement;
  late final ButtonElement $btnSave = $view.querySelector("button#save") as ButtonElement;
  late final TextAreaElement $textarea = $view.querySelector("textarea") as TextAreaElement;

  FileSystemFileHandle? handle;

  final types = [
    FilePickerAcceptType(
      description: "Web files",
      accept: {
        "text/txt+json+xml+html+css": [".txt", ".json", ".xml", ".html", ".css"]
      },
    ),
    FilePickerAcceptType(
      description: "Programming files",
      accept: {
        "application/dart+js+ts+java+c+cpp": [".dart", ".js", ".ts", ".java", ".c", ".cpp"]
      },
    ),
  ];

  @override
  Future<void> init() async {
    $btnNew.onClick.listen(newFile);
    $btnOpen.onClick.listen(selectFile);
    $btnSave.onClick.listen(saveFile);
  }

  @override
  Future<void> load() async {}

  void newFile(event) {
    $textarea.value = "";
    handle = null;
  }

  Future<void> selectFile(event) async {
    try {
      final handles = await window.showOpenFilePicker(excludeAcceptAllOption: true, types: types);

      await openFile(handles.single);
    } on AbortError {
      window.alert("User dismissed dialog or picked a file deemed too sensitive or dangerous.");
    } catch (error) {
      print(error);
    }
  }

  Future<void> openFile(FileSystemFileHandle handle) async {
    try {
      this.handle = handle;
      final file = await handle.getFile();
      final data = await loadFile(file);

      $textarea.value = data;
    } catch (_) {}
  }

  Future<void> saveFile(event) async {
    if (handle == null) {
      try {
        handle = await window.showSaveFilePicker(
          suggestedName: "document.txt",
          excludeAcceptAllOption: true,
          types: types,
        );
      } on AbortError {
        window.alert("User dismissed dialog or picked a file deemed too sensitive or dangerous.");
        return;
      } catch (error) {
        print(error);
        return;
      }
    }
    final permission = await verifyPermission(handle!);

    if (!permission) {
      return;
    }
    try {
      final stream = await handle!.createWritable();
      final data = $textarea.value ?? "";

      await stream.writeAsText(data);
      await stream.close();
    } on NotFoundError {
      window.alert("The file was not found when writing data. File has been either moved or deleted.");
    }
  }

  Future<String> loadFile(File file) async {
    final reader = FileReader();

    reader.readAsText(file);
    await reader.onLoad.first;
    return reader.result as String;
  }

  Future<bool> verifyPermission(FileSystemFileHandle handle) async {
    var state = await handle.queryPermission(mode: PermissionMode.readwrite);

    if (state == PermissionState.granted) {
      return true;
    }
    state = await handle.requestPermission(mode: PermissionMode.readwrite);
    return state == PermissionState.granted;
  }
}
