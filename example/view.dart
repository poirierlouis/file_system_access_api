import 'dart:html';

import 'light_storage.dart';
import 'tabs/about_tab.dart';
import 'tabs/abstract_tab.dart';
import 'tabs/compression_tab.dart';
import 'tabs/image_viewer_tab.dart';
import 'tabs/opfs_editor_tab.dart';
import 'tabs/text_editor_tab.dart';
import 'tabs/tree_viewer_tab.dart';
import 'tree/view_dialog_confirm.dart';
import 'tree/view_dialog_form.dart';

class View {
  String selectedTab = "about";
  final Map<String, Tab> tabs = {};

  late final ImageViewerTab imageViewer;
  late final TextEditorTab textEditor;
  late final TreeViewerTab treeViewer;
  late final OpfsEditorTab opfsEditor;
  late final CompressionTab compression;

  late final HtmlElement $header = querySelector("header") as HtmlElement;
  late final HtmlElement $unsupported = querySelector("#unsupported") as HtmlElement;
  late final HtmlElement $about = querySelector("#about") as HtmlElement;

  Future<void> init(LightStorage db) async {
    ViewDialogForm.init();
    ViewDialogConfirm.init();

    imageViewer = ImageViewerTab(db);
    textEditor = TextEditorTab(db);
    treeViewer = TreeViewerTab(db);
    opfsEditor = OpfsEditorTab(db);
    compression = CompressionTab(db);

    tabs["about"] = AboutTab(db);
    tabs["viewer"] = imageViewer;
    tabs["editor"] = textEditor;
    tabs["tree"] = treeViewer;
    tabs["opfs"] = opfsEditor;
    tabs["compression"] = compression;

    for (final tab in tabs.values) {
      tab.$btn.onClick.listen((event) => selectTab(tab.name));
      await tab.init();
    }
  }

  void selectTab(String name, [bool withUserGesture = true]) {
    tabs[selectedTab]?.hide();
    tabs[name]?.show();
    selectedTab = name;

    if (tabs.containsKey(name) && withUserGesture) {
      tabs[name]?.load();
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
}
