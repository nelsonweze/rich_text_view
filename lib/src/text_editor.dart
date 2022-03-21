import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_view/rich_text_view.dart';

/// Creates a [TextFormField] that shows suggestions mentioning and hashtags.
///
/// When [hashtagSuggestions] or [mentionSuggestions] is specified, the search as the user types will be performed on this list.
///
/// For displaying a rich text widget, see the [RichTextView] class
///
class RichTextEditor extends StatefulWidget {
  final String? initialValue;
  final int? maxLines;
  final TextAlign textAlign;
  final TextStyle? style;
  final bool autoFocus;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final Function(String)? onChanged;
  final int? maxLength;
  final int? minLines;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final bool readOnly;
  final TextDirection? textDirection;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlignVertical? textAlignVertical;

  /// Which position to append the suggested list. defaults to [SuggestionPosition.bottom].
  final SuggestionPosition? suggestionPosition;

  final Future<List<HashTag>> Function(String)? onSearchTags;
  final Future<List<Mention>> Function(String)? onSearchMention;

  /// Initial suggested hashtags when the user enters `#`
  final List<HashTag>? hashtagSuggestions;

  /// Initial suggested mentions when the user enters `@`
  final List<Mention>? mentionSuggestions;

  /// height of the suggestion item
  final double itemHeight;

  /// Callback for when a suggestion is selected during search
  final Function(Mention)? onMentionSelected;

  /// Callback for when a hashtag is selected during search
  final Function(HashTag)? onHashTagSelected;

  /// Custom mention widget shown during search
  final Widget Function(Mention)? mentionSearchCard;

  /// Custom hashtag widget shown during search
  final Widget Function(HashTag)? hashTagSearchCard;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  const RichTextEditor(
      {Key? key,
      this.initialValue,
      this.maxLines,
      this.textAlign = TextAlign.start,
      this.style,
      this.controller,
      this.decoration,
      this.onChanged,
      this.autoFocus = false,
      this.maxLength,
      this.minLines,
      this.keyboardType,
      this.focusNode,
      this.readOnly = false,
      this.suggestionPosition = SuggestionPosition.bottom,
      this.onSearchTags,
      this.onSearchMention,
      this.itemHeight = 80,
      this.hashtagSuggestions = const [],
      this.mentionSuggestions = const [],
      this.onHashTagSelected,
      this.onMentionSelected,
      this.hashTagSearchCard,
      this.mentionSearchCard,
      this.textDirection,
      this.onEditingComplete,
      this.inputFormatters,
      this.textAlignVertical,
      this.onFieldSubmitted,
      this.onSaved,
      this.validator})
      : super(key: key);

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController controller;
  late SuggestionCubit cubit;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    cubit = SuggestionCubit(widget.itemHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var searchItemWidget = SearchItemWidget(
        cubit: cubit,
        controller: controller,
        onTap: (contrl) {
          setState(() {
            controller = contrl;
          });
        },
        onHashTagSelected: widget.onHashTagSelected,
        onMentionSelected: widget.onMentionSelected,
        mentionSearchCard: widget.mentionSearchCard,
        hashTagSearchCard: widget.hashTagSearchCard,
      );
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.suggestionPosition == SuggestionPosition.top)
              searchItemWidget,
            BlocBuilder<SuggestionCubit, SuggestionState>(
                bloc: cubit,
                builder: (context, provider) {
                  return TextFormField(
                    style: widget.style,
                    focusNode: widget.focusNode,
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    readOnly: widget.readOnly,
                    textDirection: widget.textDirection,
                    onChanged: (val) async {
                      widget.onChanged?.call(val);
                      cubit.onChanged(
                          val.split(' ').last.toLowerCase(),
                          widget.hashtagSuggestions,
                          widget.mentionSuggestions,
                          widget.onSearchTags,
                          widget.onSearchMention);
                    },
                    maxLines: widget.maxLines,
                    keyboardType: widget.keyboardType,
                    maxLength: widget.maxLength,
                    minLines: widget.minLines,
                    autofocus: widget.autoFocus,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: widget.decoration,
                    textAlign: widget.textAlign,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    inputFormatters: widget.inputFormatters,
                    textAlignVertical: widget.textAlignVertical,
                    onEditingComplete: widget.onEditingComplete,
                    validator: widget.validator,
                    onSaved: widget.onSaved,
                  );
                }),
            if (widget.suggestionPosition == SuggestionPosition.bottom)
              searchItemWidget,
          ],
        ),
      );
    });
  }
}
