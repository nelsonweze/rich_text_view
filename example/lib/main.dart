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
          title: Text('Flutter RichTextView'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 32,
              ),
              Text('RichTextView'),
              SizedBox(
                height: 16,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RichTextView(
                  text:
                      '''Who else thinks it's thinks it's just cool to mention 
                      @jane when #JaneMustLive is trending without even trying 
                      to send a *bold* email to janedoe@gmail.com and verify the
                       facts talkmore of ivisitingi www.janedoe.com''',
                  maxLines: 3,
                  truncate: true,
                  viewLessText: 'less',
                  linkStyle: TextStyle(color: Colors.blue),
                  textAlign: TextAlign.center,
                  supportedTypes: [
                    EmailParser(
                        onTap: (email) => print('${email.value} clicked')),
                    PhoneParser(
                        onTap: (phone) => print('click phone ${phone.value}')),
                    MentionParser(
                        onTap: (mention) => print('${mention.value} clicked')),
                    UrlParser(onTap: (url) => print('visting ${url.value}?')),
                    BoldParser(),
                    HashTagParser(
                        onTap: (hashtag) =>
                            print('is ${hashtag.value} trending?'))
                  ],
                ),
              ),
              SizedBox(
                height: 48,
              ),
              Text('RichTextEditor'),
              SizedBox(
                height: 16,
              ),
              SizedBox(
                width: 300,
                child: RichTextEditor(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    suggestionController: SuggestionController(
                      mentionSymbol: '/',
                      position: SuggestionPosition.bottom,
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
                                id: index.toString(),
                                imageURL: 'imageURL',
                                subtitle: term.toLowerCase(),
                                title: '$term $index'));
                      },
                      onMentionSelected: (suggestion) {
                        print(suggestion.id);
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
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
