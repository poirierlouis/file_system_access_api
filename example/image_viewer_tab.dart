import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';

class ImageViewerTab {
  HtmlElement get $view => querySelector("#viewer") as HtmlElement;

  ButtonElement get $btnOpenImage => $view.querySelector("button") as ButtonElement;
  DivElement get $dndContainer => $view.querySelector("#drag-n-drop") as DivElement;
  ImageElement get $img => $view.querySelector("img") as ImageElement;

  Future<void> init() async {
    $btnOpenImage.onClick.listen(openImagePicker);
    listenDragAndDrop();
  }

  void listenDragAndDrop() {
    $view.addEventListener("dragover", (event) => event.preventDefault());
    $view.addEventListener("drop", (event) async {
      event.preventDefault();

      var handles = await FileSystemAccess.fromDropEvent(event);

      handles = handles
          .where((handle) =>
              handle.kind == FileSystemKind.file &&
              (handle.name.endsWith(".png") || handle.name.endsWith(".webp") || handle.name.endsWith(".jpg")))
          .toList(growable: false);
      if (handles.isEmpty) {
        window.alert("Found no image file.");
        return;
      }
      if (handles.length > 1) {
        window.alert("Opening only first image file out of ${handles.length}.");
      }
      await onImageDropped(handles.first);
    });
  }

  Future<void> onImageDropped(FileSystemHandle handle) async {
    if (handle is! FileSystemFileHandle) {
      return;
    }
    final file = await handle.getFile();
    final isImage = file.type.startsWith("image/");

    if (!isImage) {
      window.alert("File is not an image: ${handle.name}");
      return;
    }
    final image = await loadImageAsBase64(file);

    showImage(image);
  }

  Future<void> openImagePicker(event) async {
    try {
      final handles = await window.showOpenFilePicker(
        excludeAcceptAllOption: true,
        types: [
          FilePickerAcceptType(description: "Images", accept: {
            "image/png+gif+jpg+webp": [".png", ".gif", ".jpg", ".webp"]
          })
        ],
      );
      final handle = handles.single;
      final file = await handle.getFile();
      final image = await loadImageAsBase64(file);

      showImage(image);
    } on AbortError {
      window.alert("User dismissed dialog or picked a file deemed too sensitive or dangerous.");
    } catch (error) {
      print(error);
    }
  }

  Future<String> loadImageAsBase64(File file) async {
    final reader = FileReader();
    final extension = file.name.substring(file.name.lastIndexOf(".") + 1);

    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    Uint8List buffer = reader.result as Uint8List;
    return "data:image/$extension;base64,${base64Encode(buffer)}";
  }

  void showImage(String image) {
    $img.src = image;
    $img.style.display = "block";
  }
}
