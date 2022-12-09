import 'light_storage.dart';

abstract class Tab {
  Tab({required this.storage, required this.name});

  final String name;
  final LightStorage storage;

  Future<void> init();
  Future<void> load();
}
