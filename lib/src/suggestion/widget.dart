import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_view/rich_text_view.dart';

class SearchItemWidget extends StatefulWidget {
  final SuggestionCubit cubit;
  final TextEditingController? controller;
  final Function(TextEditingController)? onTap;
  final SuggestionPosition? suggestionPosition;
  final Widget Function(Mention)? mentionSearchCard;
  final Widget Function(HashTag)? hashTagSearchCard;
  final Function(Mention)? onMentionSelected;
  final Function(HashTag)? onHashTagSelected;
  SearchItemWidget(
      {required this.cubit,
      this.controller,
      this.onTap,
      this.suggestionPosition,
      this.mentionSearchCard,
      this.hashTagSearchCard,
      this.onHashTagSelected,
      this.onMentionSelected});

  @override
  _SearchItemWidgetState createState() => _SearchItemWidgetState();
}

class _SearchItemWidgetState extends State<SearchItemWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuggestionCubit, SuggestionState>(
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
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator()),
                      ))
                  : Scrollbar(
                      thickness: 3,
                      child: provider.last.startsWith('@')
                          ? ListView.builder(
                              itemCount: provider.mentions.length,
                              itemBuilder: (context, index) {
                                var mention = provider.mentions[index];
                                if (mention == null) return SizedBox();

                                return InkWell(
                                  onTap: () {
                                    var _controller = widget.cubit.onuserselect(
                                        '@${mention.subtitle} ',
                                        widget.controller!);
                                    widget.onMentionSelected?.call(mention);
                                    widget.onTap!(_controller);
                                  },
                                  child:
                                      widget.mentionSearchCard?.call(mention) ??
                                          ListUserItem(
                                            title: mention.title,
                                            subtitle: mention.subtitle,
                                            imageUrl: mention.imageURL,
                                          ),
                                );
                              },
                            )
                          : provider.hashtags.isNotEmpty
                              ? ListView.builder(
                                  itemBuilder: (context, position) {
                                    var item = provider.hashtags[position];
                                    return InkWell(
                                        onTap: () {
                                          var _controller = widget.cubit
                                              .onuserselect('${item.hashtag} ',
                                                  widget.controller!);
                                          widget.onHashTagSelected?.call(item);
                                          widget.onTap!(_controller);
                                        },
                                        child: widget.hashTagSearchCard
                                                ?.call(item) ??
                                            ListTile(
                                              onTap: null,
                                              title: Text(
                                                item.hashtag,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2,
                                              ),
                                              subtitle:
                                                  Text(item.subtitle ?? ''),
                                              trailing: item.trending
                                                  ? Text('Trending')
                                                  : SizedBox(
                                                      height: 0, width: 0),
                                            ));
                                  },
                                  itemCount: provider.hashtags.length)
                              : SizedBox(),
                    ));
        });
  }
}

class ListUserItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;

  ListUserItem(
      {Key? key,
      required this.imageUrl,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Row(children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 20,
        ),
        Flexible(
            child: Container(
          margin: EdgeInsets.only(left: 20.0, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    title.trim(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
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
              Padding(
                padding: EdgeInsets.only(top: 10),
              )
            ],
          ),
        )),
      ]),
    );
  }
}
