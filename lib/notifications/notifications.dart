import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_notifications_tutorial/main.dart';
import 'package:flutter_awesome_notifications_tutorial/plant_stats_page.dart';
import 'package:flutter_awesome_notifications_tutorial/utilities.dart';

///[NotificationController]
///
///Class Responsible For Handeling Notifications.
class NotificationController {
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
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
        NotificationChannel(
          channelKey: 'scheduled_channel',
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
          //locked does'nt allow user to dismiss notification.
          locked: true,
          channelName: 'Scheduled Notifications',
          channelDescription: 'Reminder Notifications',
          soundSource: 'resource://raw/res_custom_notification',
        )
      ],
    );
  }

  ///Create Dummy Notification
  static Future<void> createPlantFoodNotification() async {
    await AwesomeNotifications().createNotification(
      //NotificationContent is an object for providing a particular notification details.

      content: NotificationContent(
        //"id" is to identify a particular notification incase we have multiple notfications of same type.NOTE: If you create multiple notifications with the same ID, the new one replaces the previous one with the same ID.
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title:
            '${Emojis.money_money_bag + Emojis.plant_cactus} Buy Plant Food!!',
        body: 'Florist at 123 Main St. has 2 in stock',
        //adding picture
        bigPicture: 'asset://assets/notification_map.png',
        // roundedBigPicture: true,//for rounding picture not recomended.
        //setting layout.
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
  }

  ///Scheduled Notifications
  ///
  ///Can be used for timely reminders set by users
  static Future<void> createWaterReminderNotification(
    NotificationWeekAndTime notificationSchedule,
  ) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'scheduled_channel',
          title: '${Emojis.wheater_droplet} Add some water to your plant!',
          body: 'Water you plant regularly to keep it healthy.',
          notificationLayout: NotificationLayout.Default,
        ),
        actionButtons: [
          NotificationActionButton(key: 'Mark_Done', label: 'Mark Done'),
          // NotificationActionButton(key: 'Mark_Done', label: 'Mark Done'),
        ],
        schedule: NotificationCalendar(
          weekday: notificationSchedule.dayOfTheWeek,
          hour: notificationSchedule.timeOfDay.hour,
          minute: notificationSchedule.timeOfDay.minute,
          //^NOTE ITS MUST TO GIVE SECOND AND MILLISECOND ELSE IT WILL LOOP THROUGH OUT THE GIVEN MINUTE
          second: 0,
          millisecond: 0,
          repeats: true,
        ));
  }

  ///CANCEL SCHEDULES
  ///
  static Future<void> cancelSchedules() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  ///     REQUESTING NOTIFICATION PERMISSIONS
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = AppWidget.homeNavigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  /// Defines the global or static methods that gonna receive the notification
  /// events. OBS: Only after set at least one method, the notification's events are delivered.
  ///
  /// [startListeningNotificationEvents] method that receives all the notifications streams
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    BuildContext context = AppWidget.homeNavigatorKey.currentContext!;

    if (receivedAction.channelKey == 'basic_channel' && Platform.isIOS) {
      AwesomeNotifications().getGlobalBadgeCounter().then(
        (value) {
          AwesomeNotifications().setGlobalBadgeCounter(value - 1);
        },
      );
    } //checking if its the scheduled notification by passing same 'id'.
    if (receivedAction.id == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plant has been watered ,id is ${receivedAction.id}'),
        ),
      );
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const PlantStatsPage(),
      ),
      //If [isFirst] and [isCurrent] are both true then this is the only route on the navigator (and [isActive] will also be true).
      (route) => route.isFirst,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    BuildContext context = AppWidget.homeNavigatorKey.currentContext!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Notfication Created on ${receivedNotification.channelKey}'),
      ),
    );
  }

  ///  *********************************************
  /// DISPOSE METHODS
  ///
  ///[disposeListeners] method that will dispose all event listeners.
  ///  *********************************************
  static void disposeListeners() {
    AwesomeNotifications().dispose();
  }
}
