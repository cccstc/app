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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class RecordScreen extends StatefulWidget {
  RecordScreen({Key key}) : super(key: key);

  @override
  RecordScreenState createState() => new RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {
  Future<List<Record>> records = fetchRecord(new http.Client());

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: _buildRecords());
  }

  Widget _buildRecords() {
    return new FutureBuilder<List<Record>>(
      future: records,
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
                    Record item = snapshot.data[index];
                    return _buildRow(item);
                  },
                ),
              );
            }
        }
      },
    );
  }

  Widget _buildRow(Record record) {
    return new ListTile(
      title: new Text(
        "${record.date} ${record.session}",
        style: TextStyle(fontSize: 20.0),
      ),
      subtitle: new Text(
        record.content,
        style: TextStyle(fontSize: 16.0),
      ),
      trailing: const Icon(Icons.headset),
      onTap: () => _pushAudioURL(record),
    );
  }

  // -- Actions

  Future<Null> _reload() async {
    var newRecords = fetchRecord(new http.Client());

    setState(() {
      records = newRecords;
    });

    return null;
  }

  void _pushAudioURL(Record record) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (context) => new WebviewScaffold(
              url: record.audio,
              withZoom: true,
              appBar: new AppBar(
                title: new Text(record.date),
              ),
            ),
      ),
    );
  }
}

// Data Type

class Record {
  final String date;
  final int week;
  final String audio;
  final String session;
  final String content;

  Record({this.date, this.week, this.audio, this.session, this.content});

  factory Record.fromJson(Map<String, dynamic> json) {
    return new Record(
      date: json['date'] as String,
      week: json['week'] as int,
      audio: json['audio'] as String,
      session: json['session'] as String,
      content: json['content'] as String,
    );
  }
}

// Remote Data

Future<List<Record>> fetchRecord(http.Client client) async {
  final response = await client.get("https://app.cccstc.org/record/list");
  return compute(parseRecords, response.body);
}

List<Record> parseRecords(String responseBody) {
  final parsed = json.decode(responseBody)["records"];
  return parsed.map<Record>((json) => new Record.fromJson(json)).toList();
}
