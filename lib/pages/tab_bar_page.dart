import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopkeeper/pages/reedem_page.dart';
import 'package:shopkeeper/utils/options.dart';
import 'package:shopkeeper/pages/home_page.dart';
import 'package:shopkeeper/pages/notifications_page.dart';
import 'package:shopkeeper/pages/my_profile_page.dart';
import 'package:firebase_core/firebase_core.dart';

class TabBarPage extends StatefulWidget {
  TabBarPage({this.app, this.validated});
  final FirebaseApp app;
  final bool validated;
  @override
  TabBarPageState createState() => new TabBarPageState();
}

class TabBarPageState extends State<TabBarPage> {
  HomePage _homePage = new HomePage();
  ReedemPage _reedemPage = new ReedemPage();
  NotificationsPage _notificationsPage;
  MyProfilePage _myProfilePage;
  List _widgetOptions;
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  bool _validated = false;

  @override
  void initState() {
    super.initState();
    //  _statusService.shoopkeeperValidated().then((status) {
    //     print('status $status');
    //     if (mounted) setState(() => _validated = status);
    //   });
    print('here $_validated');
    _notificationsPage = new NotificationsPage(
      validated: _validated,
    );
    _myProfilePage = new MyProfilePage();
    _widgetOptions = <Widget>[
      _homePage,
      _reedemPage,
      _notificationsPage,
      _myProfilePage
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _showBottomNavAndroid() {
    return SizedBox(
        height: 50.0,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          iconSize: 16.0,
          type: BottomNavigationBarType.fixed,
          fixedColor: primaryColor,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.chartArea),
              title: Text(
                'Dashboard',
                style: TextStyle(color: Colors.grey, fontSize: 10.0),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.gift),
              title: Text(
                'Redimir',
                style: TextStyle(color: Colors.grey, fontSize: 10.0),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.bell),
              title: Text(
                'Notificaciones',
                style: TextStyle(color: Colors.grey, fontSize: 10.0),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userCircle),
              title: Text(
                'Mi perfil',
                style: TextStyle(color: Colors.grey, fontSize: 10.0),
              ),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
  }

  Widget _showBottomNavIos() {
    return BottomNavigationBar(
          backgroundColor: Colors.white,
          iconSize: 20.0,
          type: BottomNavigationBarType.fixed,
          fixedColor: primaryColor,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.chartArea),
              title: Text(
                'Dashboard',
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.gift),
              title: Text(
                'Redimir',
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.bell),
              title: Text(
                'Notificaciones',
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userCircle),
              title: Text(
                'Mi perfil',
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Theme.of(context).platform == TargetPlatform.android ? _showBottomNavAndroid() : _showBottomNavIos(),
    );
  }
}
