import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import 'view_directory_node.dart';
import 'view_file_node.dart';

typedef ViewNodeListener = void Function(FileSystemFileHandle);

abstract class ViewNode<T extends FileSystemHandle> {
  ViewNode({required this.handle, required this.depth, this.parent});

  final ViewNode<FileSystemDirectoryHandle>? parent;
  final int depth;

  final T handle;

  HtmlElement? $dom;

  void remove() {
    $dom?.remove();
    $dom = null;
  }

  HtmlElement build(ViewNodeListener onClick);

  static ViewNode fromHandle(FileSystemHandle handle, int depth, {ViewNode<FileSystemDirectoryHandle>? parent}) {
    if (handle is FileSystemFileHandle) {
      return ViewFileNode(handle: handle, depth: depth + 1, parent: parent);
    } else if (handle is FileSystemDirectoryHandle) {
      return ViewDirectoryNode(handle: handle, depth: depth + 1, parent: parent);
    }
    throw "unknown kind: ${handle.kind.name}";
  }

  static ParagraphElement buildNodeTile(String name, String icon) {
    final $dom = ParagraphElement();
    final iconClassName = icon.contains("folder") ? "tree-node-folder" : "tree-node-$icon";
    final $icon = buildIcon(icon);

    $dom.className = "tree-node $iconClassName";
    $dom.append($icon);
    $dom.appendText(name);
    return $dom;
  }

  static SpanElement buildIcon(final String icon) {
    final $dom = SpanElement();

    $dom.className = "material-symbols-outlined";
    $dom.innerText = icon;
    return $dom;
  }
}
