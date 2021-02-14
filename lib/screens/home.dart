import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class TLDR extends StatefulWidget {
  @override
  _TLDRState createState() => _TLDRState();
}

class _TLDRState extends State<TLDR> {
  Uri url = Uri.https('tldr.sh', 'assets');
  String data = "";
  Map<String, String>? commands = {};
  void getpage() async {
    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print(data["commands"].length);
        for (var i = 0; i < data["commands"].length; i++) {
          commands!
              .putIfAbsent(data["commands"][i]["name"], () => data["commands"][i]["platform"][0]);
        }
        print(commands);
        // setState(() {
        //   data = response.body;
        // });
      } else
        throw Exception();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getpage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(),
      body: Container(
        child: MarkdownWidget(
          shrinkWrap: true,
          data: data,
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
        // child: Markdown(
        //   data: data,
        // ),
      ),
    );
  }
}

void _launchUrl(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
