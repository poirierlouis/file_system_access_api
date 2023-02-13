import 'dart:html';

import 'view_actions_menu.dart';

class ViewFileMenu extends ViewActionsMenu {
  const ViewFileMenu({this.isPrivate = true}) : super(selector: "#file-menu");

  final bool isPrivate;

  DivElement get $btnRename => (isPrivate) ? $root.querySelector("#btn-rename") as DivElement : $root;
  DivElement get $btnDelete => $root.querySelector("#btn-delete") as DivElement;

  @override
  void reset() {
    if (isPrivate) {
      $btnRename.remove();
    }
    $btnDelete.remove();

    if (isPrivate) {
      $root.append(buildButton("rename", "secondary", "edit", "Rename"));
    }
    $root.append(buildButton("delete", "error", "delete", "Delete"));
  }
}
