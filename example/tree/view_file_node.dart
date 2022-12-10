import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../example.dart';
import 'view_dialog_confirm.dart';
import 'view_dialog_form.dart';
import 'view_directory_menu.dart';
import 'view_directory_node.dart';
import 'view_node.dart';

class ViewFileNode extends ViewNode<FileSystemFileHandle> {
  ViewFileNode({required super.handle, required super.depth, super.parent, super.isPrivate});

  ViewDirectoryMenu $menu = ViewDirectoryMenu();

  void onShowActions(MouseEvent event) {
    event.preventDefault();
    $menu.show(event);
    $menu.$parent.onClick.listen((event) => $menu.hide());
    $menu.$btnNewDirectory.hide();
    $menu.$btnNewFile.hide();
    $menu.$btnRename.show();
    $menu.$btnRename.onClick.listen((event) => onRename());
    $menu.$btnDelete.show();
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

      $icon.setAttribute("color", "icon");
      $tile.innerHtml = "";
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
