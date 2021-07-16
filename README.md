# rich_text_view

A simple yet powerful rich text view that supports mention, hashtag, emial, url and see more.

## Example

###  RichTextView as a Text Widget
```dart
Container(
            width: 300,
            child: RichTextView(
              text:
                  "Who else thinks it's thinks it's just cool to mention
                     @jane when #JaneMustLive is trending without even trying
                     to send an email to janedoe@gmail.comto verify the 
                     facts talkmore of visiting www.janedoe.com",
              maxLines: 3,
              align: TextAlign.center,
              onEmailClicked: (email) => print('$email clicked'),
              onHashTagClicked: (hashtag) => print('is $hashtag trending?'),
              onMentionClicked: (mention) => print('$mention clicked'),
              onUrlClicked: (url) => print('visting $url?'),
            ),
          )
```
### RichTextView as a Text Editor

You can use the RichTextView widget as an input field that supports suggestions when  mentioning or using hashtags

```dart
RichTextView(
                  editable: true,
                  suggestionPosition: SuggestionPosition.bottom,
                  onSearchPeople: (term) async {
                    return [
                      Suggestion(
                          imageURL: 'imageURL',
                          subtitle: 'I am the little guy from Coal city',
                          title: 'Nelly Gane')
                    ];
                  },
                  onSearchTags: (term) async {
                    return [
                      HashTag(hashtag: 'Dart', counts: 29, trending: true)
                    ];
                  },
                )
```


