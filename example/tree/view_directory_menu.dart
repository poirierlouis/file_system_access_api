import 'dart:html';

import '../example.dart';

class ViewDirectoryMenu {
  DivElement get $btnNewDirectory => $parent.querySelector("#btn-directory") as DivElement;
  DivElement get $btnNewFile => $parent.querySelector("#btn-file") as DivElement;
  DivElement get $btnRename => $parent.querySelector("#btn-rename") as DivElement;
  DivElement get $btnDelete => $parent.querySelector("#btn-delete") as DivElement;

  DivElement get $parent => document.querySelector("#directory-menu") as DivElement;

  bool canHide(MouseEvent event) {
    return $parent.style.display != "none" && (event.target as dynamic)?.offsetParent != $parent;
  }

  void reset() {
    $btnNewDirectory.remove();
    $btnNewFile.remove();
    $btnRename.remove();
    $btnDelete.remove();

    $parent.append(_buildButton("directory", "primary", "create_new_folder", "New directory"));
    $parent.append(_buildButton("file", "icon", "note_add", "New file"));
    $parent.append(_buildButton("rename", "secondary", "edit", "Rename"));
    $parent.append(_buildButton("delete", "error", "delete", "Delete"));
  }

  void show(MouseEvent event) {
    reset();
    $parent.style.left = "${event.client.x}px";
    $parent.style.top = "${event.client.y}px";
    $parent.show();
  }

  void hide() {
    $parent.hide();
  }

  DivElement _buildButton(String type, String color, String icon, String title) {
    final $btn = DivElement();
    final $icon = SpanElement();

    $btn.id = "btn-$type";

    $icon.className = "material-symbols-outlined";
    $icon.setAttribute("color", color);
    $icon.innerText = icon;

    $btn.append($icon);
    $btn.appendText(title);
    return $btn;
  }
}
