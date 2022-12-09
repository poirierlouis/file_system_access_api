import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../example.dart';
import 'view_node.dart';

class ViewDirectoryNode extends ViewNode<FileSystemDirectoryHandle> {
  ViewDirectoryNode({required super.handle, required super.depth, super.parent});

  final List<ViewNode> children = [];

  bool isLoaded = false;
  bool isExpanded = false;

  Future<void> load() async {
    if (isLoaded) {
      return;
    }
    children.clear();
    await for (final handle in handle.values) {
      final child = ViewNode.fromHandle(handle, depth + 1, parent: this);

      children.add(child);
    }
    isLoaded = true;
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

  @override
  void remove() {
    dispose();
    super.remove();
  }

  @override
  HtmlElement build(ViewNodeListener onClick) {
    $dom = DivElement();

    final $tile = ViewNode.buildNodeTile(handle.name, (depth != 0) ? "folder" : "folder_open");
    final $panel = _buildPanel(onClick);
    final $icon = $tile.querySelector("span") as SpanElement;

    $tile.onClick.listen((event) => onToggleExpand(onClick, $panel, $icon));
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
    $panel.className = "tree-panel";
    return $panel;
  }
}
