import 'package:flutter/material.dart';
import 'package:rich_text_view/src/models.dart';

class SuggestionController extends ChangeNotifier {
  final String hashtagSymbol;
  final String mentionSymbol;
  final double containerMaxHeight;
  final List<HashTag>? initalTags;
  final List<Mention>? intialMentions;
  final Future<List<HashTag>> Function(String)? onSearchTags;
  final Future<List<Mention>> Function(String)? onSearchMention;

  /// Initial suggested hashtags when the user enters the [hashtagSymbol]
  final List<HashTag>? hashtagSuggestions;

  /// Initial suggested mentions when the user enters the [mentionSymbol]
  final List<Mention>? mentionSuggestions;

  /// height of the suggestion item
  final double itemHeight;

  /// Callback for when a suggestion is selected during search
  final Function(Mention)? onMentionSelected;

  /// Callback for when a hashtag is selected during search
  final Function(HashTag)? onHashTagSelected;

  /// Which position to append the suggested list. defaults to [SuggestionPosition.bottom].
  final SuggestionPosition? position;

    /// Custom mention widget shown during search
  final Widget Function(Mention)? mentionSearchCard;

  /// Custom hashtag widget shown during search
  final Widget Function(HashTag)? hashTagSearchCard;

  SuggestionController(
      {this.itemHeight = 100,
      this.hashtagSymbol = '#',
      this.mentionSymbol = '@',
      this.containerMaxHeight = 250,
      this.initalTags,
      this.intialMentions,
      this.onSearchMention,
      this.onSearchTags,
      this.hashtagSuggestions = const [],
      this.mentionSuggestions = const [],
      this.onHashTagSelected,
      this.onMentionSelected,
      this.position = SuggestionPosition.bottom,
      this.hashTagSearchCard,
      this.mentionSearchCard});

  var state = SuggestionState();

  void emit(SuggestionState value) {
    state = value;
    notifyListeners();
  }

  set suggestions(List<Mention> value) {
    emit(state.copyWith(mentions: value));
  }

  set hashtags(List<HashTag> value) {
    emit(state.copyWith(hashtags: value));
  }

  set last(String? value) {
    emit(state.copyWith(last: value));
  }

  void onChanged(String? value) async {
    var _last = value ?? '';
    last = _last;
    var isHash = _last.startsWith(hashtagSymbol);
    var isMention = _last.startsWith(mentionSymbol);
    if (_last.isNotEmpty && (isHash || isMention)) {
      if (_last.length == 1) {
        clear(
            hash: isMention ? null : initalTags,
            people: isHash ? null : intialMentions);
      } else if (isMention) {
        var temp = onSearchMention != null && _last.length > 1
            ? await onSearchMention!(_last.split(mentionSymbol)[1])
            : intialMentions?.where((e) => e.title.contains(_last)).toList();
        clear(people: temp ?? []);
      } else if (isHash) {
        var temp = onSearchTags != null
            ? await onSearchTags!(_last)
            : initalTags?.where((e) => e.hashtag.contains(_last)).toList();
        clear(hash: temp);
      }
    } else {
      clear();
    }
    last = value;
  }

  set suggestionHeight(double value) {
    emit(state.copyWith(suggestionHeight: value));
  }

  set loading(bool value) {
    emit(state.copyWith(loading: value));
  }

  TextEditingController onuserselect(
      String item, TextEditingController controller) {
    var splits = controller.text.split(' ');
    splits.last = item;
    controller.value = TextEditingValue(
        text: splits.join(' '),
        selection: TextSelection.collapsed(offset: splits.join(' ').length));

    suggestionHeight = 1;
    hashtags = [];
    suggestions = [];
    return controller;
  }

  void clear({List<HashTag>? hash, List<Mention>? people, bool load = false}) {
    loading = load;
    suggestions = people ?? [];
    hashtags = hash ?? [];
    suggestionHeight = load
        ? containerMaxHeight
        : people != null
            ? (itemHeight * people.length).clamp(1.0, containerMaxHeight)
            : hash != null
                ? (itemHeight * hash.length).clamp(1.0, containerMaxHeight)
                : 1.0;
  }
}

class SuggestionState<T> {
  final List<HashTag> hashtags;
  final List<Mention?> mentions;
  final String last;
  final double suggestionHeight;
  final bool loading;

  SuggestionState(
      {this.hashtags = const [],
      this.mentions = const [],
      this.last = '',
      this.suggestionHeight = 1,
      this.loading = false});

  SuggestionState<Mention> copyWith(
      {final List<HashTag>? hashtags,
      final List<Mention>? mentions,
      final String? last,
      final double? suggestionHeight,
      final bool? loading}) {
    return SuggestionState(
        hashtags: hashtags ?? this.hashtags,
        mentions: mentions ?? this.mentions,
        last: last ?? this.last,
        suggestionHeight: suggestionHeight ?? this.suggestionHeight,
        loading: loading ?? this.loading);
  }
}
