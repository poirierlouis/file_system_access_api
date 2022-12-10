import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import 'view_directory_node.dart';
import 'view_file_node.dart';

typedef ViewNodeListener = void Function(FileSystemFileHandle);

abstract class ViewNode<T extends FileSystemHandle> {
  ViewNode({required this.handle, required this.depth, this.parent, this.isPrivate = false});

  final ViewNode<FileSystemDirectoryHandle>? parent;
  final int depth;
  final bool isPrivate;

  final T handle;

  String get uuid => handle.hashCode.toRadixString(16);

  HtmlElement? $dom;
  String get $selector => (handle.kind == FileSystemKind.file) ? "file-$uuid" : "folder-$uuid";

  void remove({bool recursive = false}) {
    if ($dom == null) {
      return;
    }
    $dom!.remove();
    $dom = null;
    if (recursive && parent != null && parent is ViewDirectoryNode) {
      (parent as ViewDirectoryNode).removeChild(this);
    }
  }

  HtmlElement build(ViewNodeListener onClick);

  static ViewNode fromHandle(FileSystemHandle handle, int depth,
      {ViewNode<FileSystemDirectoryHandle>? parent, bool isPrivate = false}) {
    if (handle is FileSystemFileHandle) {
      return ViewFileNode(handle: handle, depth: depth + 1, parent: parent, isPrivate: isPrivate);
    } else if (handle is FileSystemDirectoryHandle) {
      return ViewDirectoryNode(handle: handle, depth: depth + 1, parent: parent, isPrivate: isPrivate);
    }
    throw "unknown kind: ${handle.kind.name}";
  }

  static DivElement buildNodeTile(String name, String icon, {String color = "icon"}) {
    final $dom = DivElement();
    final $leading = ParagraphElement();
    final $icon = buildIcon(icon);

    $dom.setAttribute("clickable", true);

    $icon.setAttribute("color", color);

    $leading.className = "tree-node";
    $leading.append($icon);
    $leading.appendText(name);

    $dom.append($leading);
    return $dom;
  }

  static SpanElement buildIcon(final String icon) {
    final $dom = SpanElement();

    $dom.className = "material-symbols-outlined";
    $dom.innerText = icon;
    return $dom;
  }
}
