import 'dart:async';
import 'dart:html';
import 'dart:indexed_db';

import 'package:js/js.dart';

/// Workaround to serialize/deserialize native JavaScript object in IndexedDB.
/// It will serialize native JavaScript object and Dart symbols.
///
/// See [issue #50621](https://github.com/dart-lang/sdk/issues/50621)
@JS()
@staticInterop
class LightObjectStore {}

extension on LightObjectStore {
  external Request get(key);
  external Request put(value, key);
}

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
  }

  bool containsKey(String key) => _data.containsKey(key);

  dynamic operator [](String key) => _data[key];

  Future<dynamic> get(String key) async {
    if (_data.containsKey(key)) {
      return _data[key];
    }
    final twx = _db!.transaction(storeName, "readonly");
    final store = twx.objectStore(storeName) as LightObjectStore;
    final request = store.get(key);
    final value = await _completeRequest(request);

    _data[key] = value;
    return value;
  }

  Future<dynamic> set(String key, dynamic value) async {
    final twx = _db!.transaction(storeName, "readwrite");
    final store = twx.objectStore(storeName) as LightObjectStore;
    final request = store.put(value, key);
    final result = await _completeRequest(request);

    _data[key] = value;
    return result;
  }

  Future<void> clear() async {
    final twx = _db!.transaction(storeName, "readwrite");
    final store = twx.objectStore(storeName);

    store.clear();
    return twx.completed.then((_) => _data.clear());
  }

  Future<void> _init(VersionChangeEvent event) async {
    _db = event.target.result;
    if (_db == null) {
      return;
    }
    _db!.createObjectStore(storeName, autoIncrement: true);
  }

  Future<T> _completeRequest<T>(Request request) {
    final completer = Completer<T>.sync();

    request.onSuccess.listen((e) {
      T result = request.result;

      completer.complete(result);
    });
    request.onError.listen((e) {
      return completer.completeError(e);
    });
    return completer.future;
  }
}
