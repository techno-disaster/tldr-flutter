import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:tldr/models/commad.dart';
import 'package:tldr/remote/requests.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandDetails extends StatefulWidget {
  final Command command;

  const CommandDetails({Key? key, required this.command}) : super(key: key);

  @override
  _CommandDetailsState createState() => _CommandDetailsState();
}

class _CommandDetailsState extends State<CommandDetails> {
  TldrBackend api = TldrBackend();
  String details = "";
  bool loaded = false;
  final String baseURL =
      "https://github.com/tldr-pages/tldr/blob/master/pages/";
  @override
  void initState() {
    getCommandDetails(widget.command);
    super.initState();
  }

  Future<void> getCommandDetails(command) async {
    var data = await api.details(command);
    setState(() {
      details = data;
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff17181c),
          elevation: 0,
          title: Text("tldr_  ${widget.command.name}"),
        ),
        backgroundColor: Color(0xff17181c),
        body: loaded
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownWidget(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        data: details,
                        childMargin: EdgeInsets.all(10),
                        loadingWidget: Center(
                          child: CircularProgressIndicator(),
                        ),
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
                        height: 30,
                      ),
                      Container(
                        width: 220,
                        height: 50,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Color(0xff2e2f37),
                          onPressed: () => _launchUrl(baseURL +
                              widget.command.platform +
                              "/" +
                              widget.command.name +
                              ".md"),
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
                                "Edit this page on Github",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}

void _launchUrl(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
