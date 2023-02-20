import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final EdgeInsetsGeometry padding;

  ///A controller for the suggestion behaviour and customisations.
  /// You can as well extend this controller for a more custom behaviour.
  final SuggestionController? suggestionController;

  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  final TextInputAction? textInputAction;

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
      this.suggestionController,
      this.textInputAction,
      this.textDirection,
      this.onEditingComplete,
      this.inputFormatters,
      this.textAlignVertical,
      this.onFieldSubmitted,
      this.onSaved,
      this.validator,
      this.padding = const EdgeInsets.only(top: 16.0)})
      : super(key: key);

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController controller;
  late SuggestionController suggestionController;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '')
      ..addListener(() {
        if (mounted) {
          var cursorPos = controller.selection.base.offset;
          var val = controller.text.substring(0, cursorPos);
          suggestionController.onChanged(val.split(' ').last.toLowerCase());
        }
      });
    suggestionController =
        (widget.suggestionController ?? SuggestionController())
          ..addListener(() {
            if (mounted) {
              setState(() {});
            }
          });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var searchItemWidget = SearchItemWidget(
          suggestionController: suggestionController,
          controller: controller,
          onTap: (contrl) {
            setState(() {
              controller = contrl;
            });
          });
      return Padding(
        padding: widget.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (suggestionController.position == SuggestionPosition.top)
              searchItemWidget,
            TextFormField(
              style: widget.style,
              focusNode: widget.focusNode,
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              readOnly: widget.readOnly,
              textDirection: widget.textDirection,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
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
            ),
            if (suggestionController.position == SuggestionPosition.bottom)
              searchItemWidget,
          ],
        ),
      );
    });
  }
}
