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
          title: Text('Flutter Rich Text View'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text('As a Text View Widget'),
              SizedBox(
                height: 16,
              ),
              Container(
                width: 300,
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
                    ParsedType.MENTION
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Text('As a Text Editor Widget'),
              SizedBox(
                height: 16,
              ),
              Container(
                width: 300,
                child: RichTextView(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
