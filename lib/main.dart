import 'package:flutter/material.dart';
import 'package:flutter_awesome_notifications_tutorial/home_page.dart';
import 'package:flutter_awesome_notifications_tutorial/notifications/notifications.dart';

void main() async {
  //*initializing AwesomeNotifications
  await NotificationController.initializeLocalNotifications();
  //Old method.
  /* AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        defaultColor: Colors.teal,
        //this sets the importance of notifications like if should show on top of apps
        importance: NotificationImportance.High,
        //this will show notification badge on app icon
        channelDescription: 'Notification channel for basic tests',
        channelShowBadge: true,
      ),
    ],
  ); */

  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> homeNavigatorKey =
      GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: homeNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.tealAccent),
      ),
      title: 'Green Thumbs',
      home: HomePage(),
    );
  }
}
