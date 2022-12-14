# Demo
Examples of using File System Access API with Dart.

It shows how to:
- pick a file with only image types and draw image in a `<img />` tag.
- a minimal text editor to create, open and save text files.
- a tree viewer to dynamically list content of a directory and open image/text files in above tools.
- a "tree viewer" in Origin Private File System with features to create, move, rename and delete files and directories.
- a dummy encoder/decoder which takes a file from user's file system, send it into OPFS, executes encoder in a Web 
Worker (using Synchronous Access) and write back the file to user's file system.

# Usage
To view the examples, run the following command from the root directory of this project – the directory containing 
`pubspec.yaml`:
```shell
$ dart run webdev serve example:4242 --release
```

Remove `:4242` to start server on default port 8080 or use any other port you wish.

Use option `--release` to try `Web Worker` tab. In debug mode, trying to run with a Web Worker will fail.

You can view it with any compatible browsers (Chrome, Edge and Opera).
