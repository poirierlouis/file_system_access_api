import 'abstract_tab.dart';
import 'light_storage.dart';

class AboutTab extends Tab {
  AboutTab(final LightStorage storage) : super(storage: storage, name: "about");

  @override
  Future<void> init() async {
    //
  }

  @override
  Future<void> load() async {
    //
  }
}
