import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import 'abstract_tab.dart';
import 'example.dart';
import 'light_storage.dart';
import 'tree/view_directory_menu.dart';
import 'tree/view_directory_node.dart';
import 'tree/view_file_menu.dart';

class OpfsEditorTab extends Tab {
  OpfsEditorTab(final LightStorage storage) : super(storage: storage, name: "tree");

  HtmlElement get $view => querySelector("#opfs") as HtmlElement;

  DivElement get $root => $view.querySelector("div#root") as DivElement;
  ViewDirectoryMenu get $directoryMenu => ViewDirectoryMenu();
  ViewFileMenu get $fileMenu => ViewFileMenu();

  FileSystemDirectoryHandle? _directory;
  ViewDirectoryNode? _tree;

  @override
  Future<void> init() async {
    final $body = document.querySelector("body") as BodyElement;

    $body.onClick.listen((event) {
      if ($directoryMenu.canHide(event)) {
        $directoryMenu.hide();
      } else if ($fileMenu.canHide(event)) {
        $fileMenu.hide();
      }
    });
    return load();
  }

  @override
  Future<void> load() async {
    if (_directory != null) {
      return;
    }
    final directory = await window.navigator.storage?.getDirectory();

    if (directory == null) {
      return;
    }
    _directory = directory;
    try {
      final isGranted = await verifyPermission(_directory!);

      if (!isGranted) {
        return;
      }
      await showTree(_directory!);
    } catch (error) {
      window.alert(error.toString());
    }
  }

  Future<void> showTree(FileSystemDirectoryHandle directory) async {
    _clearTree();

    _tree = ViewDirectoryNode(handle: directory, depth: 0, isPrivate: true);
    await _tree!.load();

    final $dom = _tree!.build(onFileClicked);

    $root.append($dom);
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
