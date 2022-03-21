class RTUtils {
  /// Email Regex - A predefined type for handling email matching
  static const emailPattern = r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b';

  /// URL Regex - A predefined type for handling URL matching
  static const urlPattern =
      r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)';

  /// Phone Regex - A predefined type for handling phone matching
  static const phonePattern =
      r'(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})';

  static const String starPattern = r'\*.*?\*';
  static const boldPattern = r'\*.*?\*';
  static const hashPattern = r'\B#+([^\x00-\x7F]|\w)+';
  static const mentionPattern = r'\B@+([\w]+)\b';
}
