// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';

String? cookie;
int? olderCounter;

Future handleGetNotifications() async {
  // Timer.periodic(const Duration(seconds: 15), (timer) async {
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    print('${DateTime.now()} START: 15 SEC PASSED: handleGetNotifications()');
    print('olderCounter: $olderCounter');
    print('appState: $appState');
    print('cookie $cookie');

    // if (appState != AppLifecycleState.resumed) {
    //   var counter = await _checkNotification();
    //   if (counter != 0 && counter != olderCounter) {
    //     olderCounter = counter;
    //     flutterLocalNotificationsPlugin.show(
    //         0,
    //         'יש לך ' '$counter ' 'הודעות חדשות!',
    //         '' // תיאור התראה // 'לקבלת התראות, שמור על היישומון פתוח'
    //         ,
    //         notificationDetails);
    //   }
    // }
  });
}

Future<int> _checkNotification() async {
  print('START: _checkNotification()');
  print('cookie ${cookie}');
  var resp = await Dio().get('https://stips.co.il/api?name=messages.count&api_params={}',
      options: Options(
        // cookie is global & set on Webview
        headers: {'cookie': '$cookie'}, // cookie is global & set on Webview
        // headers: {'cookie': '_ga=GA1.3.1151012374.1673440711; _gid=GA1.3.1997928057.1673440711; Login%5FUser=hashedpassword=LGHoHMsrnDDoFLsFHGEDFLEpLpsnsIHE&mail=vqn0ov6LD%2BI%40tznvy%2Ep1z&rememberme=true&stype=75r4&id=GHLLII&password=Vqn0DIHFG; trc_cookie_storage=taboola%2520global%253Auser-id%3D4fc9c72f-4ae5-4357-87d0-588752fbe0d5-tuctab8887c; ASPSESSIONIDSESTCBQR=FFDGEBFDAIBDCAOOCMIDGJCB; ASPSESSIONIDCGSRDCTS=IHMGBNBAGADHGIIBMFEKGLKF; ASPSESSIONIDQGRQBBRQ=ILKIHIOAJENBENHHHFFCPLAI; ASPSESSIONIDAEQTACST=DMKHMELBCLPCDCIDLEFHGNOO; ASPSESSIONIDQESTBCQR=EDMPKAICHEBIGFGGJEIDCGLO; ASPSESSIONIDSGSSABRQ=CKEBDLEDPEAHKMPCMGCOBKEC'},
      ));

  print('resp.data ${resp.data}');
  var counter = jsonDecode(resp.data)['data']['messagesCount'];
  // print('counter $counter');
  return counter;
}
