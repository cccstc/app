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

import 'package:flutter/material.dart';
import 'booklet.dart' show BookletScreen;
import 'record.dart' show RecordScreen;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int viewIndex = 0;

  void _showBooklet() {
    setState(() {
      viewIndex = 0;
    });
  }

  void _showRecord() {
    setState(() {
      viewIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currView = _getViewFromIndex(viewIndex);
    String title = _getTitleFromIndex(viewIndex);
    Color appBarColor = _getColorFromIndex(viewIndex);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
        backgroundColor: appBarColor,
      ),
      body: new Center(child: currView),
      drawer: new Drawer(
        child: new ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            new DrawerHeader(
              child: new Text(
                '中華基督教會沙田堂',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              decoration: new BoxDecoration(
                color: Colors.green,
              ),
            ),
            new ListTile(
              title: new Text(
                _getTitleFromIndex(0),
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                Navigator.pop(context);
                _showBooklet();
              },
            ),
            new ListTile(
              title: new Text(
                _getTitleFromIndex(1),
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRecord();
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _getViewFromIndex(int index) {
  if (index == 0) {
    return new BookletScreen();
  } else {
    return new RecordScreen();
  }
}

String _getTitleFromIndex(int index) {
  if (index == 0) {
    return "崇拜週刊";
  } else {
    return "講道重溫";
  }
}

Color _getColorFromIndex(int index) {
  if (index == 0) {
    return Colors.white;
  } else {
    return Colors.white;
  }
}
