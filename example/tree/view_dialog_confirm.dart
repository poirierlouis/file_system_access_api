import 'dart:async';
import 'dart:html';

class ViewDialogConfirm {
  static DialogElement get $dialog => document.querySelector("dialog#confirm") as DialogElement;
  static ParagraphElement get $description => $dialog.querySelector("p") as ParagraphElement;
  static ButtonElement get $submit => $dialog.querySelector("#submit") as ButtonElement;

  static Completer<String> _completer = Completer();

  static void init() {
    $dialog.addEventListener("close", _onDialogClosed);
  }

  static Future<String?> show({required String description}) {
    $description.innerText = description;

    _completer = Completer();
    $dialog.showModal();
    return _completer.future;
  }

  static void _onDialogClosed(event) {
    _completer.complete($dialog.returnValue);
  }
}
