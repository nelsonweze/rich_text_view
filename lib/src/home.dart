import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'suggestion/cubit/suggestion_cubit.dart';
import 'suggestion/widget.dart';
import 'util.dart';

class RichTextView extends StatefulWidget {
  final String? text;
  final int? maxLines;
  final TextAlign? align;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final bool showMoreText;
  final double? fontSize;
  final bool selectable;
  final bool editable;
  final bool autoFocus;
  final String? initialValue;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final Function(String)? onChanged;
  final int? maxLength;
  final int? minLines;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final bool readOnly;
  final SuggestionPosition? suggestionPosition;
  final void Function(String)? onHashTagClicked;
  final void Function(String)? onMentionClicked;
  final void Function(String)? onEmailClicked;
  final void Function(String)? onUrlClicked;
  final Future<List<HashTag>?> Function(String)? onSearchTags;
  final Future<List<Suggestion?>?> Function(String)? onSearchPeople;

  RichTextView(
      {this.text,
      this.maxLines,
      this.align,
      this.style,
      this.linkStyle,
      this.showMoreText = true,
      this.selectable = true,
      this.controller,
      this.decoration,
      this.onChanged,
      this.editable = false,
      this.autoFocus = false,
      this.maxLength,
      this.minLines,
      this.keyboardType,
      this.focusNode,
      this.readOnly = false,
      this.initialValue,
      this.suggestionPosition = SuggestionPosition.none,
      this.fontSize,
      this.onHashTagClicked,
      this.onMentionClicked,
      this.onEmailClicked,
      this.onUrlClicked,
      this.onSearchTags,
      this.onSearchPeople});

  @override
  _RichTextViewState createState() => new _RichTextViewState();
}

class _RichTextViewState extends State<RichTextView> {
  late int _maxLines;
  TextStyle? _style;
  bool flag = true;
  bool readMore = true;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    _maxLines = widget.maxLines ?? 2;
    controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
  }

  var cubit = SuggestionCubit<Suggestion>();

  @override
  Widget build(BuildContext context) {
    _style = widget.style ??
        Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(fontSize: widget.fontSize);

    var linkStyle = widget.linkStyle ??
        _style?.copyWith(color: Theme.of(context).accentColor);

    return !widget.editable
        ? Container(
            child: ParsedText(
                text: widget.text!.trim(),
                linkStyle: linkStyle,
                onMore: () {
                  setState(() {
                    _maxLines = 1000;
                    readMore = false;
                  });
                },
                readMore: readMore,
                selectable: widget.selectable,
                parse: [
                  MatchText(
                    type: ParsedType.HASH,
                    style: linkStyle,
                    onTap: widget.onHashTagClicked,
                  ),
                  MatchText(
                    type: ParsedType.BOLD,
                    style: linkStyle?.copyWith(fontWeight: FontWeight.bold),
                    onTap: (txt) {},
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
                ],
                maxLines: readMore ? _maxLines : null,
                style: _style))
        : Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.suggestionPosition == SuggestionPosition.top)
                  SuggestionWidget(
                    cubit: cubit,
                    controller: controller,
                    onTap: (contrl) {
                      setState(() {
                        controller = contrl;
                      });
                    },
                  ),
                BlocBuilder<SuggestionCubit<Suggestion>,
                        SuggestionState<Suggestion>>(
                    bloc: cubit,
                    builder: (context, provider) {
                      return TextFormField(
                          style: widget.style,
                          focusNode: widget.focusNode,
                          controller: controller,
                          textCapitalization: TextCapitalization.sentences,
                          readOnly: widget.readOnly,
                          onChanged: (val) async {
                            widget.onChanged?.call(val);
                            cubit.last =
                                controller.text.split(' ').last.toLowerCase();
                            if (provider.last != null &&
                                (provider.last!.startsWith('@') ||
                                    provider.last!.startsWith('#'))) {
                              cubit.clear(
                                load: true,
                              );

                              if (provider.last!.startsWith('@')) {
                                if (widget.onSearchPeople == null) return null;
                                var temp = provider.last!.length > 1
                                    ? await widget.onSearchPeople!(
                                        provider.last!.split('@')[1])
                                    : provider.suggestions;
                                cubit.clear(
                                  people: temp,
                                );
                              } else {
                                if (widget.onSearchTags == null) return null;
                                await Future.delayed(
                                    Duration(milliseconds: 500));
                                var temp = provider.last!.length > 1
                                    ? await widget.onSearchTags!(provider.last!)
                                    : provider.hashtags;
                                cubit.clear(
                                  hash: temp,
                                );
                              }
                            } else {
                              cubit.clear();
                            }
                          },
                          maxLines: widget.maxLines,
                          keyboardType: widget.keyboardType,
                          maxLength: widget.maxLength,
                          minLines: widget.minLines,
                          autofocus: widget.autoFocus,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration: widget.decoration);
                    }),
                if (widget.suggestionPosition == SuggestionPosition.bottom)
                  SuggestionWidget(
                    cubit: cubit,
                    controller: controller,
                    onTap: (contrl) {
                      setState(() {
                        controller = contrl;
                      });
                    },
                  ),
              ],
            ),
          );
  }
}
