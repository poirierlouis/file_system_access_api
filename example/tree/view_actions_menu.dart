import 'dart:html';

import '../index.dart';
import 'view_node.dart';

abstract class ViewActionsMenu {
  const ViewActionsMenu({required this.selector});

  final String selector;

  DivElement get $overlay => document.querySelector("div#overlay") as DivElement;
  DivElement get $root => $overlay.querySelector(selector) as DivElement;

  void reset();

  bool canHide(MouseEvent event) {
    return $root.style.display != "none" && (event.target as dynamic)?.offsetParent != $root;
  }

  void show(MouseEvent event) {
    reset();
    _hideAll();
    $root.style.left = "${event.client.x}px";
    $root.style.top = "${event.client.y}px";
    $root.onClick.listen((event) => hide());
    $root.show();
  }

  void hide() {
    $root.hide();
  }

  void _hideAll() {
    final $nodes = document.querySelectorAll(".menu");

    for (final $node in $nodes) {
      ($node as HtmlElement).hide();
    }
  }

  DivElement buildButton(String type, String color, String icon, String title) {
    final $btn = DivElement();
    final $icon = ViewNode.buildIcon(icon);

    $btn.id = "btn-$type";
    $icon.setAttribute("color", color);

    $btn.append($icon);
    $btn.appendText(title);
    return $btn;
  }
}
