import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

/// To keep track of types of the API in interop declarations.
typedef Promise<T> = dynamic;

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

/// Rethrows a Dart typed error based on a JavaScript error message.
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
bool jsIsNativeError(Object? object, String expectedType) {
  if (object is DomException) {
    return object.name == expectedType;
  }
  if (object is! String) {
    return false;
  }
  return object.contains(expectedType);
}

/// Convert a JavaScript asynchronous [iterator] into a Dart [Stream].
Stream<T> jsAsyncIterator<T>(iterator) async* {
  while (true) {
    final next = await promiseToFuture(callMethod(iterator, 'next', []));

    if (getProperty(next, 'done')) {
      break;
    }
    yield getProperty(next, 'value');
  }
}
