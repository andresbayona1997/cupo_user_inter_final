import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shopkeeper/pages/tab_bar_page.dart';
import 'package:shopkeeper/services/auth_service.dart';
import 'package:shopkeeper/enums/auth_status_enum.dart';
import 'package:shopkeeper/pages/choose_mode_page.dart';
import 'package:shopkeeper/services/status_service.dart';

class RootPage extends StatefulWidget {
  _RootPage createState() => new _RootPage();
}

class _RootPage extends State<RootPage> {
  AuthService _authService = new AuthService();
  AuthStatusEnum _authStatus;
  StatusService _statusService = new StatusService();
  bool _validated = false;
  @override
  void initState() {
    super.initState();
    _statusService.shoopkeeperValidated().then((val) {
      print('status $val');
      _validated = val;
      print('validated $_validated');
    });
    _authStatus = AuthStatusEnum.NOT_DETERMINED;
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _authService.getCurrentUser().then((user) {
      print(user);
      setState(() {
        _authStatus = user?.uid == null
            ? AuthStatusEnum.NOT_LOGGED_IN
            : AuthStatusEnum.LOGGED_IN;
      });
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SpinKitThreeBounce(
          color: Color.fromRGBO(148, 3, 123, 1.0),
          size: 30.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatusEnum.NOT_DETERMINED:
      case AuthStatusEnum.NOT_LOGGED_IN:
        return ChooseModePage();
        break;
      case AuthStatusEnum.LOGGED_IN:
        return TabBarPage(
          validated: _validated,
        );
        // if (_userId.length > 0 && _userId != null) {
        //   return TabBarPage();
        // } else return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
