import 'package:js/js.dart';

@JS()
@anonymous
class FilePickerAcceptTypeOption {
  external String? get description;
  external dynamic get accept;

  external factory FilePickerAcceptTypeOption({
    String? description,
    dynamic accept,
  });
}
