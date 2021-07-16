import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_view/src/models.dart';

part 'suggestion_state.dart';

class SuggestionCubit<T> extends Cubit<SuggestionState<T>> {
  SuggestionCubit() : super(SuggestionState<T>());

  set suggestions(List<T?> value) {
    emit(state.copyWith(suggestions: value));
  }

  set hashtags(List<HashTag> value) {
    emit(state.copyWith(hashtags: value));
  }

  set last(String? value) {
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

  void clear({List<HashTag>? hash, List<T?>? people, bool load = false}) {
    loading = load;
    suggestions = people ?? [];
    hashtags = hash ?? [];
    suggestionHeight = load
        ? 150.0
        : people != null
            ? 280.0
            : hash != null
                ? (80.0 * hash.length).clamp(1.0, 280.0)
                : 1.0;
  }
}
