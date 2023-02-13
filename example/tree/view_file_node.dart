import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../index.dart';
import 'view_dialog_confirm.dart';
import 'view_dialog_form.dart';
import 'view_drag_context.dart';
import 'view_file_menu.dart';
import 'view_node.dart';

class ViewFileNode extends ViewNode<FileSystemFileHandle> {
  ViewFileNode({required super.handle, required super.depth, super.parent, super.isPrivate});

  late final ViewFileMenu $menu = ViewFileMenu(isPrivate: isPrivate);

  void onShowActions(MouseEvent event) {
    event.preventDefault();
    $menu.show(event);
    if (isPrivate) {
      $menu.$btnRename.onClick.listen((event) => onRename());
    }
    $menu.$btnDelete.onClick.listen((event) => onDelete());
  }

  void onDrag(MouseEvent event) {
    event.dataTransfer.setData("text/x-fsa-handle", uuid);
    ViewDragContext.drag(this);
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
    final confirm = await ViewDialogConfirm.show(description: "Are you sure you want to remove this file?");

    if (confirm != "true") {
      return;
    }
    try {
      await handle.remove();
      parent!.removeChild(this);
    } catch (error) {
      if (jsIsDomError(error, "NoSuchMethodError")) {
        final directory = parent?.handle;

        if (directory == null) {
          return;
        }
        await directory.removeEntry(handle.name);
        parent!.removeChild(this);
      } else {
        window.alert(error.toString());
      }
    }
  }

  @override
  HtmlElement build(ViewNodeListener onClick) {
    $dom = ViewNode.buildNodeTile(handle.name, "draft", color: "icon");

    $dom!.id = $selector;
    $dom!.onClick.listen((event) => onClick(handle));
    if (isPrivate) {
      $dom!.draggable = true;
      $dom!.onContextMenu.listen(onShowActions);
      $dom!.onDragStart.listen(onDrag);
    } else {
      $dom!.onContextMenu.listen(onShowActions);
    }
    return $dom!;
  }
}
