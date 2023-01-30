import 'dart:io';
import 'dart:isolate';
import 'package:blue/common/style.dart';
import 'package:blue/controllers/connectivity_controller.dart';
import 'package:blue/view/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async{
  tz.initializeTimeZones();
  // You need to use this line, if your main function uses async keyword because you use await statement inside it.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // To disable offline caching in Firebase for a Flutter app, you can set the persistenceEnabled property to false.
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(persistenceEnabled: false);
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp, 
      DeviceOrientation.portraitDown
    ]
  );
  // Flutter CERTIFICATE_VERIFY_FAILED error while performing a POST request.
  HttpOverrides.global = MyHttpOverrides();
  return runApp(
    const MyApp()
  );
}

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  int updateCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    final customData = await FlutterForegroundTask.getData<String>(key: 'customData');
    if (kDebugMode) {
      print('customData: $customData');
    }
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'FirstTaskHandler',
      notificationText: timestamp.toString(),
      callback: updateCount >= 10 ? updateCallback : null
    );

    // Send data to the main isolate.
    sendPort?.send(timestamp);
    sendPort?.send(updateCount);

    updateCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    if (kDebugMode) {
      print('onButtonPressed >> $id');
    }
  }
}

void updateCallback() {
  FlutterForegroundTask.setTaskHandler(SecondTaskHandler());
}

class SecondTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'SecondTaskHandler',
      notificationText: timestamp.toString()
    );

    // Send data to the main isolate.
    sendPort?.send(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConnectivityController connectionController =  Get.put(ConnectivityController());
  ReceivePort? _receivePort;

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        // buttons: [
        //   const NotificationButton(id: 'sendButton', text: 'Send'),
        //   const NotificationButton(id: 'testButton', text: 'Test'),
        // ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    connectionController.checkInitialConnectivity();
  }

  @override
  void dispose() {
    _receivePort?.close();
    super.dispose();
  }

  // This widget is the root of your application .
  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child:MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'F Sensing',
        theme: ThemeData(
          primarySwatch: primarySwatch, //Theme from style.dart
        ),
        // AppRepainWidget for native background service
        home: const WithForegroundTask(
          child: HomePage()
        ),
      ),
    );
  }
}
