import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_notifications_tutorial/notifications/notifications.dart';
import 'package:flutter_awesome_notifications_tutorial/plant_stats_page.dart';
import 'package:flutter_awesome_notifications_tutorial/utilities.dart';
import 'package:flutter_awesome_notifications_tutorial/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      //*checking if we have the permission for notfication's if not requesting for .
      //this checks if the notifications for our app is enabled on the particular device
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
        if (!isAllowed) {
          await NotificationController.displayNotificationRationale();
        }
        //*creating listeners on notifications
        await NotificationController.startListeningNotificationEvents();
      });

      //Old method.
      /* AwesomeNotifications().isNotificationAllowed().then(
        (isAllowed) {
          if (!isAllowed) {
            showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: Text('Allow Notifications'),
                  content: Text('Our App would like to send you notifications'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Don\'t Allow',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => AwesomeNotifications()
                          .requestPermissionToSendNotifications()
                          .then((_) => Navigator.of(context).pop()),
                      child: Text(
                        'Allow',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            );
          }
        },
      );

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: (receivedAction) async {
          // WidgetsFlutterBinding.ensureInitialized();
          Future.delayed(
            Duration(milliseconds: 1),
            () {
              if (receivedAction.channelKey == 'basic_channel' &&
                  Platform.isIOS) {
                AwesomeNotifications().getGlobalBadgeCounter().then((value) {
                  AwesomeNotifications().setGlobalBadgeCounter(value - 1);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('getGlobalBadgeCounter $value'),
                    ),
                  );
                });
              }

              
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlantStatsPage(),
                ),
                //If [isFirst] and [isCurrent] are both true then this is the only route on the navigator (and [isActive] will also be true).
                (route) => route.isFirst,
              );
            },
          );
        },
        onNotificationCreatedMethod: (notification) {
          return Future.delayed(
            Duration(milliseconds: 1),
            () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Notfication Created on ${notification.channelKey}'),
              ),
            ),
          );
        },
      );*/
    });
  }

  @override
  void dispose() {
    super.dispose();
    NotificationController.disposeListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppBarTitle(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantStatsPage(),
                ),
              );
            },
            icon: Icon(
              Icons.insert_chart_outlined_rounded,
              size: 30,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlantImage(),
            SizedBox(
              height: 25,
            ),
            HomePageButtons(
              onPressedOne: NotificationController.createPlantFoodNotification,
              onPressedTwo: () async {
                final NotificationWeekAndTime? pickedSchedule =
                    await pickSchedule(context);
                if (pickedSchedule != null)
                  await NotificationController.createWaterReminderNotification(
                      pickedSchedule);
              },
              onPressedThree: NotificationController.cancelSchedules,
            ),
          ],
        ),
      ),
    );
  }
}
