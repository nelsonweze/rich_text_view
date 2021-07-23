import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_view/rich_text_view.dart';

/// Email Regex - A predefined type for handling email matching
const emailPattern = r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b';

/// URL Regex - A predefined type for handling URL matching
const urlPattern =
    r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)';

/// Phone Regex - A predefined type for handling phone matching
const phonePattern =
    r'(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})';

const String starPattern = r'\*.*?\*';
const boldPattern = r'\$.*?\$';
const hashPattern = r'\B#+([^\x00-\x7F]|\w)+';
const mentionPattern = r'\B@+([\w]+)\b';

class ParsedText extends StatelessWidget {
  /// Takes a list of [MatchText] object.
  ///
  /// This list is used to find patterns in the String and assign onTap [Function] when its
  /// tapped and also to provide custom styling to the linkify text
  final List<MatchText> parse;
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final TextAlign alignment;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int? maxLines;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final bool selectable;
  final GestureTapCallback? onTap;
  final Function()? onMore;
  final ValueNotifier<bool> expanded;
  final String moreText;
  final List<ParsedType> supportedTypes;
  final RegexOptions regexOptions;

  ParsedText({
    Key? key,
    required this.text,
    this.parse = const <MatchText>[],
    required this.supportedTypes,
    this.style,
    this.regexOptions = const RegexOptions(),
    this.linkStyle,
    this.alignment = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.maxLines,
    this.onTap,
    this.onMore,
    required this.expanded,
    this.moreText = 'more',
    this.selectable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var link = expanded.value
        ? TextSpan()
        : TextSpan(
            children: [
              TextSpan(
                text: '\u2026 ',
              ),
              TextSpan(
                  text: moreText,
                  recognizer: TapGestureRecognizer()..onTap = onMore),
            ],
            style: linkStyle,
          );

    List<InlineSpan> parseText(String txt) {
      var newString = txt;

      var _mapping = <String, MatchText>{};

      parse.forEach((e) {
        if (e.type == ParsedType.EMAIL &&
            supportedTypes.contains(ParsedType.EMAIL)) {
          _mapping[emailPattern] = e;
        } else if (e.type == ParsedType.PHONE &&
            supportedTypes.contains(ParsedType.PHONE)) {
          _mapping[phonePattern] = e;
        } else if (e.type == ParsedType.URL &&
            supportedTypes.contains(ParsedType.URL)) {
          _mapping[urlPattern] = e;
        } else if (e.type == ParsedType.BOLD &&
            supportedTypes.contains(ParsedType.BOLD)) {
          _mapping[boldPattern] = e;
        } else if (e.type == ParsedType.MENTION &&
            supportedTypes.contains(ParsedType.MENTION)) {
          _mapping[mentionPattern] = e;
        } else if (e.type == ParsedType.HASH &&
            supportedTypes.contains(ParsedType.HASH)) {
          _mapping[hashPattern] = e;
        }
      });

      final pattern = '(${_mapping.keys.toList().join('|')})';

      var widgets = <InlineSpan>[];

      newString.splitMapJoin(
        RegExp(
          pattern,
          multiLine: regexOptions.multiLine,
          caseSensitive: regexOptions.caseSensitive,
          dotAll: regexOptions.dotAll,
          unicode: regexOptions.unicode,
        ),
        onMatch: (Match match) {
          final matchText = match[0];

          final mapping = _mapping[matchText!] ??
              _mapping[_mapping.keys.firstWhere((element) {
                final reg = RegExp(
                  element,
                  multiLine: regexOptions.multiLine,
                  caseSensitive: regexOptions.caseSensitive,
                  dotAll: regexOptions.dotAll,
                  unicode: regexOptions.unicode,
                );
                return reg.hasMatch(matchText);
              }, orElse: () {
                return '';
              })];

          InlineSpan widget;

          if (mapping != null) {
            if (mapping.renderText != null) {
              Map<String, String> result =
                  mapping.renderText!(str: matchText, pattern: pattern);

              widget = TextSpan(
                text: "${result['display']}",
                style: mapping.style ?? linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => mapping.onTap!(matchText),
              );
            } else {
              widget = TextSpan(
                text: '$matchText',
                style: mapping.style ?? linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => mapping.onTap!(matchText),
              );
            }
          } else {
            widget = TextSpan(
              text: '$matchText',
              style: style,
            );
          }

          widgets.add(widget);

          return '';
        },
        onNonMatch: (String text) {
          widgets.add(TextSpan(
            text: '$text',
            style: style,
          ));

          return '';
        },
      );
      return widgets;
    }

    final content = TextSpan(children: parseText(text), style: style);

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final maxWidth = constraints.maxWidth;

        var textPainter = TextPainter(
          text: link,
          textDirection: textDirection,
          textAlign: alignment,
          maxLines: maxLines,
        );

        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        textPainter.text = content;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        var textSpan;
        if (textPainter.didExceedMaxLines) {
          final pos = textPainter.getPositionForOffset(Offset(
            textSize.width - linkSize.width,
            textSize.height,
          ));
          final endIndex = textPainter.getOffsetBefore(pos.offset);
          var _text = TextSpan(
              children: expanded.value
                  ? parseText(text)
                  : parseText(text.substring(0, max(endIndex!, 0))),
              style: style);
          textSpan = TextSpan(children: [_text, link]);
        } else {
          textSpan = content;
        }

        if (selectable) {
          return SelectableText.rich(
            textSpan,
            strutStyle: strutStyle,
            textWidthBasis: textWidthBasis,
            textAlign: alignment,
            textDirection: textDirection,
            onTap: onTap,
          );
        }

        return RichText(
          textAlign: alignment,
          textDirection: textDirection,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: textScaleFactor,
          text: textSpan,
          textWidthBasis: textWidthBasis,
        );
      },
    );

    return result;
  }
}
