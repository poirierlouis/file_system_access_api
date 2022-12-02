import 'dart:html';
import 'dart:indexed_db';

/// Light database layer implementation of IndexedDB to store [FileSystemHandle].
class LightStorage {
  static const String storeName = "fsa";

  Database? _db;

  final Map<String, dynamic> _data = {};

  static bool get supported => IdbFactory.supported;

  Future<void> open() async {
    _db = await window.indexedDB!.open("fsa", version: 1, onUpgradeNeeded: _init);
    if (_db == null) {
      return;
    }
    await _loadDatabase();
  }

  bool containsKey(String key) => _data.containsKey(key);

  dynamic operator [](String key) => _data[key];

  Future<dynamic> set(String key, dynamic value) async {
    final twx = _db!.transaction(storeName, "readwrite");
    final store = twx.objectStore(storeName);

    store.put(value, key);
    return twx.completed.then((_) {
      _data[key] = value;
      return value;
    });
  }

  Future<void> clear() async {
    final twx = _db!.transaction(storeName, "readwrite");
    final store = twx.objectStore(storeName);

    store.clear();
    return twx.completed.then((_) => _data.clear());
  }

  Future<int> _loadDatabase() async {
    final trx = _db!.transaction(storeName, "readonly");
    final store = trx.objectStore(storeName);
    final cursors = store.openCursor(autoAdvance: true).asBroadcastStream();

    cursors.listen((cursor) {
      _data[cursor.key as String] = cursor.value;
    });
    return cursors.length.then((_) => _data.length);
  }

  Future<void> _init(VersionChangeEvent event) async {
    _db = event.target.result;
    if (_db == null) {
      return;
    }
    _db!.createObjectStore(storeName, autoIncrement: true);
  }
}
