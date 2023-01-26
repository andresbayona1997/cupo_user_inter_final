import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopkeeper/pages/detail_promotion_page.dart';
import 'package:shopkeeper/services/user_service.dart';
import 'package:shopkeeper/utils/options.dart';
import 'package:shopkeeper/utils/widgets/dialog_progress.dart';
import 'package:shopkeeper/utils/widgets/nav_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shopkeeper/services/status_service.dart';
import 'package:shopkeeper/utils/widgets/status.dart';
import 'package:shopkeeper/models/promotion_notification_model.dart';
import 'package:shopkeeper/utils/classes/date.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationsPage extends StatefulWidget {
  NotificationsPage({this.validated});
  final bool validated;
  @override
  _NotificationsPageState createState() => new _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final storage = new FlutterSecureStorage();
  DatabaseReference _notificationRef;
  StreamSubscription<Event> _notificationsSubscription;
  List _notifications = new List();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseDatabase database;
  StatusService _statusService = new StatusService();
  bool _validated = false;
  bool _isLoading = true;
  bool _nitExists = false;

  UserService _userService = new UserService();
  @override
  void initState() {
    super.initState();

    _statusService.shoopkeeperValidated().then((val) {
      if (mounted)
        setState(() {
          _validated = val;
          _isLoading = false;
        });
      storage.read(key: 'nit').then((nit) {
        if (mounted && nit != null) {
          String fullNit = nit.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
          setState(() {
            _nitExists = true;
            _notificationRef = FirebaseDatabase.instance
                .reference()
                .child('promotions/$fullNit');
            print('path => ${_notificationRef.path}');
            _notificationsSubscription =
                _notificationRef.onChildAdded.listen(_onEntryAddedNotification);
          });
        }
      });
    });
    _userService.getStatusStore().then((value){
      if(value["data"]["status"]=="CLOSED_SHOP"){
        showDialog(context: context, builder: (BuildContext bContext){
          return AlertDialog(
            content: Container(
              height: 100,
              child: Column(
                children: [
                  Text("La tienda se encuentra cerrada, la mayoría de acciones estarán bloqueadas hasta que la tienda se encuentre abierta de nuevo")
                ],
              ),
            ),
            actions: [
              RaisedButton(
                onPressed: (){
                  _userService.changeStatusStore();
                  Navigator.pop(context);
                },
                color: Color.fromRGBO(148, 3, 123, 1.0),
                child: Text(
                  'Abrir tienda',
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
              ),
              RaisedButton(onPressed: (){
                Navigator.pop(context);
              },
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
              )
            ],
          );});
      }else{
        print("open");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _notificationsSubscription?.cancel();
  }

  _onEntryAddedNotification(Event event) async {
    _notifications.add(PromotionNotificationModel.fromSnapshot(event.snapshot));
  }

  _onTapNotification(String promotionCode, bool status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPromotionPage(
          promotionCode: promotionCode,
          statusPrm: status,
        ),
      ),
    );
  }

  int _sortList(DataSnapshot a, DataSnapshot b) {
    return b.value["unix_timestamp"].compareTo(a.value["unix_timestamp"]);
  }

  Widget _withoutNotifications() {
    return new Center(
      child: new Text(
        'No hay notificaciones',
        style: new TextStyle(color: Colors.grey, fontSize: 20),
      ),
    );
  }

  Color _getColor(String endDate, bool status) {
    String parsedCurrentDate = Date.formatDate(DateTime.now(), 'yyyy-MM-dd');
    String parsedEndDate = Date.parseDate(endDate, 'yyyy-MM-dd');
    int daysLeft = Date.compareDates(parsedCurrentDate, parsedEndDate);
    Color color = (daysLeft < 0) ? Colors.grey : Colors.teal ;
    color = status ? Colors.grey : Colors.teal;
    return color;
  }

  Widget _showNotifications() {
    return new FirebaseAnimatedList(
        sort: _sortList,
        defaultChild: DialogProgress(
          isLoading: true,
        ),
        shrinkWrap: true,
        padding:
            new EdgeInsets.only(top: 10.0, right: 10, left: 10, bottom: 10.0),
        query: _notificationRef,
        itemBuilder:
            (_, DataSnapshot snapshot, Animation<double> animation, int index) {
          return Container(
            height: 60.0,
            child: Card(
              child: InkWell(
                splashFactory: InkRipple.splashFactory,
                onTap: () =>
                    _onTapNotification(snapshot.value["promotion_code"], snapshot.value["status"]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50.0,
                      // color: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Icon(Icons.notifications,
                              color: _getColor(snapshot.value["date_end"], snapshot.value["status"])),
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            snapshot.value["name"],
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12.0),
                            textAlign: TextAlign.left,
                            // softWrap: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(
                              Date.timestampToString(
                                  snapshot.value["unix_timestamp"],
                                  'dd/MM hh:mm'),
                              style: TextStyle(
                                  fontFamily: 'Raleway', fontSize: 10)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: NavBar(
        title: 'Notificaciones',
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            DialogProgress(
              isLoading: _isLoading,
            ),
            _validated
                ? _nitExists ? _showNotifications() : _withoutNotifications()
                : _isLoading ? Container() : Status(),
          ],
        ),
      ),
    );
  }
}
