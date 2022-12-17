import 'dart:html';
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';

import '../index.dart';
import '../light_storage.dart';
import 'abstract_tab.dart';

typedef _WorkerListener = void Function(dynamic);

class CompressionTab extends Tab {
  CompressionTab(final LightStorage storage) : super(storage: storage, name: "compression");

  late final Map<String, _WorkerListener> _workerActions = {
    "started": _onWorkerStarted,
    "ready": _onWorkerReady,
    "progress": _onWorkerProgress,
    "finished": _onWorkerFinished,
    "abort": _onWorkerAbort,
  };

  late final ButtonElement $btnOpen = $view.querySelector("#btn-open") as ButtonElement;
  late final ButtonElement $btnEncode = $view.querySelector("#btn-encode") as ButtonElement;
  late final ButtonElement $btnDecode = $view.querySelector("#btn-decode") as ButtonElement;

  late final DivElement $source = $view.querySelector("#source") as DivElement;
  late final DivElement $progress = $view.querySelector("#progress") as DivElement;

  FileSystemDirectoryHandle? _root;
  FileSystemFileHandle? _src;
  FileSystemFileHandle? _dst;
  Worker? _worker;
  bool _isEncoding = true;

  @override
  Future<void> init() async {
    _root = await window.navigator.storage?.getDirectory();

    if (!Worker.supported || _root == null) {
      $btnOpen.disabled = true;
      $btnEncode.disabled = true;
      $btnDecode.disabled = true;
      return;
    }
    $btnOpen.onClick.listen(onOpenFile);
    $btnEncode.onClick.listen(onEncodeTo);
    $btnDecode.onClick.listen(onDecodeTo);
  }

  @override
  Future<void> load() async {}

  void onOpenFile(event) async {
    if (_worker != null) {
      return;
    }
    try {
      final handles = await window.showOpenFilePicker(multiple: false);

      await selectFile(handles.single);
    } catch (error) {
      window.alert("Select a file to open.");
    }
  }

  Future<void> selectFile(FileSystemFileHandle handle) async {
    if (_worker != null) {
      return;
    }
    _src = handle;

    final file = await _src!.getFile();

    _updateFileDOM(file, $source);
    $btnEncode.disabled = false;
  }

  void onEncodeTo(event) async {
    if (_src == null || _worker != null) {
      return;
    }
    try {
      _dst = await window.showSaveFilePicker(suggestedName: "xor_${_src!.name}");
      $progress.show();
      $btnOpen.disabled = true;
      $btnEncode.disabled = true;
      $btnDecode.disabled = true;
      _isEncoding = true;
      final hasTransferred = await transferOPFS(_src!, send: true);

      if (!hasTransferred) {
        _updateStatusDOM("Failed to send file to OPFS!");
        return;
      }
      runWorker();
    } catch (error) {
      window.alert("Select a file to encode to.");
    }
  }

  void onDecodeTo(event) async {
    if (_src == null || _dst == null || _worker != null) {
      return;
    }
    try {
      final originalName = _src!.name;

      _src = _dst;
      _dst = await window.showSaveFilePicker(suggestedName: "copy_$originalName");

      var file = await _src!.getFile();

      _updateFileDOM(file, $source);
      file = await _dst!.getFile();
      $progress.show();
      _isEncoding = false;
      final hasTransferred = await transferOPFS(_src!, send: true);

      if (!hasTransferred) {
        _updateStatusDOM("Failed to send file to OPFS!");
        return;
      }
      runWorker();
    } catch (error) {
      window.alert("Select a file to decode to.");
    }
  }

  void runWorker() {
    _worker = Worker("compression_web_worker.dart.js");
    _worker!.onError.listen(onWorkerError);
    _worker!.onMessage.listen(onWorkerMessage);
  }

  /// Transfer file from / to Origin Private File System to use Synchronous Access in Web Worker.
  /// [send] true to send [src] file, false to read remote file in [src].
  Future<bool> transferOPFS(FileSystemFileHandle src, {required bool send}) async {
    try {
      final remote = await _root!.getFileHandle(src.name, create: send);
      String status;

      if (send) {
        status = "Copying data to OPFS...";
      } else {
        status = "Copying data from OPFS...";
      }
      _updateStatusDOM(status);

      final trx = (send) ? src : remote;
      final twx = (send) ? remote : src;
      final file = await trx.getFile();
      final stream = await twx.createWritable();
      final reader = FileReader();

      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      await stream.writeAsArrayBuffer(reader.result as Uint8List);
      await stream.close();
      return true;
    } on NotFoundError {
      return false;
    }
  }

  /// Remove [src] and [dst] files from Origin Private File System.
  Future<void> cleanOPFS() async {
    try {
      _updateStatusDOM("Cleaning temporary content from OPFS...");
      await _root!.removeEntry(_src!.name);
      await _root!.removeEntry(_dst!.name);
    } catch (_) {}
  }

  void onWorkerError(Event event) {
    _src = null;
    _dst = null;
    $btnOpen.disabled = false;
    $btnEncode.disabled = true;
    $btnDecode.disabled = true;
    _updateStatusDOM("Unexpected error from Web Worker, aborting compression.");
    _isEncoding = true;
    _stopWorker();
  }

  void onWorkerMessage(dynamic message) {
    final action = (message as MessageEvent).data["action"];

    if (!_workerActions.containsKey(action)) {
      return;
    }
    final fn = _workerActions[action]!;

    fn(message.data);
  }

  void _onWorkerStarted(dynamic data) {
    _worker!.postMessage({
      "action": "start",
      "direction": (_isEncoding) ? "encode" : "decode",
      "src": _src!.name,
      "dst": _dst!.name,
    });
  }

  void _onWorkerReady(dynamic data) {
    _updateStatusDOM((_isEncoding) ? "Encoding data:" : "Decoding data:");
  }

  void _onWorkerProgress(dynamic data) {
    final $done = $progress.querySelector("#done") as DivElement;
    final $label = $progress.querySelector("#percentage") as LabelElement;
    var percentage = int.tryParse(data["percentage"]) ?? 0;

    if (percentage > 100) {
      percentage = 100;
    } else if (percentage < 0) {
      percentage = 0;
    }
    $done.style.width = "$percentage%";
    $label.innerText = "$percentage %";
  }

  void _onWorkerFinished(dynamic data) async {
    await transferOPFS(_dst!, send: false);
    await cleanOPFS();
    _stopWorker();
    if (_isEncoding) {
      _updateStatusDOM("Encoding complete.");
      $btnDecode.disabled = false;
    } else {
      _updateStatusDOM("Decoding complete.");
      $btnOpen.disabled = false;
      $btnEncode.disabled = true;
      $btnDecode.disabled = true;
    }
    $progress.hide();
  }

  void _onWorkerAbort(dynamic data) async {
    print("[main] abort: ${data["error"]}");
    await cleanOPFS();
    _stopWorker();
  }

  void _stopWorker() {
    _worker!.terminate();
    _worker = null;
  }

  void _updateStatusDOM(String status) {
    final $status = $progress.querySelector("label#status") as LabelElement;

    $status.innerText = status;
  }

  void _updateFileDOM(File file, DivElement $root) {
    final $name = $root.querySelector("#file-name") as SpanElement;
    final $type = $root.querySelector("#file-type") as SpanElement;
    final $size = $root.querySelector("#file-size") as SpanElement;

    $name.innerText = file.name;
    $type.innerText = file.type;
    $size.innerText = file.size.toString();
    $root.show();
  }
}
