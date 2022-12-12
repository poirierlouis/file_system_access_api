import 'dart:html';

import '../index.dart';
import '../light_storage.dart';

abstract class Tab {
  Tab({required this.storage, required this.name});

  final String name;
  final LightStorage storage;

  late final HtmlElement $view = querySelector("#$name") as HtmlElement;
  late final AnchorElement $btn = querySelector("a[href='#$name']") as AnchorElement;

  void hide() {
    $view.hide();
    $btn.className = "";
  }

  void show() {
    $view.show();
    $btn.className = "active";
  }

  Future<void> init();
  Future<void> load();
}
