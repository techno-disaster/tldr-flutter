import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:tldr/models/commad.dart';
import 'package:tldr/remote/requests.dart';
import 'package:url_launcher/url_launcher.dart';

class CommandDetails extends StatefulWidget {
  final Command command;

  const CommandDetails({Key? key, required this.command}) : super(key: key);

  @override
  _CommandDetailsState createState() => _CommandDetailsState();
}

class _CommandDetailsState extends State<CommandDetails> {
  TldrBackend api = TldrBackend();
  String details = "";
  @override
  void initState() {
    getCommandDetails(widget.command);
    super.initState();
  }

  void getCommandDetails(command) async {
    var data = await api.details(command);
    setState(() {
      details = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: MarkdownWidget(
          shrinkWrap: true,
          data: details,
          childMargin: EdgeInsets.all(10),
          loadingWidget: Center(
            child: CircularProgressIndicator(),
          ),
          styleConfig: StyleConfig(
            pConfig: PConfig(
              onLinkTap: (url) => _launchUrl(url),
            ),
            markdownTheme: MarkdownTheme.darkTheme,
          ),
        ),
      ),
    );
  }
}

void _launchUrl(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
