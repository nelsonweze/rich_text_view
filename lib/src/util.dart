import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_view/rich_text_view.dart';

/// Email Regex - A predefined type for handling email matching
const emailPattern = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";

/// URL Regex - A predefined type for handling URL matching
const urlPattern =
    r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)";

/// Phone Regex - A predefined type for handling phone matching
const phonePattern =
    r"(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})";

const String starPattern = r"\*.*?\*";
const boldPattern = r"\$.*?\$";
const hashPattern = r"\B#+([^\x00-\x7F]|\w)+";
const mentionPattern = r"\B@+([\w]+)\b";

class ParsedText extends StatelessWidget {
  /// If non-null, the style to use for the global text.
  ///
  /// It takes a [TextStyle] object as it's property to style all the non links text objects.
  final TextStyle? style;

  final TextStyle? linkStyle;

  /// Takes a list of [MatchText] object.
  ///
  /// This list is used to find patterns in the String and assign onTap [Function] when its
  /// tapped and also to provide custom styling to the linkify text
  final List<MatchText> parse;

  /// Text that is rendered
  ///
  /// Takes a [String]
  final String text;

  /// A text alignment property used to align the the text enclosed
  ///
  /// Uses a [TextAlign] object and default value is [TextAlign.start]
  final TextAlign alignment;

  /// A text alignment property used to align the the text enclosed
  ///
  /// Uses a [TextDirection] object and default value is [TextDirection.start]
  final TextDirection? textDirection;

  /// Whether the text should break at soft line breaks.
  ///
  ///If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final double textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.text.DefaultTextStyle.textWidthBasis}
  final TextWidthBasis textWidthBasis;

  /// Make this text selectable.
  ///
  /// SelectableText does not support softwrap, overflow, textScaleFactor
  final bool selectable;

  final GestureTapCallback? onTap;
  final Function? onMore;
  final bool readMore;

  /// Creates a parsedText widget
  ///
  /// [text] paramtere should not be null and is always required.
  /// If the [style] argument is null, the text will use the style from the
  /// closest enclosing [DefaultTextStyle].
  ParsedText({
    Key? key,
    required this.text,
    this.parse = const <MatchText>[],
    this.style,
    this.linkStyle,
    this.alignment = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.maxLines,
    this.onTap,
    this.onMore,
    this.readMore = true,
    this.selectable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    // Seperate each word and create a new Array
    TextSpan link = TextSpan(
        text: "...more",
        style: linkStyle,
        recognizer: TapGestureRecognizer()..onTap = onMore as void Function()?);

    List<InlineSpan> widgets(String newString) {
      // Parse the whole text and adds "%%%%" before and after the
      // each matched text this will be used to split the text affectively
      parse.forEach((e) {
        if (e.type == ParsedType.EMAIL) {
          RegExp regExp = RegExp(emailPattern, multiLine: true);
          newString = newString.splitMapJoin(regExp,
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
        } else if (e.type == ParsedType.PHONE) {
          RegExp regExp = RegExp(phonePattern);
          newString = newString.splitMapJoin(regExp,
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
        } else if (e.type == ParsedType.URL) {
          RegExp regExp = RegExp(urlPattern);
          newString = newString.splitMapJoin(regExp,
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
        } else if (e.type == ParsedType.BOLD) {
          RegExp regExp = RegExp(starPattern, multiLine: true);
          newString = newString.splitMapJoin(regExp,
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
          newString = newString.splitMapJoin(RegExp(boldPattern),
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
        } else if (e.type == ParsedType.MENTION) {
          RegExp regExp = RegExp(
            mentionPattern,
          );
          newString = newString.splitMapJoin(regExp,
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
        } else if (e.type == ParsedType.HASH) {
          RegExp regExp = RegExp(
            hashPattern,
          );
          newString = newString.splitMapJoin(regExp,
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
        } else if (e.type == ParsedType.CUSTOM) {
          RegExp regExp = RegExp(e.pattern!,
              multiLine: e.regexOptions.multiLine,
              caseSensitive: e.regexOptions.caseSensitive,
              unicode: e.regexOptions.unicode,
              dotAll: e.regexOptions.dotAll);
          newString = newString.splitMapJoin(regExp,
              onMatch: (m) => "%%%%${m.group(0)}%%%%", onNonMatch: (m) => "$m");
        }
      });

      // splits the modified text at "%%%%"
      List<String> splits = newString.split("%%%%");

      // Map over the splits array to get a new Array with its elements as Widgets
      // checks if each word matches either a predefined type of custom defined patterns
      // if a match is found creates a link Text with its function or return a
      // default Text
      return splits.map<TextSpan>((element) {
        // Default Text object if not pattern is matched
        TextSpan widget = TextSpan(text: "$element", style: style);

        // loop over to find patterns
        for (final e in parse) {
          if (e.type == ParsedType.CUSTOM) {
            RegExp customRegExp = RegExp(e.pattern!,
                multiLine: e.regexOptions.multiLine,
                caseSensitive: e.regexOptions.caseSensitive,
                unicode: e.regexOptions.unicode,
                dotAll: e.regexOptions.dotAll);

            bool matched = customRegExp.hasMatch(element);

            if (matched) {
              if (e.renderText != null) {
                Map<String, String>? result =
                    e.renderText!(str: element, pattern: e.pattern);

                widget = TextSpan(
                  style: e.style != null ? e.style : style,
                  text: "$element",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => e.onTap!(result!['value']!),
                );
              } else {
                widget = TextSpan(
                  style: e.style != null ? e.style : style,
                  text: "$element",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => e.onTap!(element),
                );
              }
              break;
            }
          } else if (e.type == ParsedType.EMAIL) {
            RegExp emailRegExp = RegExp(emailPattern);
            bool matched = emailRegExp.hasMatch(element);

            if (matched) {
              widget = TextSpan(
                style: e.style != null ? e.style : style,
                text: "$element",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => e.onTap!(element),
              );
              break;
            }
          } else if (e.type == ParsedType.PHONE) {
            RegExp phoneRegExp = RegExp(phonePattern);

            bool matched = phoneRegExp.hasMatch(element);

            if (matched) {
              widget = TextSpan(
                style: e.style != null ? e.style : style,
                text: "$element",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => e.onTap!(element),
              );
              break;
            }
          } else if (e.type == ParsedType.URL) {
            RegExp urlRegExp = RegExp(urlPattern);

            bool matched = urlRegExp.hasMatch(element);

            if (matched) {
              widget = TextSpan(
                style: e.style != null ? e.style : style,
                text: "$element",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => e.onTap!(element),
              );
              break;
            }
          } else if (e.type == ParsedType.HASH) {
            RegExp hashRegExp = RegExp(hashPattern);

            bool matched = hashRegExp.hasMatch(element);

            element = element.startsWith('https://')
                ? element.split('https://')[1]
                : element.startsWith('http://')
                    ? element.split('http://')[1]
                    : element.startsWith('www.')
                        ? element.split('www.')[1]
                        : element;
            if (matched) {
              widget = TextSpan(
                style: e.style != null ? e.style : style,
                text: "$element",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => e.onTap!(element),
              );
              break;
            }
          } else if (e.type == ParsedType.MENTION) {
            RegExp mentionRegExp = RegExp(mentionPattern);
            bool matched = mentionRegExp.hasMatch(element);

            if (matched) {
              widget = TextSpan(
                style: e.style != null ? e.style : style,
                text: "$element",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => e.onTap!(element),
              );
              break;
            }
          } else if (e.type == ParsedType.BOLD) {
            RegExp starRegExp = RegExp(starPattern);
            bool matched = starRegExp.hasMatch(element) ||
                RegExp(boldPattern).hasMatch(element);

            if (matched) {
              widget = TextSpan(
                style: e.style != null ? e.style : style,
                text:
                    "${element.substring(1, (element.length - 1).clamp(0, element.length))}",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => e.onTap!(element),
              );
              break;
            }
          }
        }

        return widget;
      }).toList();
    }

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        // Create a TextSpan with data
        final _text = TextSpan(children: widgets(text), style: style);
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection
              .rtl, //better to pass this from master widget if ltr and rtl both supported
          maxLines: maxLines,
          ellipsis: ' ...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = _text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int? endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset);
        var textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            children: [
              readMore
                  ? TextSpan(
                      children: widgets(text.substring(0, endIndex)),
                      style: style)
                  : TextSpan(children: widgets(text), style: style)
            ]..add(link),
          );
        } else {
          textSpan = _text;
        }
        if (selectable) {
          return SelectableText.rich(
            textSpan,
            maxLines: maxLines,
            strutStyle: strutStyle,
            textWidthBasis: textWidthBasis,
            textAlign: alignment,
            textDirection: textDirection,
            onTap: onTap,
          );
        }

        return RichText(
          textAlign: defaultTextStyle.textAlign ?? TextAlign.start,
          textDirection: textDirection,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines ?? defaultTextStyle.maxLines,
          text: textSpan,
          textHeightBehavior: defaultTextStyle.textHeightBehavior,
          textWidthBasis: textWidthBasis,
        );
      },
    );

    return result;
  }
}
