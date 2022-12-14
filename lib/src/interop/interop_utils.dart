import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

/// Declare undefined JavaScript type in Dart.
// I'm positive I don't want void.
@JS()
external Null get undefined;

/// Convert a [Map] object from Dart into a JavaScript [Object].
/// It recursively converts values too.
Object mapToJsObject(Map<dynamic, dynamic> a) {
  final obj = newObject();

  for (final key in a.keys) {
    final value = a[key];

    if (value is Map) {
      setProperty(obj, key, mapToJsObject(value));
    } else {
      setProperty(obj, key, value);
    }
  }
  return obj;
}

/// Returns true when DomException [error] is an unwrapped JavaScript error instance of [type], false otherwise.
///
/// e.g. AbortError in JavaScript will unwrap to a [DomException] with name "AbortError".
///
/// ```dart
/// try {
///   // ...
/// } catch (error) {
///   if (jsIsNativeError(error, "AbortError")) {
///     throw AbortError();
///   } else {
///     rethrow;
///   }
/// }
/// ```
bool jsIsNativeError(Object? error, String type) {
  if (error is DomException) {
    return error.name == type;
  }
  if (error is! String) {
    return false;
  }
  return error.contains(type);
}

/// Convert a JavaScript asynchronous [iterator] into a Dart [Stream].
Stream<T> jsAsyncIterator<T>(iterator) async* {
  while (true) {
    final next = await promiseToFuture(callMethod(iterator, "next", []));

    if (getProperty(next, "done")) {
      break;
    }
    yield getProperty(next, "value");
  }
}
