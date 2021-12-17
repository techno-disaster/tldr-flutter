import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:tldr/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<List>? supportedLanguages;
  String? currentLocale;
  @override
  void initState() {
    supportedLanguages = getSupportedLanguages();
    currentLocale = getCurrentLocale();
    super.initState();
  }

  Future<List> getSupportedLanguages() async {
    var box = Hive.box(PAGES_INFO_BOX);
    return box.get('supportedLanguages');
  }

  String? getCurrentLocale() {
    var box = Hive.box(PAGES_INFO_BOX);
    return box.get('locale');
  }

// https://stackoverflow.com/a/63961112/11885219
  String flag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => match.group(0) != null
            ? String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397)
            : 'uwu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17181c),
      appBar: AppBar(
        backgroundColor: Color(0xff17181c),
        elevation: 0,
        title: Text("Settings"),
      ),
      body: FutureBuilder<List>(
        future: supportedLanguages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  ListTile(
                    title: Text('Language'),
                    subtitle:
                        Text('Change language for commands tldr'),
                    trailing: Column(
                      children: [
                        Text(flag(currentLocale ?? 'en')),
                        SizedBox(height: 10),
                        Text(
                          ISO639ToCountry.countryData[currentLocale] ??
                              currentLocale ??
                              'English',
                          style: TextStyle(fontSize: 14),
                        )
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          backgroundColor: Color(0xff17181c),
                          content: Container(
                            height: 500.0,
                            width: 300.0,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) => ListTile(
                                onTap: () {
                                  var box = Hive.box(PAGES_INFO_BOX);
                                  box.put(
                                      'locale',
                                      snapshot.data[index] == 'en'
                                          ? null
                                          : snapshot.data[index]);
                                  setState(() {
                                    currentLocale = box.get('locale');
                                  });
                                  Navigator.pop(context);
                                },
                                leading: Text(flag(snapshot.data[index])),
                                title: Text(
                                  ISO639ToCountry
                                          .countryData[snapshot.data[index]] ??
                                      snapshot.data[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
