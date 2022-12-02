import 'package:js/js.dart';

@JS()
@anonymous
class FilePickerAcceptType {
  external String? get description;
  external dynamic get accept;

  external factory FilePickerAcceptType({
    String? description,
    dynamic accept,
  });
}
