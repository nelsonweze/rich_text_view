part of 'suggestion_cubit.dart';

class SuggestionState<T> {
  final List<HashTag> hashtags;
  final List<Suggestion?> suggestions;
  final String last;
  final double suggestionHeight;
  final bool loading;

  SuggestionState(
      {this.hashtags = const [],
      this.suggestions = const [],
      this.last = '',
      this.suggestionHeight = 1,
      this.loading = false});

  SuggestionState<Suggestion> copyWith(
      {final List<HashTag>? hashtags,
      final List<Suggestion>? suggestions,
      final String? last,
      final double? suggestionHeight,
      final bool? loading}) {
    return SuggestionState(
        hashtags: hashtags ?? this.hashtags,
        suggestions: suggestions ?? this.suggestions,
        last: last ?? this.last,
        suggestionHeight: suggestionHeight ?? this.suggestionHeight,
        loading: loading ?? this.loading);
  }
}
