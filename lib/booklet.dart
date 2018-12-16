// Copyright 2018 CCCSTC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

const FEEDBACK_FORM_URL =
    "https://docs.google.com/forms/d/e/1FAIpQLSdhtehxsi4p7vzWLlIbClcOt8Z2Mr0jgaDuceGfweQStWY0MQ/viewform";

class BookletScreen extends StatefulWidget {
  BookletScreen({Key key}) : super(key: key);

  @override
  BookletScreenState createState() => new BookletScreenState();
}

class BookletScreenState extends State<BookletScreen> {
  Future<List<Booklet>> booklets = fetchBooklet(new http.Client());

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: _buildBooklets(), floatingActionButton: _buildFeedbackFAB());
  }

  Widget _buildBooklets() {
    return new FutureBuilder<List<Booklet>>(
      future: booklets,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // TODO load from cache
            return new Center(child: new Text("沒有網絡"));
          case ConnectionState.waiting:
            return new Center(child: new CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              print(snapshot.error);
              return new Center(child: new Text("發生錯誤"));
            } else {
              return new RefreshIndicator(
                onRefresh: _reload,
                child: new ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Booklet item = snapshot.data[index];
                    return _buildRow(item);
                  },
                ),
              );
            }
        }
      },
    );
  }

  Widget _buildRow(Booklet booklet) {
    return new ListTile(
      title: new Text(booklet.date),
      subtitle: new Text("第${booklet.week}週"),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _pushViewBookletPDF(booklet),
    );
  }

  Widget _buildFeedbackFAB() {
    return new FloatingActionButton(
      onPressed: () => _pushFeedbackForm(),
      tooltip: '講道回應',
      child: new Icon(Icons.insert_comment),
    );
  }

  // -- Actions

  Future<Null> _reload() async {
    var newBooklet = fetchBooklet(new http.Client());

    setState(() {
      booklets = newBooklet;
    });

    return null;
  }

  void _pushViewBookletPDF(Booklet booklet) async {
    if (Platform.isAndroid) {
      Uint8List pdfBytes = await FlutterPdfViewer.downloadAsBytes(
        booklet.pdfUrl,
      );
      FlutterPdfViewer.loadBytes(pdfBytes);
    } else {
      Navigator.of(context).push(
        new MaterialPageRoute<void>(
            builder: (context) => new WebviewScaffold(
                  url: booklet.pdfUrl,
                  withZoom: true,
                  appBar: new AppBar(
                    title: new Text(booklet.date),
                  ),
                )),
      );
    }
  }

  void _pushFeedbackForm() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) => new WebviewScaffold(
              url: FEEDBACK_FORM_URL,
              withZoom: true,
              clearCache: true,
              clearCookies: true,
              appBar: new AppBar(
                title: new Text("講道回應"),
              ),
            ),
      ),
    );
  }
}

class Booklet {
  final String date;
  final int week;
  final String pdfUrl;

  Booklet({this.date, this.week, this.pdfUrl});

  factory Booklet.fromJson(Map<String, dynamic> json) {
    return new Booklet(
      date: json['date'] as String,
      week: json['week'] as int,
      pdfUrl: json['booklet'] as String,
    );
  }
}

// Remote Data

Future<List<Booklet>> fetchBooklet(http.Client client) async {
  final response = await client.get("https://app.cccstc.org/booklet/list");
  return compute(parseBooklets, response.body);
}

List<Booklet> parseBooklets(String responseBody) {
  final parsed = json.decode(responseBody)["booklets"];
  return parsed.map<Booklet>((json) => new Booklet.fromJson(json)).toList();
}
