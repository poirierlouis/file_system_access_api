import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import 'view_node.dart';

class ViewFileNode extends ViewNode<FileSystemFileHandle> {
  ViewFileNode({required super.handle, required super.depth, super.parent});

  @override
  HtmlElement build(ViewNodeListener onClick) {
    $dom = ViewNode.buildNodeTile(handle.name, "draft");

    $dom!.style.cursor = "pointer";
    $dom!.onClick.listen((event) => onClick(handle));
    return $dom!;
  }
}
