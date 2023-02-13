import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../index.dart';
import '../light_storage.dart';
import '../tree/view_directory_menu.dart';
import '../tree/view_directory_node.dart';
import '../tree/view_file_menu.dart';
import 'abstract_tab.dart';

class TreeViewerTab extends Tab {
  TreeViewerTab(final LightStorage storage) : super(storage: storage, name: "tree");

  late final ButtonElement $btnOpenDirectory = $view.querySelector("button#open") as ButtonElement;
  late final ButtonElement $btnClearRecent = $view.querySelector("button#clear") as ButtonElement;

  late final DivElement $root = $view.querySelector("div#root") as DivElement;
  late final DivElement $cardLoading = $view.querySelector("div#loading") as DivElement;

  late final ViewDirectoryMenu $directoryMenu = ViewDirectoryMenu();
  late final ViewFileMenu $fileMenu = ViewFileMenu(isPrivate: false);

  FileSystemDirectoryHandle? _directory;
  ViewDirectoryNode? _tree;

  @override
  Future<void> init() async {
    final $body = document.querySelector("body") as BodyElement;

    $btnOpenDirectory.onClick.listen(openDirectoryPicker);
    $btnClearRecent.onClick.listen(clearRecent);
    $body.onClick.listen((event) {
      if ($directoryMenu.canHide(event)) {
        $directoryMenu.hide();
      } else if ($fileMenu.canHide(event)) {
        $fileMenu.hide();
      }
    });
  }

  @override
  Future<void> load() async {
    if (_directory != null) {
      return;
    }
    final handle = await storage.get("tree-recent");
    final directory = handle as FileSystemDirectoryHandle?;

    if (directory is! FileSystemDirectoryHandle) {
      return;
    }
    _directory = directory;
    try {
      final isGranted = await verifyPermission(_directory!);

      if (!isGranted) {
        return;
      }
      await showTree(_directory!);
    } on NotFoundError {
      await storage.set("tree-recent", null);
      _loading(false);
      window.alert("The last directory was not found when iterating on its files. "
          "Directory has been either moved or deleted.");
    }
  }

  Future<void> openDirectoryPicker(event) async {
    try {
      final directory = await window.showDirectoryPicker(mode: PermissionMode.read);

      await showTree(directory);
      await storage.set("tree-recent", directory);
    } on AbortError {
      window.alert("User dismissed dialog or picked a directory deemed too sensitive or dangerous.");
    } catch (error) {
      print(error);
    }
  }

  Future<void> clearRecent(event) async {
    await storage.clear();
  }

  Future<void> showTree(FileSystemDirectoryHandle directory) async {
    _clearTree();

    _loading(true);
    _tree = ViewDirectoryNode(handle: directory, depth: 0);
    await _tree!.load();

    final $dom = _tree!.build(onFileClicked);

    $root.append($dom);
    _loading(false);
  }

  void _loading(bool isLoading) {
    if (isLoading) {
      $cardLoading.show();
    } else {
      $cardLoading.hide();
    }
  }

  void _clearTree() {
    if (_tree == null) {
      return;
    }
    _tree!.remove();
    _tree = null;
    for (final $node in $root.childNodes) {
      $node.remove();
    }
  }

  void onFileClicked(FileSystemFileHandle handle) {
    final offset = handle.name.lastIndexOf(".");
    final extension = (offset == -1) ? handle.name : handle.name.substring(offset);

    if (extension.contains(RegExp(r"\.png|\.gif|\.jpg|\.webp$", caseSensitive: false))) {
      openInImageViewer(handle);
    } else if (extension.contains(RegExp(
        r"\.txt|\.md|\.yaml|\.json|\.xml|\.html|\.css|\.dart|\.js|\.ts|\.java|\.c|\.cpp$",
        caseSensitive: false))) {
      openInTextEditor(handle);
    }
  }

  void openInImageViewer(FileSystemFileHandle handle) async {
    final file = await handle.getFile();
    final image = await view.imageViewer.loadImageAsBase64(file);

    view.imageViewer.showImage(image);
    view.selectTab("viewer");
  }

  void openInTextEditor(FileSystemFileHandle handle) async {
    view.textEditor.openFile(handle);
    view.selectTab("editor");
  }
}
