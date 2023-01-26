import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shopkeeper/pages/tab_bar_page.dart';
import 'package:shopkeeper/utils/widgets/dialog_progress.dart';
import 'package:shopkeeper/services/auth_service.dart';
import 'package:shopkeeper/services/user_service.dart';
import 'package:shopkeeper/services/storage_service.dart';
import 'package:shopkeeper/utils/classes/auth_errors.dart';
import 'package:shopkeeper/config.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = new TextEditingController(text: null);
  TextEditingController _password = new TextEditingController(text: null);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  AuthService _authService = new AuthService();
  UserService _userService = new UserService();
  StorageService _storageService = new StorageService();
  String _errorMessage = "";

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  void _showSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: TextStyle(fontFamily: 'Raleway'),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget _showIcon() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Center(
        child: Image.asset(
          'assets/shopkeeper.png',
          height: 130.0,
        ),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      child: Form(
        child: ListView(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30.0, top: 5.0),
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    // icon: Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(8.0),
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.mail_outline,
                      size: 20.0,
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 13.0)
                    // border:
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                      // icon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                      ),
                      suffixIcon: Icon(
                        Icons.lock,
                        size: 20.0,
                      ),
                      labelText: 'Password',
                      labelStyle: TextStyle(fontSize: 13.0))),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 15.0),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
                child: RaisedButton(
                  onPressed: _validate,
                  color: Color.fromRGBO(148, 3, 123, 1.0),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).pushNamed('/passRec');
              },
              child: Text("¿Olvidaste tu contraseña?",
                style: TextStyle(
                  color: Color.fromRGBO(148, 3, 123, 1.0)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _verifyRole(String role) {
    if (role == roleName) {
      return true;
    } else {
      return false;
    }
  }

  void _validate() {
    if (_email.text != null &&
        _email.text.length > 0 &&
        _password.text != null &&
        _password.text.length >= 6) {
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() => _isLoading = true);
      _authService.signIn(_email.text, _password.text).then((uuid) {
        if (uuid != null) {
          _userService.login(_email.text, uuid).then((value) {
            print(value);
            setState(() {
              _isLoading = false;
            });
            if (value != null &&
                value["data"] != null &&
                _verifyRole(value["data"]["role_name"])) {
              print(value["data"]);
              _storageService.saveValue('token', value["data"]["access_token"]);
              _storageService.saveValue('id', value["data"]["key"]);
              _storageService.saveValue(
                  'status', value["data"]["status_profile"]);
              _storageService.saveValue(
                  'company_id', value["data"]["company_id"]);

              _storageService.saveValue(
                  'counter', value["data"]["counter_referred_code"].toString());

              _storageService.saveValue('update_key', _password.text);

              _storageService.saveValue('amount_referred',
                  value["data"]["amount_referred"].toString());

              if (value["data"]["nit"] != null) {
                _storageService.saveValue('nit', value["data"]["nit"]);
              }

              bool validated = false;

              if (value["data"]["status_profile"] == SHOPKEEPER_ENABLED) {
                validated = true;
              }

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TabBarPage(
                            validated: validated,
                          )),
                  (Route<dynamic> route) => false);

              // Navigator.pushNamedAndRemoveUntil(context, '/tabs', (Route<dynamic> route) => false);
            } else {
              _showSnackbar('Acceso denegado');
            }
          }).catchError((onError) {
            print(onError);
            _showSnackbar('Ha ocurrido un error inesperado');
          });
        }
      }).catchError((error) {
        print(error);
        setState(() {
          _isLoading = false;

          if (error.code != null) {
            _errorMessage = AuthErrors.getErrorMsg(error.code);
            _showSnackbar(_errorMessage);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(148, 3, 123, 1.0),
        elevation: 0.0,
        title: Text('Iniciar sesión',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17.0)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),
        // iconTheme: IconThemeData(opacity: 0.1),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromRGBO(148, 3, 123, 1.0),
                  Color.fromRGBO(191, 111, 178, 1.0)
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              )),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              margin: EdgeInsets.only(
                  top: 15.0, bottom: 45.0, left: 20.0, right: 20.0),
              child: Container(
                child: ListView(
                  padding: EdgeInsets.all(20.0),
                  shrinkWrap: true,
                  children: <Widget>[_showIcon(), _showForm()],
                ),
              ),
            ),
          ),
          DialogProgress(
            isLoading: _isLoading,
          )
        ],
      ),
    );
  }
}
