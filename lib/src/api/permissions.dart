/// Defines mode to interact with a file using read-only access or read and write access.
enum PermissionMode {
  read,
  readwrite,
}

/// A permission represents a user's decision to allow a web application to use a powerful feature. Conceptually, a
/// permission for a powerful feature can be in one of the following states: [granted], [denied] or [prompt].
///
/// Example and more on [MDN Web Docs](https://developer.mozilla.org/docs/Web/API/PermissionStatus/state)
enum PermissionState {
  /// The user, or the user agent on the user's behalf, has given express permission to use a powerful feature.
  /// The caller will can use the feature possibly without having the user agent asking the user's permission.
  granted,

  /// The user, or the user agent on the user's behalf, has denied access to this powerful feature. The caller will
  /// can't use the feature.
  denied,

  /// The user has not given express permission to use the feature (i.e., it's the same as denied). It also means that
  /// if a caller attempts to use the feature, the user agent will either be prompting the user for permission or access
  /// to the feature will be denied.
  prompt,
}
