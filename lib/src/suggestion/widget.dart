import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'cubit/suggestion_cubit.dart';

class SuggestionWidget extends StatefulWidget {
  final SuggestionCubit<Suggestion> cubit;
  final TextEditingController? controller;
  final Function(TextEditingController)? onTap;
  final SuggestionPosition? suggestionPosition;
  final Widget Function(Suggestion)? suggestionCard;
  SuggestionWidget(
      {required this.cubit,
      this.controller,
      this.onTap,
      this.suggestionPosition,
      this.suggestionCard});

  @override
  _SuggestionWidgetState createState() => _SuggestionWidgetState();
}

class _SuggestionWidgetState extends State<SuggestionWidget> {
  Widget build(BuildContext context) {
    return BlocBuilder<SuggestionCubit<Suggestion>,
            SuggestionState<Suggestion>>(
        bloc: widget.cubit,
        builder: (context, provider) {
          var border = BorderSide(
              width:
                  Theme.of(context).brightness == Brightness.dark ? 0.1 : 1.0,
              color: provider.suggestionHeight > 1
                  ? Colors.grey[200]!
                  : Colors.transparent);

          return Container(
              constraints: BoxConstraints(
                minHeight: 1,
                maxHeight: provider.suggestionHeight,
                maxWidth: double.infinity,
                minWidth: double.infinity,
              ),
              decoration: BoxDecoration(
                  border: Border(
                top: widget.suggestionPosition == SuggestionPosition.top &&
                        provider.suggestionHeight > 1.0
                    ? border
                    : BorderSide.none,
                left: border,
                right: border,
                bottom: border,
              )),
              child: provider.loading
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    )
                  : Scrollbar(
                      thickness: 3,
                      child: provider.suggestions.isNotEmpty &&
                              provider.last!.startsWith('@')
                          ? ListView.builder(
                              itemCount: provider.suggestions.length,
                              itemBuilder: (context, index) {
                                var user = provider.suggestions[index];
                                if (user == null) return Container();
                                return widget.suggestionCard?.call(user) ??
                                    ListUserItem(
                                      title: user.title,
                                      subtitle: user.subtitle,
                                      imageUrl: user.imageURL,
                                      onClick: () {
                                        var _controller = widget.cubit
                                            .onuserselect('@${user.subtitle} ',
                                                widget.controller!);
                                        widget.onTap!(_controller);
                                      },
                                    );
                              },
                            )
                          : provider.hashtags.isNotEmpty
                              ? ListView.builder(
                                  itemBuilder: (context, position) {
                                    var item = provider.hashtags[position];
                                    return ListTile(
                                      onTap: () {
                                        var _controller = widget.cubit
                                            .onuserselect('${item.hashtag} ',
                                                widget.controller!);
                                        widget.onTap!(_controller);
                                      },
                                      title: Text(
                                        item.hashtag!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      subtitle: Text('${item.counts} posts'),
                                      trailing: item.trending
                                          ? Text('Trending')
                                          : Container(
                                              height: 0,
                                              width: 0,
                                            ),
                                    );
                                  },
                                  itemCount: provider.hashtags.length)
                              : Container(),
                    ));
        });
  }
}

class ListUserItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Function()? onClick;

  ListUserItem(
      {Key? key,
      required this.imageUrl,
      required this.title,
      this.onClick,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Row(children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 45,
          ),
          Flexible(
              child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        title.trim(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                  child: Container(
                      child: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 14),
                  )),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                )
              ],
            ),
            margin: EdgeInsets.only(left: 20.0),
          )),
        ]),
      ),
    );
  }
}
