import 'package:flutter/material.dart';
import 'package:rich_text_view/rich_text_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter RichTextView Example'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 32,
              ),
              Text('As a Text View Widget'),
              SizedBox(
                height: 16,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RichTextView(
                  text:
                      "Who else thinks it's thinks it's just cool to mention @jane when #JaneMustLive is trending without even trying to send an email to janedoe@gmail.com and verify the facts talkmore of visiting www.janedoe.com",
                  maxLines: 3,
                  align: TextAlign.center,
                  onEmailClicked: (email) => print('$email clicked'),
                  onHashTagClicked: (hashtag) => print('is $hashtag trending?'),
                  onMentionClicked: (mention) => print('$mention clicked'),
                  onUrlClicked: (url) => print('visting $url?'),
                  supportedTypes: [
                    ParsedType.EMAIL,
                    ParsedType.HASH,
                    ParsedType.MENTION,
                    ParsedType.URL
                  ],
                ),
              ),
              SizedBox(
                height: 48,
              ),
              Text('As a TextField Widget'),
              SizedBox(
                height: 16,
              ),
              Container(
                width: 300,
                child: RichTextView.editor(
                  suggestionPosition: SuggestionPosition.bottom,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  mentionSuggestions: [
                    Suggestion(
                        imageURL: 'imageURL',
                        subtitle: 'nelly',
                        title: 'Nelly Gane'),
                    Suggestion(
                        imageURL: 'imageURL',
                        subtitle: 'gaus',
                        title: 'Gaus Shell')
                  ],
                  onSearchPeople: (term) async {
                    return [
                      Suggestion(
                          imageURL: 'imageURL',
                          subtitle: term.toLowerCase(),
                          title: term)
                    ];
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
