import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import 'example.dart';
import 'light_storage.dart';

class TreeViewerTab {
  HtmlElement get $view => querySelector("#tree") as HtmlElement;

  ButtonElement get $btnOpenDirectory => $view.querySelector("button#open") as ButtonElement;
  ButtonElement get $btnClearRecent => $view.querySelector("button#clear") as ButtonElement;

  DivElement get $root => $view.querySelector("div#root") as DivElement;
  DivElement get $cardLoading => $view.querySelector("div#loading") as DivElement;
  DivElement get $cardError => $view.querySelector("div#error") as DivElement;

  LightStorage? _storage;

  Future<void> init(LightStorage storage) async {
    _storage = storage;

    $btnOpenDirectory.onClick.listen(openDirectoryPicker);
    $btnClearRecent.onClick.listen(clearRecent);

    final handle = storage["tree-recent"];
    final directory = window.fromStorage(handle);

    if (directory == null || directory is! FileSystemDirectoryHandle) {
      return;
    }
    await showTree(directory);
  }

  Future<void> openDirectoryPicker(event) async {
    $cardError.hide();
    try {
      final directory = await window.showDirectoryPicker(mode: PermissionMode.read);

      await showTree(directory);
      await _storage!.set("tree-recent", directory.toStorage());
    } on AbortError {
      $cardError.show();
    } catch (error) {
      print(error);
    }
  }

  Future<void> clearRecent(event) async {
    await _storage!.clear();
  }

  Future<void> showTree(FileSystemDirectoryHandle directory) async {
    _clearTree();
    _loading(true);
    final dynamic tree = await traverseTree(directory);

    $root.append(buildDOMTree(tree));
    _loading(false);
  }

  Future<dynamic> traverseTree(FileSystemHandle handle, {int depthLimit = 1}) async {
    if (handle is FileSystemFileHandle) {
      final file = await handle.getFile();

      return {
        "type": handle.kind,
        "size": file.size,
        "name": handle.name,
        "handle": handle,
      };
    } else if (handle is FileSystemDirectoryHandle) {
      final children = [];
      bool loaded = false;

      if (depthLimit > 0) {
        await for (final subHandle in handle.values) {
          final child = await traverseTree(subHandle, depthLimit: depthLimit - 1);

          children.add(child);
        }
        loaded = true;
      }
      return {
        "type": handle.kind,
        "name": handle.name,
        "handle": handle,
        "loaded": loaded,
        "files": children,
      };
    }
    return {"type": "unknown"};
  }

  void _loading(bool isLoading) {
    if (isLoading) {
      $cardLoading.show();
    } else {
      $cardLoading.hide();
    }
  }

  void _clearTree() {
    for (final $node in $root.childNodes) {
      $node.remove();
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

  HtmlElement buildDOMTree(dynamic tree, {int depth = 0}) {
    if (tree["type"] == "file") {
      return buildFileDOMElement(tree);
    } else if (tree["type"] == "directory") {
      return buildDirectoryDOMElement(tree, depth: depth);
    }
    ParagraphElement $node = ParagraphElement();

    $node.innerText = "Unknown";
    return $node;
  }

  HtmlElement buildDirectoryDOMElement(dynamic tree, {int depth = 0}) {
    final $node = DivElement();
    final $name = buildHandleDOMElement(name: tree["name"], icon: (depth != 0) ? "folder" : "folder_open");
    final $panel = buildPanelDOMElement(tree["files"], depth: depth);

    $name.onClick.listen((event) async {
      final $icon = $name.querySelector("span") as SpanElement;

      if ($panel.style.display.isEmpty) {
        $panel.style.display = "none";
        $icon.innerText = "folder";
      } else {
        $panel.style.display = "";
        $icon.innerText = "folder_open";
        await buildLazyDirectoryDOMElement(tree, depth: depth, $panel: $panel);
      }
    });
    $node.append($name);
    $node.append($panel);
    return $node;
  }

  HtmlElement buildFileDOMElement(dynamic leaf) {
    final $node = buildHandleDOMElement(name: leaf["name"], icon: "draft");
    final handle = leaf["handle"] as FileSystemFileHandle;
    final offset = handle.name.lastIndexOf(".");
    final extension = (offset == -1) ? handle.name : handle.name.substring(offset);

    if (extension.contains(RegExp(r"\.png|\.gif|\.jpg|\.webp$", caseSensitive: false))) {
      $node.style.cursor = "pointer";
      $node.onClick.listen((event) => openInImageViewer(handle));
    } else if (extension.contains(
        RegExp(r"\.txt|\.md|\.json|\.xml|\.html|\.css|\.dart|\.js|\.ts|\.java|\.c|\.cpp$", caseSensitive: false))) {
      $node.style.cursor = "pointer";
      $node.onClick.listen((event) => openInTextEditor(handle));
    }
    return $node;
  }

  ParagraphElement buildHandleDOMElement({required String name, required String icon}) {
    final $node = ParagraphElement();
    final iconClassName = icon.contains("folder") ? "tree-node-folder" : "tree-node-$icon";
    final $icon = buildIconDOMElement(icon);

    $node.className = "tree-node $iconClassName";
    $node.append($icon);
    $node.appendText(name);
    return $node;
  }

  HtmlElement buildPanelDOMElement(dynamic files, {required int depth, HtmlElement? $panel}) {
    final appendOnly = $panel != null;

    $panel ??= DivElement();
    for (final file in files) {
      final $node = buildDOMTree(file, depth: depth + 1);

      $panel.append($node);
    }
    if (appendOnly) {
      return $panel;
    }
    if (depth != 0) {
      $panel.hide();
    }
    $panel.className = "tree-panel";
    return $panel;
  }

  Future<void> buildLazyDirectoryDOMElement(dynamic tree, {required int depth, required HtmlElement $panel}) async {
    if (tree["loaded"] == true) {
      return;
    }
    final leaf = await traverseTree(tree["handle"], depthLimit: 1);

    tree["loaded"] = true;
    tree["files"] = leaf["files"];
    buildPanelDOMElement(tree["files"], depth: depth, $panel: $panel);
  }

  HtmlElement buildIconDOMElement(final String icon) {
    final $node = SpanElement();

    $node.className = "material-symbols-outlined";
    $node.innerText = icon;
    return $node;
  }
}
