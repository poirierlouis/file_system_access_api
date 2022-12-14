# File System Access API

[![Pub Version](https://img.shields.io/pub/v/file_system_access_api)](https://pub.dev/packages/file_system_access_api)
![Platform Web](https://img.shields.io/badge/platform-web-blue)
[![License MIT](https://img.shields.io/github/license/poirierlouis/file_system_access_api)](https://github.com/poirierlouis/file_system_access_api/blob/master/LICENSE)
[![Donate](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-yellow)](https://www.buymeacoffee.com/lpfreelance)

A Dart library to expose the File System Access API from web platform.
You can pick files and directories from user's local file system to read, write, create, move and delete files from Dart
web apps.

> The web API (and this library) is experimental and is only supported on [Chrome, Edge and Opera browsers] for now.
> It is not recommended to use this library in a production environment.

## Features

This library reflects the web File System Access API using Dart types.
See a more detailed description on [MDN Web Docs] or keep reading to [Usage](#usage) section below.

## Getting started

Install library in your Dart project:
```shell
$ dart pub add file_system_access_api
```

You're all set to play around with the API.
> Note that in a cross-platform Flutter project, you can use this library only in a Web environment.
> Use `kIsWeb` to prevent building/runtime errors and optimize build size.

## Usage

You can reproduce example from the web API as much of the interfaces are transparent between this Dart library and the 
JavaScript API.

> Note that you must execute code samples within `main()` as a result of a user gesture (e.g. click event) for security 
> reason. This part is omitted for brevity.

### Open file(s)
You can ask a user to open file(s) with the method `window.showOpenFilePicker()` and access selected files like this:
```dart
import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

void main() async {
  try {
    List<FileSystemFileHandle> handles = await window.showOpenFilePicker(
        multiple: true, 
        excludeAcceptAllOption: true,
        types: [FilePickerAcceptType(description: "Pictures", accept: {"image/png+jpg": [".png", ".jpg"]})],
        startIn: WellKnownDirectory.pictures
    );
    
    for (final handle in handles) {
      File file = await handle.getFile();
      
      print("<file name='${handle.name}' size='${file.size} bytes' />");
      
      // You can read content of a File using a FileReader, like any other File coming from 'dart:html'
    }
  } on AbortError {
    print("User dismissed dialog or picked a file deemed too sensitive or dangerous.");
  }
}
```

### Save a file
You can ask a user where to save a file with the method `window.showSaveFilePicker()` and write in the selected file 
like this:
```dart
import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

void main() async {
  try {
    FileSystemFileHandle handle = await window.showSaveFilePicker(
        suggestedName: "awesome.dart",
        excludeAcceptAllOption: true,
        types: [FilePickerAcceptType(description: "Dart files", accept: {"application/dart": [".dart"]})],
        startIn: WellKnownDirectory.documents
    );

    FileSystemWritableFileStream stream = await handle.createWritable();
    
    await stream.writeAsText(
        "void main() {"
        "  print('This is the way.');"
        "}"
    );
    await stream.close();
    // Note that data will be written on disk only after call to close() completed.
  } on AbortError {
    print("User dismissed dialog or picked a file deemed too sensitive or dangerous.");
  } on NotAllowedError {
    print("User did not granted permission to readwrite in this file.");
  }
}
```

### Open a directory
You can ask a user to pick a directory `window.showDirectoryPicker()` and recursively access files and directories like 
this:
```dart
import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

void main() async {
  try {
    FileSystemDirectoryHandle directory = await window.showDirectoryPicker(
        // Use readwrite to ask permission and grant write access on files instead.
        mode: PermissionMode.read
    );
    
    // List of handles in a directory emitted with a [Stream].
    // Listen periodically on [Stream] to reproduce a file system watch-like feature.
    await for (FileSystemHandle handle in directory.values) {
      if (handle is FileSystemFileHandle) {
        print("<file name='${handle.name}' />");
      } else if (handle is FileSystemDirectoryHandle) {
        print("<directory name='${handle.name}/' />");
        // You can create, move and delete files/directories. See example/ for more on this.
      }
    }
  } on AbortError {
    print("User dismissed dialog or picked a directory deemed too sensitive or dangerous.");
  }
}
```

### Permissions
You can query / request permission on files and directories from the user. It allows you to write in files, modify a 
directory structure, etc. Those methods are available per file/directory handle:
```dart
import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

void main() async {
  try {
    final handles = await window.showOpenFilePicker(multiple: false);
    final handle = handles.single;
    
    var permission = await handle.queryPermission(mode: PermissionMode.readwrite);
    
    if (permission != PermissionState.granted) {
      print("Asking permission to read and write");
      permission = await handle.requestPermission(mode: PermissionMode.readwrite);
      if (permission != PermissionState.granted) {
        print("read/write access refused, either prompt was dismissed or denied.");
        return;
      }
      print("read/write access granted. 😀");
    }
    print("Write beautiful bytes. ✨");
  } on AbortError {
    print("User dismissed dialog or picked a file deemed too sensitive or dangerous.");
  }
}
```

> Note that current implementation of the File System Access API does not remember permissions across browser's sessions
> when used with IndexedDB.
> Star [crbug.com/1011533](https://crbug.com/1011533) to be notified of work on persisting granted permissions.

### Drag and Drop
You can get files/directories from a drag-n-drop event:
```dart
import 'dart:html';

import 'package:file_system_access_api/file_system_access_api.dart';

void main() {
  final $area = document.querySelector("#area") as DivElement;
  
  $area.addEventListener("dragover", (event) => event.preventDefault());
  $area.addEventListener("drop", (event) async {
    event.preventDefault();
    
    final handles = await FileSystemAccess.fromDropEvent(event);
    
    for (final handle in handles) {
      print("<${handle.kind.name} name='${handle.name}' />");
    }
  });
}
```

### More

See examples in `example/` folder to play with fun tools.

## Origin Private File System

This is a storage endpoint private to the origin of the page. It contains files/directories within a "virtual disk" 
chosen by the browser implementing this API. Files and directories may be written in a database or any other data 
structure. You should not expect to find those files/directories as-this on the hard disk.

### Get root directory
You can get a root directory of the origin private file system with:
```dart
void main() async {
  FileSystemDirectoryHandle? root = await window.navigator.storage?.getDirectory();
}
```

### Rename a file
> Applies only within Origin Private File System for now.

You can rename a file with:
```dart
void main() async {
  FileSystemDirectoryHandle root;

  FileSystemFileHandle handle = await root.getFileHandle("some-name.txt");

  await handle.rename("new-name.txt");
}
```

### Move a file
> Applies only within Origin Private File System for now.

You can move a file inside another directory and optionally rename it in the same call with:
```dart
void main() async {
  FileSystemDirectoryHandle root;
  
  FileSystemFileHandle handle = await root.getFileHandle("some-name.txt");
  FileSystemDirectoryHandle destination = await root.getDirectoryHandle("config", create: true);

  // Move only
  await handle.move(destination);
  // Move and rename
  await handle.move(destination, name: "new-name.txt");
}
```

## [Synchronous access in Web Workers]
> Applies only within a Web Worker and Origin Private File System for now.

You can get an interface to synchronously read from and write to a file. This will create an exclusive lock on the file 
associated with the file handle, until it is closed:
```dart
// Code executed within a Web Worker
void main() async {
  FileSystemDirectoryHandle root;
  
  FileSystemFileHandle source = await root.getFileHandle("linux.iso");
  FileSystemSyncAccessHandle src = await source.createSyncAccessHandle();
  Uint8List buffer = Uint8List(src.getSize());
  
  src.read(buffer);
  src.close();
  print(buffer);
}
```

## Missing features

### [Origin Private File System]
There is no wrapper around this JavaScript feature for now:
> - FileSystemHandle.remove()

## Known issues

- You cannot store a FileSystemHandle into IndexedDB as-this. See [issue #50621] for more. A workaround is implemented 
in `LightStorage` within `example/` folder.

File any potential [issues] you see.

## Additional information
See this [article on web.dev] for an introduction to this API (JavaScript).

See examples and more on [MDN Web Docs] (JavaScript).

See specification on [W3C WICG’s File System Access] and [WHATWG's File System].

Feel free to contribute with [issues] or [pull-requests].

## Intellectual property rights
This library includes documentation copied and/or modified from [W3C WICG’s File System Access], which is available 
under the [W3C Software and Document License]. 

This library includes documentation copied and/or modified from [MDN Web Doc’s File System Access], by 
[Mozilla Contributors] which is available under the [CC-BY-SA 2.5].

This library is available under [MIT license].

<!-- Table of Links -->
[Chrome, Edge and Opera browsers]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API#browser_compatibility
[Synchronous access in Web Workers]: https://developer.mozilla.org/docs/Web/API/FileSystemFileHandle/createSyncAccessHandle
[Origin Private File System]: https://fs.spec.whatwg.org/#origin-private-file-system
[issue #50621]: https://github.com/dart-lang/sdk/issues/50621

[issues]: https://github.com/poirierlouis/file_system_access_api/issues
[pull-requests]: https://github.com/poirierlouis/file_system_access_api/pulls

[MDN Web Docs]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API
[MDN Web Doc’s File System Access]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API
[W3C WICG’s File System Access]: https://wicg.github.io/file-system-access/
[article on web.dev]: https://web.dev/file-system-access/
[WHATWG's File System]: https://fs.spec.whatwg.org/

[W3C Software and Document License]: https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
[Mozilla Contributors]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API/contributors.txt
[CC-BY-SA 2.5]: https://creativecommons.org/licenses/by-sa/2.5/
[MIT license]: https://github.com/poirierlouis/file_system_access_api/blob/master/LICENSE
