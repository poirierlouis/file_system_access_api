/// Thrown if a user dismisses the prompt without making a selection or if a file selected is deemed too sensitive or
/// dangerous to be exposed to the website.
class AbortError {}

/// Thrown if you try to access a file while [PermissionState] is not [granted] by user.
class NotAllowedError {}

/// Thrown if the name specified is not a valid string or contains characters not allowed on the file system.
class MalformedNameError {}

/// Thrown if the named entry is a directory and not a file when using [FileSystemDirectoryHandle.getFileHandle].
/// Throw if the named entry is a file and not a directory when using [FileSystemDirectoryHandle.getDirectoryHandle].
class TypeMismatchError {}

/// Thrown if [recursive] is set to [false] and the entry to be removed has children.
class InvalidModificationError {}

/// Thrown if file doesn't exist and the create option is set to [false].
class NotFoundError {}
