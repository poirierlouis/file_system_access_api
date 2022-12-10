import 'dart:html';

import 'view_actions_menu.dart';

class ViewDirectoryMenu extends ViewActionsMenu {
  const ViewDirectoryMenu() : super(selector: "#directory-menu");

  DivElement get $btnNewDirectory => $root.querySelector("#btn-directory") as DivElement;
  DivElement get $btnNewFile => $root.querySelector("#btn-file") as DivElement;
  DivElement get $btnDelete => $root.querySelector("#btn-delete") as DivElement;

  @override
  void reset() {
    $btnNewDirectory.remove();
    $btnNewFile.remove();
    $btnDelete.remove();

    $root.append(buildButton("directory", "primary", "create_new_folder", "New directory"));
    $root.append(buildButton("file", "icon", "note_add", "New file"));
    $root.append(buildButton("delete", "error", "delete", "Delete"));
  }
}
