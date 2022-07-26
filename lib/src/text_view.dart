import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'util.dart';

/// Creates a [RichText] widget that supports emails, mentions, hashtags and more.
///
/// When [viewLessText] is specified, toggling between view more and view less will be supported.
///
/// For displaying a rich text editor, see the [RichTextEditor] class
///
class RichTextView extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle linkStyle;
  final TextStyle? boldStyle;
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
  final bool truncate;

  /// the view more text if `truncate` is true
  final String viewMoreText;

  /// if included, will show a view less text
  final String? viewLessText;
  final List<ParsedType> supportedTypes;
  final RegexOptions regexOptions;
  final TextAlign textAlign;

  final void Function(String)? onHashTagClicked;
  final void Function(String)? onMentionClicked;
  final void Function(String)? onEmailClicked;
  final void Function(String)? onUrlClicked;
  final void Function(String)? onBoldClicked;
  final void Function(String)? onPhoneClicked;
  final bool toggleTruncate;

  RichTextView({
    Key? key,
    required this.text,
    required this.supportedTypes,
    required this.truncate,
    required this.linkStyle,
    this.style,
    this.toggleTruncate = false,
    this.regexOptions = const RegexOptions(),
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.maxLines,
    this.onTap,
    this.onMore,
    this.viewMoreText = 'more',
    this.viewLessText,
    this.selectable = false,
    this.boldStyle,
    this.onHashTagClicked,
    this.onMentionClicked,
    this.onEmailClicked,
    this.onPhoneClicked,
    this.onUrlClicked,
    this.onBoldClicked,
  }) : super(key: key);

  @override
  State<RichTextView> createState() => _RichTextViewState();
}

class _RichTextViewState extends State<RichTextView> {
  late bool _expanded;
  late int? _maxLines;
  late TextStyle linkStyle;
  late List<MatchText> parse;

  Map<String, String?> formatBold({String? pattern, String? str}) {
    return {'display': str?.substring(1, str.length - 1)};
  }

  @override
  void initState() {
    super.initState();
    _expanded = !widget.truncate;
    _maxLines = widget.truncate ? (widget.maxLines ?? 2) : widget.maxLines;

    linkStyle = widget.linkStyle;
    parse = [
      MatchText(
        type: ParsedType.HASH,
        style: linkStyle,
        onTap: widget.onHashTagClicked,
      ),
      MatchText(
        type: ParsedType.PHONE,
        style: linkStyle,
        onTap: widget.onPhoneClicked,
      ),
      MatchText(
        type: ParsedType.BOLD,
        renderText: formatBold,
        onTap: (txt) {
          widget.onBoldClicked?.call(txt.substring(1, txt.length - 1));
        },
      ),
      MatchText(
        type: ParsedType.MENTION,
        style: linkStyle,
        onTap: widget.onMentionClicked,
      ),
      MatchText(
        type: ParsedType.EMAIL,
        style: linkStyle,
        onTap: widget.onEmailClicked,
      ),
      MatchText(
        type: ParsedType.URL,
        style: linkStyle,
        onTap: widget.onUrlClicked,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var _style = widget.style ?? Theme.of(context).textTheme.bodyText2;
    var link = _expanded && widget.viewLessText == null
        ? TextSpan()
        : TextSpan(
            children: [
              TextSpan(text: ' \u2026'),
              TextSpan(
                  text: _expanded ? widget.viewLessText : widget.viewMoreText,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    }),
            ],
            style: linkStyle,
          );

    List<InlineSpan> parseText(String txt) {
      var newString = txt;

      var _mapping = <String, MatchText>{};

      parse.forEach((e) {
        if (e.type == ParsedType.EMAIL &&
            widget.supportedTypes.contains(ParsedType.EMAIL)) {
          _mapping[RTUtils.emailPattern] = e;
        } else if (e.type == ParsedType.PHONE &&
            widget.supportedTypes.contains(ParsedType.PHONE)) {
          _mapping[RTUtils.phonePattern] = e;
        } else if (e.type == ParsedType.URL &&
            widget.supportedTypes.contains(ParsedType.URL)) {
          _mapping[RTUtils.urlPattern] = e;
        } else if (e.type == ParsedType.BOLD &&
            widget.supportedTypes.contains(ParsedType.BOLD)) {
          _mapping[RTUtils.boldPattern] = e
            ..style = widget.boldStyle ??
                _style?.copyWith(fontWeight: FontWeight.bold);
        } else if (e.type == ParsedType.MENTION &&
            widget.supportedTypes.contains(ParsedType.MENTION)) {
          _mapping[RTUtils.mentionPattern] = e;
        } else if (e.type == ParsedType.HASH &&
            widget.supportedTypes.contains(ParsedType.HASH)) {
          _mapping[RTUtils.hashPattern] = e;
        }
      });

      final pattern = '(${_mapping.keys.toList().join('|')})';

      var widgets = <InlineSpan>[];

      newString.splitMapJoin(
        RegExp(
          pattern,
          multiLine: widget.regexOptions.multiLine,
          caseSensitive: widget.regexOptions.caseSensitive,
          dotAll: widget.regexOptions.dotAll,
          unicode: widget.regexOptions.unicode,
        ),
        onMatch: (Match match) {
          final matchText = match[0];

          final mapping = _mapping[matchText!] ??
              _mapping[_mapping.keys.firstWhere((element) {
                final reg = RegExp(
                  element,
                  multiLine: widget.regexOptions.multiLine,
                  caseSensitive: widget.regexOptions.caseSensitive,
                  dotAll: widget.regexOptions.dotAll,
                  unicode: widget.regexOptions.unicode,
                );
                return reg.hasMatch(matchText);
              }, orElse: () {
                return '';
              })];

          InlineSpan span;

          if (mapping != null) {
            if (mapping.renderText != null) {
              var result = Map<String, String>.from(
                  mapping.renderText!(str: matchText, pattern: pattern));

              span = TextSpan(
                text: "${result['display']}",
                style: mapping.style ?? linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => mapping.onTap!(matchText),
              );
            } else {
              span = TextSpan(
                text: '$matchText',
                style: mapping.style ?? linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => mapping.onTap!(matchText),
              );
            }
          } else {
            span = TextSpan(
              text: '$matchText',
              style: _style,
            );
          }
          widgets.add(span);
          return '';
        },
        onNonMatch: (String text) {
          widgets.add(TextSpan(
            text: '$text',
            style: _style,
          ));

          return '';
        },
      );
      return widgets;
    }

    final content = TextSpan(children: parseText(widget.text), style: _style);

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final maxWidth = constraints.maxWidth;

        var textPainter = TextPainter(
          text: link,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          maxLines: _maxLines,
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
              children: _expanded
                  ? parseText(widget.text)
                  : parseText(widget.text.substring(0, max(endIndex!, 0))),
              style: widget.style);
          textSpan = TextSpan(children: [_text, link]);
        } else {
          textSpan = content;
        }

        if (widget.selectable) {
          return SelectableText.rich(
            textSpan,
            strutStyle: widget.strutStyle,
            textWidthBasis: widget.textWidthBasis,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            onTap: widget.onTap,
          );
        }

        return RichText(
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          textScaleFactor: widget.textScaleFactor,
          text: textSpan,
          textWidthBasis: widget.textWidthBasis,
        );
      },
    );

    return result;
  }
}
