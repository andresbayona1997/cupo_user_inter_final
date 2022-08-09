import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopkeeper/utils/classes/validators.dart';
import 'package:shopkeeper/services/auth_service.dart';
import 'package:shopkeeper/services/user_service.dart';
import 'package:shopkeeper/services/storage_service.dart';
import 'package:shopkeeper/utils/widgets/dialog_progress.dart';

class RegisterPage extends StatefulWidget {
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _email;
  TextEditingController _password;
  TextEditingController _referredCode;
  final _formKey = GlobalKey<FormState>();
  FocusNode _focusEmail = new FocusNode();
  FocusNode _focusPassword = new FocusNode();
  FocusNode _focusReferredCode = new FocusNode();
  AuthService _authService = new AuthService();
  UserService _userService = new UserService();
  StorageService _storageService = new StorageService();
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    _email = new TextEditingController();
    _password = new TextEditingController();
    _referredCode = new TextEditingController(text: null);
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

  void _validate() {
    // _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    print(_formKey.currentState.toString());
    if (_email.text != null && _password.text != null) {
      FocusScope.of(context).requestFocus(FocusNode());
      _userService
          .register(_email.text, _password.text, _referredCode.text)
          .then((response) {
        if (response["status"] == 200) {
          setState(() {
            _isLoading = false;
            _email.text = null;
            _password.text = null;
          });
          _formKey.currentState.reset();
          _showSnackbar('Usuario registrado exitosamente');
          _login(_email.text, _password.text);
        } else {
          print(response);
          setState(() {
            _isLoading = false;
            _email.text = null;
            _password.text = null;
          });

          String msg =
              (response["data"]["reason"] == 'email is already registered.')
                  ? 'Este email ya se encuentra registrado'
                  : 'Ha ocurrido un error inesperado';
          _showSnackbar(msg);
        }
      }).catchError((error) {
        print(error);
        setState(() {
          _isLoading = false;
        });
        _showSnackbar('Ha ocurrido un error inesperado');
      });
    }
  }

  void _login(String username, String password) {
    _authService.signIn(username, password).then((uuid) {
      _userService.login(username, uuid).then((result) {
        if (result != null && result["data"] != null) {
          _storageService.saveValue('token', result["data"]["access_token"]);
          _storageService.saveValue('id', result["data"]["key"]);
          _storageService.saveValue('status', result["data"]["status_profile"]);
          _storageService.saveValue(
              'counter', result["data"]["counter_referred_code"].toString());
          _storageService.saveValue(
              'amount_referred', result["data"]["amount_referred"].toString());
          _storageService.saveValue('update_key', _password.text);
          Navigator.pushNamedAndRemoveUntil(
              context, '/tabs', (Route<dynamic> route) => false);
        }
      }).catchError((error) {
        print(error);
        _showSnackbar('Ha ocurrido un error inesperado');
      });
    }).catchError((onError) {
      if (onError.code != null) {
        _showSnackbar(onError.code);
      }
    });
  }

  Widget _showIcon() {
    return Container(
        padding: EdgeInsets.all(30.0),
        child: Center(
          child: Image.asset(
            'assets/shopkeeper.png',
            height: 100.0,
          ),
        ));
  }

  Widget _showForm() {
    return Container(
      child: Form(
        key: _formKey,
        autovalidate: true,
        child: ListView(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 5.0, top: 8.0),
              child: TextFormField(
                focusNode: _focusEmail,
                autovalidate: true,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    ),
                  ),
                  suffixIcon: Icon(Icons.mail_outline, size: 20.0),
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 12.0),
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                validator: (String val) {
                  if (val.isEmpty) {
                    return 'Este campo es obligatorio';
                  } else if (!Validators.isEmail(val)) {
                    return 'El email es inválido';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
              child: TextFormField(
                autovalidate: true,
                focusNode: _focusPassword,
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
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(fontSize: 12.0),
                    errorStyle: TextStyle(fontSize: 10.0)),
                validator: (String val) {
                  if (val.isEmpty) {
                    return 'Este campo es obligatorio';
                  } else if (val.length < 6) {
                    return 'La contraseña debe tener al menos seis caracteres';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
              child: Divider(
                height: 1.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
              child: TextFormField(
                autovalidate: true,
                focusNode: _focusReferredCode,
                controller: _referredCode,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(8.0),
                      ),
                    ),
                    suffixIcon: Icon(
                      FontAwesomeIcons.listOl,
                      size: 20.0,
                    ),
                    labelText: 'Código referido',
                    labelStyle: TextStyle(fontSize: 12.0),
                    errorStyle: TextStyle(fontSize: 10.0)),
                textInputAction: TextInputAction.done,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
                child: RaisedButton(
                  onPressed: () =>
                      _formKey.currentState.validate() ? _validate() : null,
                  color: Color.fromRGBO(148, 3, 123, 1.0),
                  child: Text(
                    'Registrarme',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(148, 3, 123, 1.0),
        elevation: 0.0,
        title: Text('Registro',
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
                  top: 15.0, bottom: 50.0, left: 20.0, right: 20.0),
              child: ListView(
                padding: EdgeInsets.only(
                    top: 0.0, left: 20.0, right: 20.0, bottom: 15.0),
                shrinkWrap: true,
                children: <Widget>[_showIcon(), _showForm()],
              ),
            ),
          ),
          Positioned(
            bottom: 5.0,
            left: 50.0,
            right: 50.0,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                  onPressed: () => Navigator.of(context).pushNamed('/terms'),
                  child: Text(
                    'Terminos y condiciones',
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
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
