import 'dart:html';

import '../index.dart';
import 'view_actions_menu.dart';

class ViewFileMenu extends ViewActionsMenu {
  const ViewFileMenu({this.isPrivate = true}) : super(selector: "#file-menu");

  final bool isPrivate;

  DivElement get $btnRename => $root.querySelector("#btn-rename") as DivElement;
  DivElement get $btnDelete => $root.querySelector("#btn-delete") as DivElement;

  @override
  void reset() {
    if (isPrivate) {
      $btnRename.remove();
    } else {
      $btnRename.hide();
    }
    $btnDelete.remove();

    if (isPrivate) {
      $root.append(buildButton("rename", "secondary", "edit", "Rename"));
    }
    $root.append(buildButton("delete", "error", "delete", "Delete"));
  }
}
