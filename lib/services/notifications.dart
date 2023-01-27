// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../cleanWebView.dart';
import '../main.dart';

const AndroidNotificationDetails androidNotificationDetails =
AndroidNotificationDetails('your channel id', 'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    // icon: 'ic_bg_service_small',
    ticker: 'ticker');

const NotificationDetails notificationDetails =
NotificationDetails(android: androidNotificationDetails);

Future handleGetNotifications(ServiceInstance service) async {
  // Timer.periodic(const Duration(seconds: 15), (timer) async {

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      // print('START: setAsForeground()');
      service.setAsBackgroundService(); // Notification hidden
    });

    service.on('setAsBackground').listen((event) {
      // print('START: setAsBackground()');
      service.setAsForegroundService(); // Notification shows
    });
  }

  service.on('cookieUpdate').listen((event) {
    // print('START: cookieUpdate()');
    // print('event $event');
    cookie = event?['cookie'];
  });

  service.on('appStateUpdate').listen((event) {
    // print('START: appStateUpdate()');
    // print('event $event');
    appState = event?['appState'];
  });

  Timer.periodic(const Duration(seconds: kDebugMode ? 20 : 45), (timer) async {
    // print('${DateTime.now()} START: 45 SEC PASSED: handleGetNotifications()');
    // print('olderCounter: $olderCounter');
    // print('appState: $appState');
    // print('cookie $cookie');

    // if (appState != AppLifecycleState.resumed) {
    var isGetNotification = service is AndroidServiceInstance &&
        (await service.isForegroundService());
    // print('isGetNotification: $isGetNotification');

    if (isGetNotification) {
      var counter = await _checkNotification();
      if (counter != 0 && counter != olderCounter) {
        olderCounter = counter;
        flutterLocalNotificationsPlugin.show(
            0,
            'יש לך ' '$counter ' 'הודעות חדשות!',
            '' // תיאור התראה // 'לקבלת התראות, שמור על היישומון פתוח'
            ,
            notificationDetails);
      }
    }
  });
}



Future<int> _checkNotification() async {
  // print('START: _checkNotification()');
  // print('cookie $cookie');
  var resp = await Dio().get('https://stips.co.il/api?name=messages.count&api_params={}',
      options: Options(
        // cookie is global & set on Webview
        headers: {'cookie': '$cookie'}, // cookie is global & set on Webview
        // headers: {'cookie': '_ga=GA1.3.1151012374.1673440711; _gid=GA1.3.1997928057.1673440711; Login%5FUser=hashedpassword=LGHoHMsrnDDoFLsFHGEDFLEpLpsnsIHE&mail=vqn0ov6LD%2BI%40tznvy%2Ep1z&rememberme=true&stype=75r4&id=GHLLII&password=Vqn0DIHFG; trc_cookie_storage=taboola%2520global%253Auser-id%3D4fc9c72f-4ae5-4357-87d0-588752fbe0d5-tuctab8887c; ASPSESSIONIDSESTCBQR=FFDGEBFDAIBDCAOOCMIDGJCB; ASPSESSIONIDCGSRDCTS=IHMGBNBAGADHGIIBMFEKGLKF; ASPSESSIONIDQGRQBBRQ=ILKIHIOAJENBENHHHFFCPLAI; ASPSESSIONIDAEQTACST=DMKHMELBCLPCDCIDLEFHGNOO; ASPSESSIONIDQESTBCQR=EDMPKAICHEBIGFGGJEIDCGLO; ASPSESSIONIDSGSSABRQ=CKEBDLEDPEAHKMPCMGCOBKEC'},
      ));

  // print('resp.data ${resp.data}');
  var counter = jsonDecode(resp.data)['data']['messagesCount'];
  // print('counter $counter');
  return counter;
}
