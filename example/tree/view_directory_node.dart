import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../index.dart';
import 'view_dialog_confirm.dart';
import 'view_dialog_form.dart';
import 'view_directory_menu.dart';
import 'view_drag_context.dart';
import 'view_file_node.dart';
import 'view_node.dart';

class ViewDirectoryNode extends ViewNode<FileSystemDirectoryHandle> {
  ViewDirectoryNode({required super.handle, required super.depth, super.parent, super.isPrivate});

  final List<ViewNode> children = [];

  bool isLoaded = false;
  bool isExpanded = false;

  DivElement get $panel => $dom!.querySelector("#panel-$uuid") as DivElement;
  ViewDirectoryMenu $menu = ViewDirectoryMenu();

  Future<void> load() async {
    if (isLoaded) {
      return;
    }
    children.clear();
    await for (final handle in handle.values) {
      final child = ViewNode.fromHandle(handle, depth + 1, parent: this, isPrivate: isPrivate);

      children.add(child);
    }
    isLoaded = true;
  }

  void removeChild(ViewNode node) {
    final $child = $panel.querySelector("#${node.$selector}") as HtmlElement?;

    node.remove();
    children.remove(node);
    $child?.remove();
  }

  void dispose() {
    for (final child in children) {
      child.remove();
    }
    children.clear();
    isLoaded = false;
  }

  @override
  void remove({bool recursive = false}) {
    dispose();
    super.remove(recursive: recursive);
  }

  void onToggleExpand(ViewNodeListener onClick, DivElement $panel, SpanElement $icon) async {
    if ($panel.style.display.isEmpty) {
      $panel.hide();
      $icon.innerText = "folder";
      isExpanded = false;
      dispose();
    } else {
      $panel.show();
      $icon.innerText = "folder_open";
      isExpanded = true;
      await load();
      _buildPanel(onClick, $panel);
    }
  }

  void onShowActions(MouseEvent event, ViewNodeListener onClick) {
    event.preventDefault();
    $menu.show(event);
    $menu.$btnNewDirectory.onClick.listen((event) => onNewDirectory(onClick));
    $menu.$btnNewFile.onClick.listen((event) => onNewFile(onClick));
    if (parent != null) {
      $menu.$btnDelete.show();
      $menu.$btnDelete.onClick.listen((event) => onDelete());
    } else {
      $menu.$btnDelete.hide();
    }
  }

  void onDrop(MouseEvent event, ViewNodeListener onClick) async {
    final uuid = event.dataTransfer.getData("text/x-fsa-handle");
    var node = ViewDragContext.drop(uuid);

    if (node == null) {
      return;
    }
    if (node is! ViewFileNode) {
      print("FileSystemHandle.move() is currently not supported on directories.");
      return;
    }
    if (await _isChild(node.handle)) {
      final path = await _resolvePath(node.handle);

      print("File already present in: $path");
      return;
    }
    try {
      await node.handle.move(handle);

      node.remove(recursive: true);
      node = ViewNode.fromHandle(node.handle, depth, parent: this, isPrivate: isPrivate);
      children.add(node);
      if (isExpanded) {
        final $dom = node.build(onClick);

        $panel.append($dom);
      }
    } catch (error) {
      window.alert(error.toString());
    }
  }

  void onNewDirectory(ViewNodeListener onClick) async {
    var fileName = await ViewDialogForm.show(label: "New directory", placeholder: "Name of folder", btnLabel: "Create");

    fileName ??= "";
    if (fileName.isEmpty) {
      return;
    }
    try {
      final directory = await handle.getDirectoryHandle(fileName, create: true);

      if (directory == null) {
        return;
      }
      final node = ViewNode.fromHandle(directory, depth, parent: this, isPrivate: isPrivate);

      children.add(node);
      if (isExpanded) {
        final $dom = node.build(onClick);

        $panel.append($dom);
      }
    } catch (error) {
      window.alert(error.toString());
    }
  }

  void onNewFile(ViewNodeListener onClick) async {
    var fileName = await ViewDialogForm.show(label: "New file", placeholder: "Name of file", btnLabel: "Create");

    fileName ??= "";
    if (fileName.isEmpty) {
      return;
    }
    try {
      final file = await handle.getFileHandle(fileName, create: true);

      if (file == null) {
        return;
      }
      final node = ViewNode.fromHandle(file, depth, parent: this, isPrivate: isPrivate);

      children.add(node);
      if (isExpanded) {
        final $dom = node.build(onClick);

        $panel.append($dom);
      }
    } catch (error) {
      window.alert(error.toString());
    }
  }

  void onDelete() async {
    if (parent == null) {
      return;
    }
    final confirm = await ViewDialogConfirm.show(description: "Are you sure you want to remove this directory?");

    if (confirm != "true") {
      return;
    }
    final directory = parent!.handle;

    await directory.removeEntry(handle.name, recursive: true);
    (parent! as ViewDirectoryNode).removeChild(this);
  }

  @override
  HtmlElement build(ViewNodeListener onClick) {
    $dom = DivElement();

    final name = (handle.name.isEmpty && isPrivate) ? "/" : handle.name;
    final $tile = ViewNode.buildNodeTile(
      name,
      (depth != 0) ? "folder" : "folder_open",
      color: "primary",
    );
    final $panel = _buildPanel(onClick);
    final $icon = $tile.querySelector("span") as SpanElement;

    $tile.onClick.listen((event) => onToggleExpand(onClick, $panel, $icon));
    if (isPrivate) {
      $tile.onContextMenu.listen((event) => onShowActions(event, onClick));
      $tile.onDragOver.listen((event) => event.preventDefault());
      $tile.onDrop.listen((event) => onDrop(event, onClick));
    }
    $dom!.id = $selector;
    $dom!.append($tile);
    $dom!.append($panel);
    return $dom!;
  }

  DivElement _buildPanel(ViewNodeListener onClick, [DivElement? $panel]) {
    final appendOnly = $panel != null;

    $panel ??= DivElement();
    for (final child in children) {
      final $dom = child.build(onClick);

      $panel.append($dom);
    }
    if (appendOnly) {
      return $panel;
    }
    if (depth != 0) {
      $panel.hide();
    }
    $panel.id = "panel-$uuid";
    $panel.className = "tree-panel";
    return $panel;
  }

  Future<String> _resolvePath(FileSystemHandle file) async {
    if (parent == null) {
      return "/";
    }
    FileSystemDirectoryHandle? root = await window.navigator.storage?.getDirectory();
    List<String>? paths = await root?.resolve(file);

    if (paths == null) {
      return "/";
    }
    return "/${paths.take(paths.length - 1).join("/")}/";
  }

  Future<bool> _isChild(FileSystemHandle file) async {
    await for (final child in handle.values) {
      if (await child.isSameEntry(file)) {
        return true;
      }
    }
    return false;
  }
}
