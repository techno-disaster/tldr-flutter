import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/constants.dart';

class TldrBackend {
  Future commands() async {
    String dir = (await getExternalStorageDirectory())!.path;
    File file = File("$dir/commands.json");
    final Uri commandsUrl = Uri.https(
      'raw.githubusercontent.com',
      '/Techno-Disaster/tldr-flutter/master/tldrdict/static/commands2.json',
    );
    var data = [];
    try {
      http.Response response = await http.get(commandsUrl);
      file.writeAsStringSync(response.body);
    } on Exception catch (e) {
      print(e);
    }
    data = jsonDecode(file.readAsStringSync());
    return data;
  }

  Future<List<String>> getVersionAndLastUpdateDateTime() async {
    final Uri getVersionURI = Uri.https(
      'raw.githubusercontent.com',
      '/Techno-Disaster/tldr-flutter/master/tldrdict/static/version.json',
    );
    Map<String, dynamic> data;
    String version = '';
    String datetime = '';
    try {
      http.Response response = await http.get(getVersionURI);
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        version = data['version']!;
        datetime = data['lastUpdatedAt']!;
      }
    } on Exception catch (e) {
      print(e);
    }
    return [version, datetime];
  }

  Future<String> details(Command command) async {
    String dir = (await getExternalStorageDirectory())!.path;
    var box = Hive.box(PAGES_INFO_BOX);
    final String? locale = box.get('locale');
    final String version = box.get('version');
    String details = "";
    try {
      details = File(
              "$dir/${locale != null && command.languages.contains(locale) ? 'pages.$locale-$version' : 'pages-$version'}/tldr/${locale != null && command.languages.contains(locale) ? 'pages.$locale' : 'pages'}/${command.platform}/${command.name}.md")
          .readAsStringSync();
    } on Exception catch (e) {
      print(e);
    }
    return details;
  }

  void downloadPages(String version, String? locale) async {
    String dir = (await getExternalStorageDirectory())!.path;
    Directory(dir + '/' + 'all-pages-$version').create(recursive: true);
    String filename = locale != null ? 'pages.$locale.zip' : 'pages.zip';
    List<FileSystemEntity> entities = await Directory(dir).list().toList();
    List<String> paths = [];
    bool latestVerionPresent(String value) =>
        value.contains('all-pages-$version');
// TODO
    // delete old versions and older languages
    // entities.forEach((element) {
    //   if (locale != null &&
    //       !element.absolute.toString().split('/').last.contains('commands') &&
    //       !element.absolute.toString().contains('pages-$version')) {
    //     if (!element.absolute.toString().contains('.' + locale + '-' + version))
    //       // delete all zips and folder which are not latest.
    //       element.delete(recursive: true);
    //   } else if (locale == null &&
    //       !element.absolute.toString().contains('pages-$version')) {
    //     element.delete(recursive: true);
    //   } else
    //     paths.add(element.absolute.toString());
    // });

    if (!paths.any(latestVerionPresent)) {
      var httpClient = http.Client();

      http.Request allPagesRequest;
      // http.Request? localePagesRequest;
      allPagesRequest = http.Request(
          'GET',
          Uri.https(
            'raw.githubusercontent.com',
            '/Techno-Disaster/tldr-flutter/master/tldrdict/static/pages_zips/',
          ));

      // if (locale != null)
      //   localePagesRequest = http.Request(
      //       'GET',
      //       Uri.https(
      //         'raw.githubusercontent.com',
      //         '/Techno-Disaster/tldr-flutter/master/tldrdict/static/pages_zips/pages.$locale.zip',
      //       ));

      zipDownloader(
        httpClient.send(allPagesRequest),
        dir,
        filename,
        version,
      );
      // if (locale != null)
      //   zipDownloader(
      //     httpClient.send(localePagesRequest!),
      //     dir,
      //     localeDirectory,
      //     filename,
      //   );
    } else
      print('Already on latest version');
  }
}

void zipDownloader(Future<http.StreamedResponse> response, String dir,
    String filename, String version) {
  List<List<int>> chunks = [];
  response.asStream().listen((http.StreamedResponse r) {
    r.stream.listen((List<int> chunk) {
      chunks.add(chunk);
    }, onDone: () async {
      File file = File('$dir/all-pages-$version/$filename');
      final Uint8List bytes = Uint8List(r.contentLength!);
      int offset = 0;
      for (List<int> chunk in chunks) {
        bytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      await file.writeAsBytes(bytes);
      final zipFile = File('$dir/all-pages-$version/$filename');
      try {
        // Read the Zip file from disk.
        final bytes = zipFile.readAsBytesSync();
        // Decode the Zip file
        final archive = ZipDecoder().decodeBytes(bytes);
        // Extract the contents of the Zip archive to disk.
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File(dir + '/all-pages-$version/' + filename)
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory(dir + '/all-pages-$version/' + filename)
                .create(recursive: true);
          }
        }
      } catch (e) {
        print(e);
      }
      return;
    });
  });
}
