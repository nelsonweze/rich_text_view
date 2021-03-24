
enum SuggestionPosition { top, bottom, none }

class HashTag {
  String? hashtag;
  int? counts;
  bool trending;
  int? last24;
  HashTag({this.hashtag, this.counts, this.trending = false, this.last24});

  HashTag.fromMap(Map map)
      : hashtag = map['hashtag'],
        counts = map['count'],
        trending = map["trending"] ?? false;
}

class Suggestion {
  final String title;
  final String subtitle;
  final String imageURL;
  final Function() onClick;
  final Map<String, dynamic>? parameters;
  Suggestion(
      {required this.imageURL,
      required this.onClick,
      required this.subtitle,
      required this.title,
      this.parameters});

  Suggestion.fromMap(Map<String, dynamic> map, final Function() onClick,
      {Map<String, dynamic>? params})
      : title = map["title"],
        subtitle = map["subtitle"],
        imageURL = map["imageURL"],
        onClick = onClick,
        parameters = params;
}


enum ParsedType { EMAIL, PHONE, URL, HASH, MENTION, BOLD, CUSTOM }

class RegexOptions {
  /// Creates a RegexOptions object
  /// If `multiLine` is enabled, then `^` and `$` will match the beginning and
  ///  end of a _line_, in addition to matching beginning and end of input,
  ///  respectively.
  ///
  ///  If `caseSensitive` is disabled, then case is ignored.
  ///
  ///  If `unicode` is enabled, then the pattern is treated as a Unicode
  ///  pattern as described by the ECMAScript standard.
  ///
  ///  If `dotAll` is enabled, then the `.` pattern will match _all_ characters,
  ///  including line terminators.
  const RegexOptions({
    this.multiLine = false,
    this.caseSensitive = true,
    this.unicode = false,
    this.dotAll = false,
  });

  final bool multiLine;
  final bool unicode;
  final bool caseSensitive;
  final bool dotAll;
}

/// A MatchText class which provides a structure for [ParsedText] to handle
/// Pattern matching and also to provide custom [Function] and custom [TextStyle].
class MatchText {
  /// Used to enforce Predefined regex to match from
  ParsedType type;

  /// If no [type] property is explicitly defined then this propery must be
  /// non null takes a [regex] string
  String? pattern;

  /// Takes a custom style of [TextStyle] for the matched text widget
  var style;

  /// A custom [Function] to handle onTap.
  void Function(String)? onTap;

  /// A callback function that takes two parameter String & pattern
  ///
  /// @param str - is the word that is being matched
  /// @param pattern - pattern passed to the MatchText class
  ///
  /// eg: Your str is 'Mention [@michel:5455345]' where 5455345 is ID of this user
  /// and @michel the value to display on interface.
  /// Your pattern for ID & username extraction : `/\[(@[^:]+):([^\]]+)\]/`i
  /// Displayed text will be : Mention `@michel`
  Function({String? str, String? pattern})? renderText;

  final RegexOptions regexOptions;

  /// Creates a MatchText object
  MatchText({
    this.type = ParsedType.CUSTOM,
    this.pattern,
    this.style,
    this.onTap,
    this.renderText,
    this.regexOptions = const RegexOptions(),
  });
}
