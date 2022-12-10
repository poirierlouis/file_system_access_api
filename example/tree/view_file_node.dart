import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import 'view_dialog_confirm.dart';
import 'view_dialog_form.dart';
import 'view_directory_node.dart';
import 'view_file_menu.dart';
import 'view_node.dart';

class ViewFileNode extends ViewNode<FileSystemFileHandle> {
  ViewFileNode({required super.handle, required super.depth, super.parent, super.isPrivate});

  ViewFileMenu $menu = ViewFileMenu();

  void onShowActions(MouseEvent event) {
    event.preventDefault();
    $menu.show(event);
    $menu.$btnRename.onClick.listen((event) => onRename());
    $menu.$btnDelete.onClick.listen((event) => onDelete());
  }

  void onRename() async {
    var fileName = await ViewDialogForm.show(label: "Rename file", placeholder: handle.name, btnLabel: "Rename");

    fileName ??= "";
    if (fileName.isEmpty) {
      return;
    }
    try {
      await handle.rename(fileName);

      final $tile = $dom!.querySelector("p") as ParagraphElement;
      final $icon = ViewNode.buildIcon("draft");

      $tile.innerHtml = "";
      $icon.setAttribute("color", "icon");

      $tile.append($icon);
      $tile.appendText(fileName);
    } catch (error) {
      window.alert(error.toString());
    }
  }

  void onDelete() async {
    if (parent == null) {
      return;
    }
    final confirm = await ViewDialogConfirm.show(description: "Are you sure you want to remove this file?");

    if (confirm != "true") {
      return;
    }
    final directory = parent!.handle;

    await directory.removeEntry(handle.name);
    (parent! as ViewDirectoryNode).removeChild(this);
  }

  @override
  HtmlElement build(ViewNodeListener onClick) {
    $dom = ViewNode.buildNodeTile(handle.name, "draft", color: "icon");

    $dom!.id = $selector;
    $dom!.onClick.listen((event) => onClick(handle));
    if (isPrivate) {
      $dom!.onContextMenu.listen(onShowActions);
    }
    return $dom!;
  }
}
