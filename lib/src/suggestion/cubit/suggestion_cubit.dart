import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_view/src/models.dart';

part 'suggestion_state.dart';

class SuggestionCubit extends Cubit<SuggestionState> {
  final double itemHeight;
  SuggestionCubit(this.itemHeight) : super(SuggestionState());

  set suggestions(List<Mention> value) {
    emit(state.copyWith(mentions: value));
  }

  set hashtags(List<HashTag> value) {
    emit(state.copyWith(hashtags: value));
  }

  void onChanged(
      String? value,
      List<HashTag>? initalTags,
      List<Mention>? intialMentions,
      Future<List<HashTag>> Function(String)? onSearchTags,
      Future<List<Mention>> Function(String)? onSearchPeople) async {
    var last = value ?? '';
    emit(state.copyWith(last: last));
    var isHash = last.startsWith('#');
    var isMention = last.startsWith('@');
    if (last.isNotEmpty && (isHash || isMention)) {
      if (last.length == 1) {
        clear(
            hash: isMention ? null : initalTags,
            people: isHash ? null : intialMentions);
      } else if (isMention) {
        var temp = onSearchPeople != null && last.length > 1
            ? await onSearchPeople(last.split('@')[1])
            : intialMentions?.where((e) => e.title.contains(last)).toList();
        clear(
          people: temp ?? [],
        );
      } else if (isHash) {
        await Future.delayed(Duration(milliseconds: 500));
        var temp = onSearchTags != null
            ? await onSearchTags(last)
            : initalTags?.where((e) => e.hashtag.contains(last)).toList();
        clear(
          hash: temp,
        );
      }
    } else {
      clear();
    }
    emit(state.copyWith(last: value));
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
        ? 150.0
        : people != null
            ? (itemHeight * people.length).clamp(1.0, 280.0)
            : hash != null
                ? (itemHeight * hash.length).clamp(1.0, 280.0)
                : 1.0;
  }
}
