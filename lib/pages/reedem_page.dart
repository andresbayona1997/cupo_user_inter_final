import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopkeeper/services/status_service.dart';
import 'package:shopkeeper/services/user_service.dart';
import 'package:shopkeeper/utils/widgets/nav_bar.dart';
import 'package:shopkeeper/utils/widgets/dialog_progress.dart';
import 'package:shopkeeper/utils/options.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shopkeeper/services/promotion_service.dart';
import 'package:shopkeeper/utils/classes/promotion_error.dart';
import 'package:shopkeeper/utils/widgets/status.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReedemPage extends StatefulWidget {
  _ReedemPageState createState() => new _ReedemPageState();
}

class _ReedemPageState extends State<ReedemPage> {
  final storage = new FlutterSecureStorage();
  bool _isLoading = true;
  TextEditingController _codeCtrl = new TextEditingController(text: null);
  TextEditingController _precio = new TextEditingController(text: null);
  TextEditingController _descuento = new TextEditingController(text: null);
  TextEditingController _fin = new TextEditingController();
  FocusNode myFocusNode;
  PromotionService _promotionService;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _validated = false;
  StatusService _statusService = new StatusService();
  UserService _userService = new UserService();

  @override
  initState() {
    super.initState();
    myFocusNode = FocusNode();
    _promotionService = new PromotionService();

    _statusService.shoopkeeperValidated().then((val) {
      if (mounted)
        setState(() {
          _validated = val;
          _isLoading = false;
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

  void _beforeRedeemPromotion(){
    if (_codeCtrl.text != null && _codeCtrl.text.length == 6) {
      setState(() => _isLoading = true);
      _promotionService.beforeRedeemPromotion(_codeCtrl.text).then((result) {
        print(result);
        setState(() => _isLoading = false);
        if (result["data"] != null) {
          bool discount = result["data"]["name_type_promotions"] == "DESCUENTOS";
          bool showPrice = false;
          double precioFinal = 0;
          showDialog(context: context, builder: (BuildContext bContext){
            return Container(
              height: 450,
              width: 200,
              child: AlertDialog(
                actions: [
                  RaisedButton(
                    onPressed: _reedemPromotion,
                    color: Color.fromRGBO(148, 3, 123, 1.0),
                    child: Text(
                      'Redimir',
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
                title: Text("Redimir promoción"),
                content: Container(
                  height: 300,
                  child: Column(
                    children: [
                      Text(result["data"]["promotion_name"],
                      textAlign: TextAlign.center,),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            Text("Calcula el porcentaje de descuento",
                              textAlign: TextAlign.center,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _precio,
                                    decoration: InputDecoration(
                                        hintText: "Ingresa el precio",
                                        suffixText: '\$'
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _descuento,
                                    decoration: InputDecoration(
                                        hintText: "Ingresa el descuento",
                                      suffixText: "%"
                                    ),
                                  ),
                                )
                              ],
                            ),
                            TextButton(
                              onPressed: (){
                                setState(() {
                                  double pre = double.parse(_precio.text);
                                  double desc = double.parse(_descuento.text);
                                  desc = desc*0.01;
                                  precioFinal = pre*desc;
                                  precioFinal = pre-precioFinal;
                                });
                                setState(() {
                                  showPrice = true;
                                  _fin.text = precioFinal.toString();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(148, 3, 123, 1.0),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text("Calcular descuento",
                                  style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
                              ),
                            ),
                            Container(
                              height: 50,
                              child: TextField(
                                controller: _fin,
                                enabled: false,
                                decoration: InputDecoration(
                                    hintText: precioFinal.toString(),
                                  suffixText: "\$"
                                ),
                              ),
                            ),
                            Text("Valor a cobrar",
                            textAlign: TextAlign.center,)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        } else {
          _showSnackbar(result["message"]);
        }
      }).catchError((error) {
        setState(() => _isLoading = false);
        _showSnackbar('Ha ocurrido un error inesperado');
      });
    }
  }

  void _reedemPromotion() {
      _promotionService.reedemPromotion(_codeCtrl.text).then((result) {
        Navigator.pop(context);
        print(result);
        setState(() => _isLoading = false);
        if (result["data"] != null) {
          _codeCtrl.clear();
          _showSnackbar('Codigo redimido exitosamente');
        } else {
          _showSnackbar(result["message"]);
        }
      }).catchError((error) {
        setState(() => _isLoading = false);
        _showSnackbar('Ha ocurrido un error inesperado');
      });
  }

  Widget _showBody() {
    return Container(
      child: ListView(
        padding: EdgeInsets.all(18.0),
        children: <Widget>[
          _showLabelTextField(),
          _showTextField(),
          _showDivider(),
          _showBtnReedem()
        ],
      ),
    );
  }

  Widget _showLabelTextField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Ingresa el codigo para redimir:',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 13.0),
        ),
      ),
    );
  }

  Widget _showDivider() {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Divider(
            color: Colors.grey,
          ),
          Text('o'),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'Escanea el codigo con el botón que se encuentra en la parte inferior derecha de la pantalla',
              style: TextStyle(
                fontSize: 12.0,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _showBtnReedem() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 50.0,
        child: RaisedButton(
          onPressed: _codeCtrl.text != null ? _beforeRedeemPromotion : null,
          color: Color.fromRGBO(148, 3, 123, 1.0),
          child: Text(
            'Redimir',
            style: TextStyle(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
        ),
      ),
    );
  }

  Widget _showTextField() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: TextField(
        inputFormatters: [LengthLimitingTextInputFormatter(6)],
        focusNode: myFocusNode,
        controller: _codeCtrl,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(8.0),
            ),
          ),
          prefixIcon: Icon(FontAwesomeIcons.gift, size: 15.0),
          labelText: "Codigo de promoción",
          labelStyle: TextStyle(fontSize: 12.0),
          errorStyle: TextStyle(fontSize: 10.0, color: Colors.redAccent),
          errorText:
              _codeCtrl.text.length > 6 ? "Este codigo no es valido" : null,
        ),
      ),
    );
  }

  Future<void> _scanQrCode() async {
    String qrcodeRes;
    try {
      qrcodeRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", true, ScanMode.QR);

      if (qrcodeRes != null) {
        _codeCtrl.text = qrcodeRes;
        print("scanned");
      }
    } on PlatformException {
      qrcodeRes = 'Failed to get platform version.';
    }
  }

  Widget _floatBtn() {
    if (_validated) {
      return FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(FontAwesomeIcons.qrcode),
        onPressed: _scanQrCode,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        title: 'Redimir promoción',
      ),
      body: Stack(
        children: <Widget>[
          _validated ? _showBody() : _isLoading ? Container() : Status(),
          DialogProgress(
            isLoading: _isLoading,
          )
        ],
      ),
      floatingActionButton: _floatBtn(),
    );
  }
}
