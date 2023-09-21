import 'package:flutter/material.dart';
import 'util.dart';

enum SuggestionPosition { top, bottom, none }

class HashTag {
  String hashtag;
  String? subtitle;
  bool trending;
  int? last24;
  HashTag(
      {required this.hashtag,
      this.subtitle,
      this.trending = false,
      this.last24});

  HashTag.fromMap(Map map)
      : hashtag = map['hashtag'],
        subtitle = map['subtitle'],
        trending = map['trending'] ?? false;
}

class Mention {
  final String? id;
  final String title;
  final String subtitle;
  final String imageURL;
  final Map<String, dynamic>? parameters;
  Mention(
      {required this.imageURL,
      required this.subtitle,
      required this.title,
      this.id,
      this.parameters});

  Mention.fromMap(Map<String, dynamic> map, {Map<String, dynamic>? params})
      : title = map['title'],
        subtitle = map['subtitle'],
        imageURL = map['imageURL'],
        id = map['id'],
        parameters = params;
}

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

class Matched {
  String? display;
  String? value;
  int? start;
  int? end;
  Matched({required this.display, this.value, this.start, this.end});

  @override
  String toString() =>
      'display: $display value: $value start: $start end: $end';
}



abstract class ParserType {
  /// If no [type] property is explicitly defined then this propery must be
  /// non null takes a [regex] string
  String? pattern;

  /// Takes a custom style of [TextStyle] for the matched text widget
  TextStyle? style;

  /// A custom [Function] to handle onTap.
  void Function(Matched)? onTap;

  /// This lets you customise how you want the
  /// matched text to be displayed
  Matched Function({String? str})? renderText;

  /// Creates a ParserType object
  ParserType({
    this.pattern,
    this.style,
    this.onTap,
    this.renderText,
  });
}

class MentionParser extends ParserType {
  MentionParser(
      {String? pattern = RTUtils.mentionPattern,
      Function(Matched)? onTap,
      TextStyle? style,
      bool enableID = false})
      : super(
          pattern: pattern,
          onTap: onTap,
        );
}

class HashTagParser extends ParserType {
  HashTagParser({
    String? pattern = RTUtils.hashPattern,
    Function(Matched)? onTap,
    TextStyle? style,
  }) : super(pattern: pattern, style: style, onTap: onTap);
}

class PhoneParser extends ParserType {
  PhoneParser({
    String? pattern = RTUtils.phonePattern,
    Function(Matched)? onTap,
    TextStyle? style,
  }) : super(pattern: pattern, style: style, onTap: onTap);
}

class EmailParser extends ParserType {
  EmailParser({
    String? pattern = RTUtils.emailPattern,
    Function(Matched)? onTap,
    TextStyle? style,
  }) : super(pattern: pattern, style: style, onTap: onTap);
}

class UrlParser extends ParserType {
  UrlParser({
    String? pattern = RTUtils.urlPattern,
    Function(Matched)? onTap,
    TextStyle? style,
  }) : super(pattern: pattern, style: style, onTap: onTap);
}

class BoldParser extends ParserType {
  BoldParser(
      {Function(Matched)? onTap,
      TextStyle? style,
      String pattern = RTUtils.boldPattern})
      : super(style: style, onTap: onTap, pattern: pattern) {
    renderText = ({String? str}) {
      return Matched(
          display: str?.substring(1, str.length - 1),
          value: str?.substring(1, str.length - 1));
    };
  }
}

class ItalicParser extends ParserType {
  ItalicParser(
      {Function(Matched)? onTap,
      TextStyle? style,
      String pattern = RTUtils.italicPattern})
      : super(style: style, onTap: onTap, pattern: pattern) {
    renderText = ({String? str}) {
      return Matched(
          display: str?.substring(1, str.length - 1),
          value: str?.substring(1, str.length - 1));
    };
  }
}
