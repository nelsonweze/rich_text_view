class RTUtils {
  /// Email Regex - A predefined type for handling email matching
  static const emailPattern = 
    r'''(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])''';

  /// URL Regex - A predefined type for handling URL matching
  static const urlPattern =
      r'''[(http(s)?):\/\/(www\.)?a-zA-Z0-9!@:%.\-_\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9!@:%\-_\+.~#?&//=]*)''';

  /// Phone Regex - A predefined type for handling phone matching
  static const phonePattern =
      r'(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})';

  static const boldPattern = r'\*.*?\*';
  static const italicPattern = r'\_.*?\_';
  static const hashPattern = r'\B#+([^\x00-\x7F]|\w)+';
  static const mentionPattern = r'\B@+([\w]+)\b';
}
