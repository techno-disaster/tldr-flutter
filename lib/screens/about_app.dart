import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:tldr/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17181c),
      appBar: AppBar(
        title: Text("Info"),
        elevation: 0,
        backgroundColor: Color(0xff17181c),
      ),
      body: Container(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Image.asset(
                    'assets/images/tldr.png',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                Text(
                  "About TLDR",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                MarkdownWidget(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  data: aboutApp,
                  styleConfig: StyleConfig(
                    codeConfig: CodeConfig(
                      codeStyle: GoogleFonts.robotoMono(fontSize: 12),
                    ),
                    pConfig: PConfig(
                      selectable: false,
                      onLinkTap: (url) => _launchUrl(url),
                    ),
                    markdownTheme: MarkdownTheme.darkTheme,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 220,
                  height: 50,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Color(0xff2e2f37),
                    onPressed: () =>
                        _launchUrl(appURL), 
                    child: Row(
                      children: [
                        Container(  
                          height: 20,
                          width: 20,
                          child: Image.asset(
                            "assets/images/github.png",
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "View this app on Github",
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                Text(
                  "Credits",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(Icons.closed_caption_off),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Flare animation by Cas van Luijtelaar found ",
                            ),
                            TextSpan(
                              text: "here",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launch(flareURL);
                                },
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(Icons.closed_caption_off),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "tldr-pages icon found ",
                            ),
                            TextSpan(
                              text: "here",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launch(iconURL);
                                },
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _launchUrl(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
