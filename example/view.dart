import 'dart:html';

import 'example.dart';
import 'image_viewer_tab.dart';
import 'light_storage.dart';
import 'text_editor_tab.dart';
import 'tree_viewer_tab.dart';

class View {
  HtmlElement get $header => querySelector("header") as HtmlElement;
  HtmlElement get $unsupported => querySelector("#unsupported") as HtmlElement;
  HtmlElement get $about => querySelector("#about") as HtmlElement;
  HtmlElement get $viewer => querySelector("#viewer") as HtmlElement;
  HtmlElement get $editor => querySelector("#editor") as HtmlElement;
  HtmlElement get $tree => querySelector("#tree") as HtmlElement;

  AnchorElement get $btnTabAbout => $header.querySelector("a[href='#about']") as AnchorElement;
  AnchorElement get $btnTabViewer => $header.querySelector("a[href='#viewer']") as AnchorElement;
  AnchorElement get $btnTabEditor => $header.querySelector("a[href='#editor']") as AnchorElement;
  AnchorElement get $btnTabTree => $header.querySelector("a[href='#tree']") as AnchorElement;

  List<HtmlElement> get $tabs => [$about, $viewer, $editor, $tree];
  List<AnchorElement> get $btnTabs => [$btnTabAbout, $btnTabViewer, $btnTabEditor, $btnTabTree];

  Map<String, HtmlElement> get $tabPerName => {
        "about": $about,
        "viewer": $viewer,
        "editor": $editor,
        "tree": $tree,
      };
  Map<String, HtmlElement> get $btnTabPerName => {
        "about": $btnTabAbout,
        "viewer": $btnTabViewer,
        "editor": $btnTabEditor,
        "tree": $btnTabTree,
      };

  String tab = "about";

  ImageViewerTab imageViewer = ImageViewerTab();
  TextEditorTab textEditor = TextEditorTab();
  TreeViewerTab treeViewer = TreeViewerTab();

  void selectTab(String name) {
    $tabPerName[tab]!.hide();
    $btnTabPerName[tab]!.className = "";

    $tabPerName[name]!.show();
    $btnTabPerName[name]!.className = "active";
    tab = name;
  }

  Future<void> init(LightStorage db) async {
    for (final name in $btnTabPerName.keys) {
      $btnTabPerName[name]!.onClick.listen((event) => selectTab(name));
    }
    await imageViewer.init();
    await textEditor.init();
    await treeViewer.init(db);
  }

  void loading(bool isLoading) {
    final $card = $tree.querySelector("div#loading") as DivElement;

    if (isLoading) {
      $card.show();
    } else {
      $card.hide();
    }
  }
}
