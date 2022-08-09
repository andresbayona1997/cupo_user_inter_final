import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopkeeper/utils/widgets/nav_bar.dart';
import 'package:shopkeeper/utils/widgets/dialog_progress.dart';
import 'package:shopkeeper/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopkeeper/utils/forms/controllers.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shopkeeper/models/shopkeeper_model.dart';
import 'package:shopkeeper/utils/widgets/confirm_dialog.dart';
import 'package:shopkeeper/config.dart';

class MyProfilePage extends StatefulWidget {
  _MyProfilePageState createState() => new _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final storage = new FlutterSecureStorage();
  bool _isLoading = false;
  UserService _userService = new UserService();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Map dataUser;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _phoneCtrl = new TextEditingController(text: null);
  List<Widget> _actionsNavBar = [];
  String latitude;
  String longitude;
  dynamic valueSelected;
  List typologies = [];
  List statusShop = [];
  List countries = [];

  String typologySelected;
  String availabilitySelected;
  String statusShopSelected;
  String phoneCodeSelected;
  String password;
  @override
  void initState() {
    super.initState();
    _clearForm();

    statusShop = [
      {"label": "Abrir comercio", "value": "OPEN_SHOP"},
      {"label": "Cerrar comercio", "value": "CLOSED_SHOP"},
    ];

    _actionsNavBar.add(IconButton(
      icon: Icon(FontAwesomeIcons.arrowAltCircleRight),
      onPressed: openConfirmDialog,
    ));

    storage.read(key: 'update_key').then((key) => password = key);

    storage.read(key: 'id').then((id) {
      if (mounted) setState(() => _isLoading = true);
      _userService.getUserById(id).then((result) {
        print(result);
        _isLoading = false;
        if (result != null && result["data"] != null) {
          dataUser = result["data"];
          result["data"].forEach((k, v) {
            if (myProfileControllers.containsKey(k)) {
              myProfileControllers[k]["controller"].text = v;
            }
          });
          _phoneCtrl.text = dataUser["cell_phone"];
          phoneCodeSelected = dataUser["telephone_code"];
          setState(() {
            phoneCodeSelected = dataUser["telephone_code"];
            typologySelected = dataUser["typology"];
            dynamic test = daysAttention.firstWhere(
                (d) => d["value"] == dataUser["days_attention"],
                orElse: () => daysAttention[0]);
            availabilitySelected = test["value"];

            dynamic test2 = statusShop.firstWhere(
                (s) => s["value"] == dataUser["status_id"],
                orElse: () => statusShop[0]);
            statusShopSelected = test2["value"];
          });
        }
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        _isLoading = false;
        print(error);
        _showSnackbar('Ha ocurrido un error inesperado');
        if (mounted) setState(() => _isLoading = false);
      });
    });

    _userService.getTypologies().then((result) {
      if (result["data"] != null && result["data"].length > 0) {
        if (mounted) {
          setState(() {
            typologies = result["data"];
          });
        }
      }
    });

    _userService.getCountries().then((result) {
      if (result["data"] != null && result["data"].length > 0) {
        if (mounted) {
          setState(() {
            countries = result["data"];
          });
        }
      }
    });
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

  _logout() {
    _userService.signOut();
  }

  void openConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: 'Cerrar sesión',
          content: Text('Esta seguro que desea cerrar sesión?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            FlatButton(
              onPressed: _logout,
              child: Text(
                'Si',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _body() {
    return Container(
      child: Form(
        autovalidate: false,
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Column(
              children: _buildTextFields(),
            ),
            Column(
              children: <Widget>[
                _updatePhoneNumber(),
                _buildTypologiesSelect(),
                _buildAttentiodDaySelect(),
                _buildStatusShopSelect(),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
                child: RaisedButton(
                  onPressed: _validate,
                  color: Color.fromRGBO(148, 3, 123, 1.0),
                  child: Text(
                    'Actualizar',
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

  void _clearForm() {
    myProfileControllers.forEach((k, v) {
      print(v["controller"].clear());
    });
  }

  void _validate() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      ShopkeeperModel _shopkeeperModel = new ShopkeeperModel(
        businessName: myProfileControllers["business_name"]["controller"].text,
        username: dataUser["username"],
        email: dataUser["email"],
        password: password,
        typology: typologySelected,
        address: myProfileControllers["address"]["controller"].text,
        city: myProfileControllers["city"]["controller"].text,
        location: myProfileControllers["city"]["controller"].text,
        phone: myProfileControllers["phone"]["controller"].text,
        cellPhone: _phoneCtrl.text,
        telephoneCode: phoneCodeSelected,
        baseCity: myProfileControllers["city"]["controller"].text,
        daysAttention: availabilitySelected,
        initHourAttention:
            myProfileControllers["init_hour_attention"]["controller"].text,
        endHourAttention:
            myProfileControllers["end_hour_attention"]["controller"].text,
        statusId: statusShopSelected,
      );

      print(_shopkeeperModel.toJson());

      storage.read(key: 'id').then((id) {
        setState(() => _isLoading = true);
        _userService
            .updateShopkeeper(id, _shopkeeperModel.toJson())
            .then((result) {
          setState(() => _isLoading = false);
          if (result != null && result["status"] == 200) {
            if (dataUser["nit"] != null) {
              storage.write(key: 'nit', value: dataUser["nit"]);
            }
            _showSnackbar('Usuario actualizado correctamente');
          } else {
            _showSnackbar('Ha ocurrido un error inesperado');
          }
          print('Error => $result');
        }).catchError((error) {
          setState(() => _isLoading = false);
          print(error);
          _showSnackbar('Ha ocurrido un error inesperado');
        });
      });
    }
  }

  Widget _updatePhoneNumber() {
    return Container(
      padding: EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Número de celular',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.left,
          ),
          _buildPhoneCodesSelect(),
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: TextFormField(
              autovalidate: true,
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                ),
                prefixIcon: Icon(Icons.phone, size: 15.0),
                labelText: 'Número de celular',
                labelStyle: TextStyle(fontSize: 12.0),
                errorStyle: TextStyle(fontSize: 10.0),
              ),
              validator: (String newValue) {
                if (newValue.isEmpty) {
                  return 'Este campo es obligatorio';
                } else if (newValue.length < 10) {
                  return "Por favor ingresa un numero valido";
                }
                return null;
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypologiesSelect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(icon: Icon(Icons.merge_type)),
        value: typologySelected,
        hint: Text(
          'Seleccione la tipologia',
          style: TextStyle(fontSize: 12.0),
        ),
        items: typologies.map((t) {
          return DropdownMenuItem(
            child: Text(t["name"]),
            value: t["name"],
          );
        }).toList(),
        onChanged: (val) {
          print(val);
          setState(() {
            typologySelected = val;
          });
        },
        validator: (val) {
          if (val == null && typologySelected == null) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneCodesSelect() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            icon: Icon(
              Icons.confirmation_number,
            ),
          ),
          value: phoneCodeSelected,
          hint: Text('Seleccione el indicativo'),
          items: countries.map((t) {
            return DropdownMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(t["phone_code"]),
                  Text(
                    t["name"],
                    style: TextStyle(fontSize: 10.0),
                  )
                ],
              ),
              value: t["phone_code"],
            );
          }).toList(),
          onChanged: (val) {
            print(val);
            setState(() {
              phoneCodeSelected = val;
            });
          },
          validator: (val) {
            if (val == null && phoneCodeSelected == null) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildAttentiodDaySelect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(icon: Icon(Icons.event_available)),
        hint: Text(
          'Seleccione disponibilidad de atención',
          style: TextStyle(fontSize: 12.0),
        ),
        value: availabilitySelected,
        items: daysAttention.map((t) {
          return DropdownMenuItem(
            child: Text(t["label"]),
            value: t["value"],
          );
        }).toList(),
        onChanged: (val) {
          print(val);
          setState(() {
            availabilitySelected = val;
          });
        },
        validator: (val) {
          if (val == null && availabilitySelected == null) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStatusShopSelect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(icon: Icon(Icons.store)),
        hint: Text(
          'Estado del comercio',
          style: TextStyle(fontSize: 12.0),
        ),
        value: statusShopSelected,
        items: statusShop.map((t) {
          return DropdownMenuItem(
            child: Text(t["label"]),
            value: t["value"],
          );
        }).toList(),
        onChanged: (val) {
          print(val);
          setState(() {
            statusShopSelected = val;
          });
        },
        validator: (val) {
          if (val == null && statusShopSelected == null) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  void _showDatePicker(TextEditingController controller) {
    DatePicker.showTimePicker(
      context,
      locale: LocaleType.es,
      onConfirm: (DateTime date) {
        var formatter = new DateFormat().add_jm();
        String formattedDate = formatter.format(date);
        controller.text = formattedDate;
      },
      showTitleActions: true,
      theme: DatePickerTheme(
        cancelStyle:
            TextStyle(fontFamily: 'Raleway', color: Colors.red, fontSize: 12.0),
        doneStyle: TextStyle(fontFamily: 'Raleway', fontSize: 12.0),
      ),
    );
  }

  List<Widget> _buildTextFields() {
    List<Widget> textFields = [];
    myProfileControllers.forEach((key, val) {
      if (val["isSelectTime"]) {
        textFields.add(Padding(
          padding: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => _showDatePicker(val["controller"]),
            child: TextFormField(
              // autovalidate: true,
              enabled: false,
              // enableInteractiveSelection: false,
              controller: val["controller"],
              // keyboardType: val["typeKeyboard"],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                ),
                prefixIcon: Icon(val["icon"], size: 15.0),
                labelText: val["label"],
                labelStyle: TextStyle(fontSize: 12.0),
                errorStyle: TextStyle(fontSize: 10.0, color: Colors.redAccent),
              ),
              validator: (String newValue) {
                if (newValue.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
          ),
        ));
      } else {
        textFields.add(Padding(
          padding: EdgeInsets.all(8.0),
          child: TextFormField(
            autovalidate: true,
            controller: val["controller"],
            keyboardType: val["typeKeyboard"],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                ),
              ),
              prefixIcon: Icon(val["icon"], size: 15.0),
              labelText: val["label"],
              labelStyle: TextStyle(fontSize: 12.0),
              errorStyle: TextStyle(fontSize: 10.0),
            ),
            validator: (String newValue) {
              if (newValue.isEmpty) {
                return '${val["label"]} es obligatorio';
              }
              return null;
            },
          ),
        ));
      }
    });
    return textFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        title: 'Mi perfil',
        actions: _actionsNavBar,
      ),
      body: Stack(
        children: <Widget>[
          _body(),
          DialogProgress(
            isLoading: _isLoading,
          )
        ],
      ),
    );
  }
}
