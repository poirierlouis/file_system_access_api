/// Lets a website pick one of several well-known directories when used with file picker / directory picker.
///
/// See each value which describes its meaning, and gives possible example paths on different operating systems.
enum WellKnownDirectory {
  /// The user’s Desktop directory, if such a thing exists. For example this could be:
  /// - C:\Documents and Settings\username\Desktop
  /// - /Users/username/Desktop
  /// - /home/username/Desktop
  desktop,

  /// Directory in which documents created by the user would typically be stored. For example:
  /// - C:\Documents and Settings\username\My Documents
  /// - /Users/username/Documents
  /// - /home/username/Documents
  documents,

  /// Directory where downloaded files would typically be stored. For example:
  /// - C:\Documents and Settings\username\Downloads
  /// - /Users/username/Downloads
  /// - /home/username/Downloads
  downloads,

  /// Directory where audio files would typically be stored. For example:
  /// - C:\Documents and Settings\username\My Documents\My Music
  /// - /Users/username/Music
  /// - /home/username/Music
  music,

  /// Directory where photos and other still images would typically be stored. For example:
  /// - C:\Documents and Settings\username\My Documents\My Pictures
  /// - /Users/username/Pictures
  /// - /home/username/Pictures
  pictures,

  /// Directory where videos/movies would typically be stored. For example:
  /// - C:\Documents and Settings\username\My Documents\My Videos
  /// - /Users/username/Movies
  /// - /home/username/Videos
  videos,
}
