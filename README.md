# rich_text_view

A simple yet powerful rich text view that supports mention, hashtag, email, url and view more.

## Example

<p>
    <img src="https://raw.githubusercontent.com/nelstein/rich_text_view/main/screenshots/homepage.png" width="200px" height="auto" hspace="20"/>
</p>

###  RichTextView 
```dart
 RichTextView(
           text:
                      '''Who else thinks it's thinks it's just cool to mention 
                      @jane when #JaneMustLive is trending without even trying 
                      to send a *bold* email to janedoe@gmail.com and verify the
                       facts talkmore of visiting www.janedoe.com''',
                  maxLines: 3,
                  onEmailClicked: (email) => print('$email clicked'),
                  onHashTagClicked: (hashtag) => print('is $hashtag trending?'),
                  onMentionClicked: (mention) => print('$mention clicked'),
                  onUrlClicked: (url) => print('visting $url?'),
                  truncate: true,
                  viewLessText: 'less',
                  linkStyle: TextStyle(color: Colors.blue),
                  supportedTypes: [
                    ParsedType.EMAIL,
                    ParsedType.HASH,
                    ParsedType.MENTION,
                    ParsedType.URL,
                    ParsedType.BOLD
                  ],
                )
```
### RichTextEditor 

RichTextEditor is an input field that supports suggestions when  mentioning or using hashtags

```dart

RichTextEditor(
  suggestionPosition: SuggestionPosition.bottom,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  mentionSuggestions: [
                    Mention(
                        imageURL: 'imageURL',
                        subtitle: 'nelly',
                        title: 'Nelly Gane'),
                    Mention(
                        imageURL: 'imageURL',
                        subtitle: 'gaus',
                        title: 'Gaus Shell')
                  ],
                  onSearchMention: (term) async {
                    return List.generate(
                        20,
                        (index) => Mention(
                            imageURL: 'imageURL',
                            subtitle: term.toLowerCase(),
                            title: '$term $index'));
                  },
                  onMentionSelected: (suggestion) {
                    print(suggestion.toString());
                  },
                  onSearchTags: (term) async {
                    return [
                      HashTag(
                          hashtag: '#Dart',
                          subtitle: '30 posts',
                          trending: true),
                      HashTag(
                        hashtag: '#Flutter',
                        subtitle: '56 posts',
                      )
                    ];
                  },
                )
```

### Todo

* Add styles to mentions/hashtags in RichTextEditor
