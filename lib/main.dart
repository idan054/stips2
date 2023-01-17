import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:stips2/services/notifications.dart';
import 'package:stips2/webViewScreen.dart';

import 'cleanWebView.dart';

final bgService = FlutterBackgroundService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupNotify();
  await initializeService();
  runApp(
    const MyApp(),
  );
}

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> setupNotify() async {
  print('START: setup()');
  const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSetting);
  await flutterLocalNotificationsPlugin.initialize(initSettings).then((_) {
    debugPrint('setupPlugin: setup success');
  }).catchError((Object error) {
    debugPrint('Error: $error');
  });
}

Future<void> initializeService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  // const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  // const initSettings = InitializationSettings(android: androidSetting);
  // await flutterLocalNotificationsPlugin.initialize(initSettings).then((_) {
  //   debugPrint('setupPlugin: setup success');
  // }).catchError((Object error) {
  //   debugPrint('Error: $error');
  // });

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await bgService.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'סטיפס פעיל לקבלת התראות',
      initialNotificationContent: 'יש לשמור על היישומון פתוח ברקע',
      foregroundServiceNotificationId: 88,
    ),
  );
}

Future<void> onStart(ServiceInstance service) async {
  handleGetNotifications(service);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LifeCycleManager(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.green),
        debugShowCheckedModeBanner: false,
        home: const CleanWebView(),
      ),
    );
  }
}

var appState = AppLifecycleState.resumed;

class LifeCycleManager extends StatefulWidget {
  final Widget child;

  const LifeCycleManager({Key? key, required this.child}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('START: didChangeAppLifecycleState state = $state');
    appState = state;

    if (appState == AppLifecycleState.resumed) {
      FlutterBackgroundService().invoke("setAsForeground");
    }

    if (appState == AppLifecycleState.inactive || appState == AppLifecycleState.paused) {
      FlutterBackgroundService().invoke("setAsBackground");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
