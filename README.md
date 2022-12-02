A Dart library to expose the File System Access API from web platform.
You can pick files and directories from user's local file system to read, write, create, move and delete files from Dart
web apps.

> The web API (and this library) is experimental and is only supported on [Chrome, Edge and Opera browsers] for now.
> It is not recommended to use this library in a production environment.

## Features

TBD.

## Getting started

TBD.

## Usage

TBD.

See examples in `example/` folder.

## Missing features

### [Drag and Drop]
There is no wrapper around this JavaScript feature for now.

### [Synchronous access in Web Workers]
There is no wrapper around this JavaScript feature for now.

## Known issues

You cannot store a FileSystemHandle into IndexedDB for now.

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
[Mozilla Contributors] which is available under the [CC-BY-SA 2.5](https://creativecommons.org/licenses/by-sa/2.5/).

This library is available under MIT license.

<!-- Table of Links -->
[Chrome, Edge and Opera browsers]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API#browser_compatibility
[Drag and Drop]: https://developer.mozilla.org/docs/Web/API/DataTransferItem/getAsFileSystemHandle
[Synchronous access in Web Workers]: https://fs.spec.whatwg.org/#api-filesystemfilehandle-createsyncaccesshandle

[issues]: https://github.com/poirierlouis/file_system_access_api/issues
[pull-requests]: https://github.com/poirierlouis/file_system_access_api/pulls

[MDN Web Docs]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API
[MDN Web Doc’s File System Access]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API
[W3C WICG’s File System Access]: https://wicg.github.io/file-system-access/
[article on web.dev]: https://web.dev/file-system-access/
[WHATWG's File System]: https://fs.spec.whatwg.org/

[W3C Software and Document License]: https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
[Mozilla Contributors]: https://developer.mozilla.org/docs/Web/API/File_System_Access_API/contributors.txt
