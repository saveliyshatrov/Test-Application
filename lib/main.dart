import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Test Application',
      home: MyApp(storage: URLStorage()),
    ),
  );
}

class URLStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/URLS.txt');
  }

  Future<String> readURL() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      debugPrint("CONTENTS = $contents");

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "https://navsegda.net/";
    }
  }

  Future<File> writeURL(String URL) async {
    final file = await _localFile;
    debugPrint("URL = $URL");

    // Write the file
    return file.writeAsString(URL);
  }
}

class MyApp extends StatefulWidget {
  final URLStorage storage;

  MyApp({Key key, @required this.storage}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _URL;

  @override
  void initState() {
    super.initState();

    widget.storage.readURL().then((String value) {
      setState(() {
        _URL = value;
        debugPrint("_URL = $_URL");
        flutterWebviewPlugin.reloadUrl(_URL);
      });
    });

    _onchanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        if (state.type == WebViewState.finishLoad) {
          // if the full website page loaded
          debugPrint("loaded... $_URL");
        } else if (state.type == WebViewState.abortLoad) {
          // if there is a problem with loading the url
          debugPrint("there is a problem...");
        } else if (state.type == WebViewState.startLoad) {
          // if the url started loading
          debugPrint("start loading...");
        }
      }
    });

    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print("Current URL: $url");
        _incrementURL(url);
      }
    });
    
  }

  Future<File> _incrementURL(String _url) {
    setState(() {
      _URL = _url;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeURL(_URL);
  }

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription<WebViewStateChanged>
      _onchanged; // here we checked the url state if it loaded or start Load or abort Load
  StreamSubscription<String> _onUrlChanged;

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        url: "https://google.com", //,
        withJavascript: true, // run javascript
        withZoom: false, // if you want the user zoom-in and zoom-out
        hidden: true,
        initialChild: Container(
          // but if you want to add your own waiting widget just add InitialChild
          color: Colors.white,
          child: const Center(
            child: Text('waiting...'),
          ),
        ));
  }
}
/*import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(storage: URLStorage()),
    );
  }
}

class URLStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/url.txt');
  }

  Future<String> readURL() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "https://google.com";
    }
  }

  Future<File> writeURL(String URL) async {
    final file = await _localFile;
    return file.writeAsString(URL);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  final URLStorage storage;
  MyHomePage({Key key, @required this.storage}) : super(key: key);
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url;

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription<WebViewStateChanged>
      _onchanged; // here we checked the url state if it loaded or start Load or abort Load
  StreamSubscription<String> _onUrlChanged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.storage.readURL().then((String value) {
      setState(() {
        url = value;
      });
    });

    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print("Current URL: $url");
        //_saveURL(url);
        widget.storage.writeURL(url);
      }
    });

    _onchanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        if (state.type == WebViewState.finishLoad) {
          // if the full website page loaded
          debugPrint("loaded... $url");
        } else if (state.type == WebViewState.abortLoad) {
          // if there is a problem with loading the url
          debugPrint("there is a problem...");
        } else if (state.type == WebViewState.startLoad) {
          // if the url started loading
          debugPrint("start loading...");
        }
      }
    });

    @override
    void dispose() {
      // TODO: implement dispose
      super.dispose();
      flutterWebviewPlugin
          .dispose(); // disposing the webview widget to avoid any leaks
    }

    @override
    Widget build(BuildContext context) {
      return WebviewScaffold(
          url: url, //,
          withJavascript: false, // run javascript
          withZoom: false, // if you want the user zoom-in and zoom-out
          hidden:
              true, // put it true if you want to show CircularProgressIndicator while waiting for the page to load

          appBar: AppBar(
            title: Text("Test application"),
            centerTitle: false,
            elevation: 1, // give the appbar shadows
            iconTheme: IconThemeData(
                color: Colors
                    .white), // make the icons colors inside appbar with white color
          ),
          initialChild: Container(
            // but if you want to add your own waiting widget just add InitialChild
            color: Colors.white,
            child: const Center(
              child: Text('waiting...'),
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
  }
}*/
