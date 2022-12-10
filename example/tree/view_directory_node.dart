import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../example.dart';
import 'view_dialog_confirm.dart';
import 'view_dialog_form.dart';
import 'view_directory_menu.dart';
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
    final $child = $panel.querySelector("#${node.$selector}") as HtmlElement;

    node.remove();
    children.remove(node);
    $child.remove();
  }

  void dispose() {
    for (final child in children) {
      child.remove();
    }
    children.clear();
    isLoaded = false;
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
  void remove() {
    dispose();
    super.remove();
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
}
