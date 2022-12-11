import 'dart:html';

import 'abstract_tab.dart';
import 'image_viewer_tab.dart';
import 'index.dart';
import 'light_storage.dart';
import 'opfs_editor_tab.dart';
import 'text_editor_tab.dart';
import 'tree/view_dialog_confirm.dart';
import 'tree/view_dialog_form.dart';
import 'tree_viewer_tab.dart';

class View {
  String selectedTab = "about";

  late ImageViewerTab imageViewer;
  late TextEditorTab textEditor;
  late TreeViewerTab treeViewer;
  late OpfsEditorTab opfsEditor;

  List<Tab> get tabs => [imageViewer, textEditor, treeViewer, opfsEditor];
  Map<String, Tab> get tabPerName => {
        "viewer": imageViewer,
        "editor": textEditor,
        "tree": treeViewer,
        "opfs": opfsEditor,
      };

  HtmlElement get $header => querySelector("header") as HtmlElement;
  HtmlElement get $unsupported => querySelector("#unsupported") as HtmlElement;
  HtmlElement get $about => querySelector("#about") as HtmlElement;
  HtmlElement get $viewer => querySelector("#viewer") as HtmlElement;
  HtmlElement get $editor => querySelector("#editor") as HtmlElement;
  HtmlElement get $tree => querySelector("#tree") as HtmlElement;
  HtmlElement get $opfs => querySelector("#opfs") as HtmlElement;

  AnchorElement get $btnTabAbout => $header.querySelector("a[href='#about']") as AnchorElement;
  AnchorElement get $btnTabViewer => $header.querySelector("a[href='#viewer']") as AnchorElement;
  AnchorElement get $btnTabEditor => $header.querySelector("a[href='#editor']") as AnchorElement;
  AnchorElement get $btnTabTree => $header.querySelector("a[href='#tree']") as AnchorElement;
  AnchorElement get $btnTabOpfs => $header.querySelector("a[href='#opfs']") as AnchorElement;

  List<HtmlElement> get $tabs => [$about, $viewer, $editor, $tree, $opfs];
  List<AnchorElement> get $btnTabs => [$btnTabAbout, $btnTabViewer, $btnTabEditor, $btnTabTree, $btnTabOpfs];

  Map<String, HtmlElement> get $tabPerName => {
        "about": $about,
        "viewer": $viewer,
        "editor": $editor,
        "tree": $tree,
        "opfs": $opfs,
      };
  Map<String, HtmlElement> get $btnTabPerName => {
        "about": $btnTabAbout,
        "viewer": $btnTabViewer,
        "editor": $btnTabEditor,
        "tree": $btnTabTree,
        "opfs": $btnTabOpfs,
      };

  Future<void> init(LightStorage db) async {
    ViewDialogForm.init();
    ViewDialogConfirm.init();
    imageViewer = ImageViewerTab(db);
    textEditor = TextEditorTab(db);
    treeViewer = TreeViewerTab(db);
    opfsEditor = OpfsEditorTab(db);
    for (final name in $btnTabPerName.keys) {
      $btnTabPerName[name]!.onClick.listen((event) => selectTab(name));
    }
    for (final tab in tabs) {
      await tab.init();
    }
  }

  void selectTab(String name, [bool withUserGesture = true]) {
    if (!_hasTab(name)) {
      return;
    }
    $tabPerName[selectedTab]!.hide();
    $btnTabPerName[selectedTab]!.className = "";

    $tabPerName[name]!.show();
    $btnTabPerName[name]!.className = "active";
    selectedTab = name;

    if (tabPerName.containsKey(name) && withUserGesture) {
      Tab tab = tabPerName[name]!;

      tab.load();
    }
  }

  void redirectTab() {
    var url = window.location.href;

    if (!url.contains("#")) {
      return;
    }
    final tab = url.substring(url.lastIndexOf("#") + 1);

    selectTab(tab, false);
  }

  bool _hasTab(String name) {
    return $tabPerName.containsKey(name) && $btnTabPerName.containsKey(name);
  }
}
