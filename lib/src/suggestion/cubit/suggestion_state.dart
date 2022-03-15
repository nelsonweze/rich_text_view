part of 'suggestion_cubit.dart';

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
