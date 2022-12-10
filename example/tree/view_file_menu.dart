import 'dart:html';

import 'view_actions_menu.dart';

class ViewFileMenu extends ViewActionsMenu {
  const ViewFileMenu() : super(selector: "#file-menu");

  DivElement get $btnRename => $root.querySelector("#btn-rename") as DivElement;
  DivElement get $btnDelete => $root.querySelector("#btn-delete") as DivElement;

  @override
  void reset() {
    $btnRename.remove();
    $btnDelete.remove();

    $root.append(buildButton("rename", "secondary", "edit", "Rename"));
    $root.append(buildButton("delete", "error", "delete", "Delete"));
  }
}
