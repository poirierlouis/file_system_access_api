import 'dart:async';
import 'dart:html';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:js/js.dart';

@JS()
external dynamic get navigator;

@JS()
external void postMessage(msg);

@JS("onmessage")
external set onmessage(fn);

typedef WorkerListener = void Function(dynamic);

final Map<String, WorkerListener> actions = {
  "start": allowInterop(onStartAction),
};

late final FileSystemDirectoryHandle root;

void main() async {
  final storage = getProperty(navigator, "storage") as StorageManager?;
  final directory = await storage?.getDirectory();

  if (directory == null) {
    sendAbort();
    return;
  }
  root = directory;
  onmessage = allowInterop(onActionMessage);
  sendStarted();
}

void onActionMessage(dynamic event) {
  final data = getProperty(event, "data");
  final action = getProperty(data, "action");

  try {
    if (!actions.containsKey(action)) {
      return;
    }
    final fn = actions[action]!;

    fn(event.data);
  } catch (error) {
    print("[worker] error: $error");
  }
}

void onStartAction(dynamic data) async {
  final isEncoding = data["direction"] == "encode";
  final srcFileName = data["src"] as String;
  final dstFileName = data["dst"] as String;

  try {
    final src = await root.getFileHandle(srcFileName);
    final dst = await root.getFileHandle(dstFileName, create: true);

    sendReady();

    final syncSrc = await src.createSyncAccessHandle();
    final syncDst = await dst.createSyncAccessHandle();

    await run(syncSrc, syncDst, isEncoding);

    sendFinished();
  } catch (error) {
    sendAbort(error);
  }
}

int dummyConverter(int byte) {
  return byte ^ 0x42;
}

Future<void> run(FileSystemSyncAccessHandle src, FileSystemSyncAccessHandle dst, bool isEncoding) async {
  try {
    int size = src.getSize();
    Uint8List buffer = Uint8List(size);

    src.read(buffer);

    int prev = -1;
    int progress;

    for (int i = 0; i < size; i++) {
      buffer[i] = dummyConverter(buffer[i]);
      progress = (i * 100 / size).round();
      if (prev != progress) {
        sendProgress(progress);
        prev = progress;
      }
    }

    dst.write(buffer);
    dst.flush();

    sendProgress(100);
  } catch (error) {
    print(error);
  } finally {
    src.close();
    dst.close();
  }
}

void sendFinished() {
  postMessage(jsify({"action": "finished"}));
}

void sendProgress(int percentage) {
  postMessage(jsify({
    "action": "progress",
    "percentage": percentage,
  }));
}

void sendReady() {
  postMessage(jsify({"action": "ready"}));
}

void sendStarted() {
  postMessage(jsify({"action": "started"}));
}

void sendAbort([Object? error]) {
  postMessage(jsify({
    "action": "abort",
    "error": error,
  }));
}
