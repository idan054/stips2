// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CleanWebView extends StatefulWidget {
  const CleanWebView({Key? key}) : super(key: key);

  @override
  State<CleanWebView> createState() => _CleanWebViewState();
}

class _CleanWebViewState extends State<CleanWebView> {
  WebViewController? controller;
  int? loadProgress;

  @override
  Widget build(BuildContext context) {
    print('START: CleanWebView()');

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          controller?.goBack();
          return false;
        },
        child: Scaffold(
          // appBar: AppBar(
          //   // elevation: 0,
          //   // backgroundColor: const Color(0xff15986A),
          //   backgroundColor: const Color(0xff09c286),
          //   centerTitle: true,
          //   title: SizedBox(height: 25, child: SvgPicture.asset('assets/stips_plus.svg')),
          // ),
          body: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: 'https://stips.co.il/pen-friends',
            onProgress: (progress) async {
              loadProgress = progress;
              // _updateTheme();
            },
            onWebViewCreated: (_controller) async {
              controller = _controller;

              await controller?.runJavascript("""
               console.stdlog = console.log.bind(console);
                  console.logs = [];
                  console.log = function(){
                  console.logs.push(Array.from(arguments));
                  console.stdlog.apply(console, arguments);
              }
             """);
            },
            onPageFinished: (url) async {
              print('START: onPageFinished()');
              // _handleRemoveNotes('317');
              await _handleRemoveNotes('300170');
              _checkNotification();
            },
          ),
        ),
      ),
    );
  }

  void _checkNotification() async {
    print('START: _checkNotification()');
    var cookie = await _getCookies();
    var resp = await Dio().get('https://stips.co.il/api?name=messages.count&api_params={}',
        options: Options(
          headers: {
            'cookie': '$cookie'
          },
        ));
    print('resp ${resp}');
  }

  Future<String?> _getCookies() async {
    var cookies = await controller?.runJavascriptReturningResult('document.cookie');
    return cookies;
  }

  void _updateTheme() async {
    //~ Remove AppBar
    await controller?.runJavascript("""
               var appBar = document.getElementsByTagName('app-navbar')[0];
               appBar.parentNode.removeChild(appBar);
             """);
  }

  Future _handleRemoveNotes(String from) async {
    // await Future.delayed(const Duration(seconds: 1));

    var _isItemsAvailable = false;
    Timer.periodic(const Duration(milliseconds: 250), (timer) async {
      // print('_controller.getTitle() ${await controller?.getTitle()}');
      try {
        if (_isItemsAvailable) {
          removePenNotesFrom(from);
          // timer.cancel();
        } else {
          _isItemsAvailable = await isItemsAvailable();
        }
      } catch (e, s) {
        print(s);
      }
    });

    // await controller?.runJavascript("""
    //     console.log("START JS CHECKER()");
    //     function myAction() {
    //         console.log('2 SEC PASS - CHECK NOW IF SCROLLED');
    //     }
    //     var repeatedAction = setInterval(myAction, 2000);
    //     // clearInterval(repeatedAction); // call this line to stop the loop
    // """);
  }

  Future<bool> isItemsAvailable() async {
    await controller?.runJavascript(
      'console.log("START JS isItemsAvailable()");'
      'items = document.getElementsByClassName("item-wrapper ng-star-inserted");',
    );
    await controller?.runJavascript(
      'console.log("items.length:");'
      'console.log(items.length);',
    );

    var resp = await controller?.runJavascriptReturningResult('items.length');
    var isItemsAvailable = resp != null && int.parse(resp) != 0;
    print('DONE: isItemsAvailable: $isItemsAvailable');
    return isItemsAvailable;
  }

  void removePenNotesFrom(String from) async {
    // print('START: removePenNotesFrom()');
    await controller?.runJavascript(
      // 'console.log("START JS removePenNotesFrom()");'
      'items = document.getElementsByClassName("item-wrapper ng-star-inserted");',
    );

    await controller?.runJavascript('''
            for (let i = 0; i < items.length; i++) {
                  var item = items[i];
                  if (item.innerText.includes('$from')) {
                      console.log("-----------------");
                      console.log("REMOVE:");
                      console.log(item.innerText);
                      item.parentNode.removeChild(item);
                    }
                }
            ''');
  }
}
