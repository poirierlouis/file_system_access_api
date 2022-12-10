import 'dart:async';
import 'dart:html';

class ViewDialogForm {
  static DialogElement get $dialog => document.querySelector("dialog#form") as DialogElement;
  static LabelElement get $label => $dialog.querySelector("label") as LabelElement;
  static InputElement get $input => $dialog.querySelector("input") as InputElement;
  static ButtonElement get $submit => $dialog.querySelector("#submit") as ButtonElement;

  static Completer<String> _completer = Completer();

  static void init() {
    $input.onInput.listen((event) {
      $submit.value = $input.value ?? "";
      $submit.disabled = $submit.value.isEmpty;
    });
    $dialog.addEventListener("close", _onDialogClosed);
  }

  static Future<String?> show({required String label, required String placeholder, required String btnLabel}) {
    $label.innerText = label;
    $input.placeholder = placeholder;
    $submit.innerText = btnLabel;

    _completer = Completer();
    $dialog.showModal();
    return _completer.future;
  }

  static void _onDialogClosed(event) {
    String? value = $input.value;

    $input.value = "";
    $submit.value = "";
    $submit.disabled = true;
    _completer.complete(value);
  }
}
