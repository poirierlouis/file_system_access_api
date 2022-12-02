/// Consists of an optional [description] and a number of MIME types and extensions ([accept]). If no [description] is
/// provided one will be generated. Extensions have to be strings that start with a "." and only contain valid suffix
/// code points. Additionally extensions are limited to a length of 16 characters.
///
/// Common MIME types on
/// [MDN Web Docs](https://developer.mozilla.org/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)
class FilePickerAcceptType {
  const FilePickerAcceptType({this.description, required this.accept});

  /// An optional description of the category of files types allowed.
  final String? description;

  /// A [Map] with the keys set to the MIME type and the values a [List] of file extensions.
  ///
  /// ```dart
  /// e.g. {"image/png+gif+jpg": [".png", ".gif", ".jpg"]}
  /// ```
  final Map<String, List<String>> accept;
}
