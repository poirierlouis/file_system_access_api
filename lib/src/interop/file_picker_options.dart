import 'package:file_system_access_api/src/interop/file_picker_accept_type.dart';
import 'package:js/js.dart';

@JS()
@anonymous
abstract class FilePickerOptions {
  external List<FilePickerAcceptType>? get types;
  external bool get excludeAcceptAllOption;
  external String? get id;
  external dynamic get startIn;

  external factory FilePickerOptions({
    List<FilePickerAcceptType>? types,
    bool excludeAcceptAllOption = false,
    String? id,
    dynamic startIn,
  });
}

@JS()
@anonymous
class OpenFilePickerOptions extends FilePickerOptions {
  external bool get multiple;

  external factory OpenFilePickerOptions({
    bool multiple = false,
    List<FilePickerAcceptType>? types,
    bool excludeAcceptAllOption = false,
    String? id,
    dynamic startIn,
  });
}

@JS()
@anonymous
class SaveFilePickerOptions extends FilePickerOptions {
  external String? get suggestedName;

  external factory SaveFilePickerOptions({
    String? suggestedName,
    List<FilePickerAcceptType>? types,
    bool excludeAcceptAllOption = false,
    String? id,
    dynamic startIn,
  });
}

@JS()
@anonymous
class DirectoryPickerOptions {
  external String? get id;
  external dynamic get startIn;
  external String? get mode;

  external factory DirectoryPickerOptions({
    String? id,
    dynamic startIn,
    String? mode,
  });
}
