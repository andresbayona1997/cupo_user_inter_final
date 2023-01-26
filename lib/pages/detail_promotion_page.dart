import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopkeeper/utils/classes/promotion_error.dart';
import 'package:shopkeeper/utils/widgets/confirm_dialog.dart';
import 'package:shopkeeper/utils/widgets/nav_bar.dart';
import 'package:shopkeeper/utils/options.dart';
import 'package:shopkeeper/services/promotion_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopkeeper/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shopkeeper/utils/widgets/no_data_found.dart';
import 'package:shopkeeper/utils/widgets/dialog_progress.dart';
import 'package:shopkeeper/utils/widgets/no_data_found.dart';

class DetailPromotionPage extends StatefulWidget {
  DetailPromotionPage({this.promotionCode, this.statusPrm});
  final String promotionCode;
  final bool statusPrm;
  @override
  _DetailPromotionPageState createState() => _DetailPromotionPageState();
}

class _DetailPromotionPageState extends State<DetailPromotionPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  User currentUser;
  PromotionService _promotionService = new PromotionService();
  AuthService _authService = new AuthService();
  bool _noDataFound = false;
  bool descTextShowFlag = false;
  Map promotion = {
    "promotion_name": "",
    "image_url": "",
    "description_promotion": "",
    "promotion_terms": "",
    // "redeem_code": "",
    "products": null,
    "type_promotion_id": "",
    "date_init": "",
    "date_end": "",
    "init_hour": "",
    "end_hour": "",
    "type_promotion": "",
    "status": ""
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    if (widget.promotionCode != null) {
      _authService.getCurrentUser()
      .then((user) {
        _promotionService.getPromotion(widget.promotionCode)
        .then((result) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              if (result["data"] != null) {
                var data = result["data"][0];
                promotion["image_url"] = data["imageURL"];
                promotion["promotion_name"] = data["promotion_name"];
                promotion["description_promotion"] = data["description_promotion"];
                promotion["redeem_code"] = data["redeem_code"];
                promotion["promotion_terms"] = data["promotion_terms"];
                promotion["products"] = data["products"] != null ? data["products"] : [];
                promotion["type_promotion_id"] = data["type_promotion_id"];
                promotion["date_init"] = data["date_init"];
                promotion["date_end"] = data["date_end"];
                promotion["init_hour"] = data["init_hour"];
                promotion["end_hour"] = data["end_hour"];
                promotion["type_promotion"] = data["type_promotion"];
                promotion["status"] = data["accepted"];
              } else {
                _noDataFound = true;
              }
            });
          }
        })
        .catchError((onError) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _noDataFound = true;
            });
          }
        });
      });
    }
  }

  void _acceptPromotion() {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    _promotionService.acceptPromotion(widget.promotionCode)
    .then((result) {
      setState(() => _isLoading = false);
      if (result["data"] != null) {
        _showSnackbar('Promoción aceptada correctamente');
      } else {
        _showSnackbar(PromotionErrors.getErrorMsg(result["error"]));
      }
    })
    .catchError((onError) {
      setState(() => _isLoading = false);
      _showSnackbar('Ha ocurrido un error inesperado');
    });
  }

  void _showSnackbar(String msg) {
    final snackBar = SnackBar(content: Text(msg, style: TextStyle(fontFamily: 'Raleway'),),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _openConfirmDialog() {
    showDialog( 
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: 'Aceptar Promoción',
          content: Text('Esta seguro que desea aceptar la Promoción?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            FlatButton(
              onPressed: _acceptPromotion,
              child: Text('Si', style: TextStyle(color: Colors.redAccent),),
            ),
          ],
        );
      }
    );
  }

  void _showTerms() {
    showDialog( 
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text('Terminos y condiciones', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
          content: promotion["promotion_terms"] != null ? Text(promotion["promotion_terms"], style: TextStyle(fontSize: 12.0), textAlign: TextAlign.justify,) : Text(''),
        );
      }
    );
  }

  Widget _showDateInit() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
                Icon(FontAwesomeIcons.hourglassStart, size: 18.0, color: primaryColor,),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Fecha inicio promoción:', style: TextStyle(fontWeight: FontWeight.w700),),
                ),
                Expanded(
                  child: Text(promotion["date_init"] + " " + promotion["init_hour"], style: TextStyle(fontSize: 11.0), textAlign: TextAlign.end,),
                )
              ],
            ),
        ),
      ),
    );
  }

  Widget _showDateEnd() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Icon(FontAwesomeIcons.hourglassEnd, size: 18.0, color: primaryColor,),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text('Fecha fin promoción:', style: TextStyle(fontWeight: FontWeight.w700),),
              ),
              Expanded(
                child: Text(promotion["date_end"] + " " + promotion["end_hour"], style: TextStyle(fontSize: 11.0), textAlign: TextAlign.end,),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _showTypePromotion() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Icon(FontAwesomeIcons.productHunt, size: 18.0, color: primaryColor,),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text('Tipo de promoción:', style: TextStyle(fontWeight: FontWeight.w700),),
              ),
              Expanded(
                child: Text(promotion["type_promotion"], style: TextStyle(fontSize: 12.0), textAlign: TextAlign.end,),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _showBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showHeader(),
          _showContent(),
          _showLabelProducts(),
          _showProducts(),
          _showTypePromotion(),
          _showDateInit(),
          _showDateEnd(),
          _acceptBtn(),
          _promotionTerms()
        ],
      ),
    );
  }

  Widget _showHeader() {
    return Container(
      padding: EdgeInsets.all(15.0),
      height: 290.0,
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage( 
        placeholder: (context, url) => SpinKitThreeBounce(color: Color.fromRGBO(148, 3, 123, 1.0), size: 25.0,),
        errorWidget: (context, url, error) => new Icon(Icons.error),
        fit: BoxFit.fitHeight,
        imageUrl: promotion["image_url"].length > 0 ? promotion["image_url"] : 'http://isabelpaz.com/wp-content/themes/nucleare-pro/images/no-image-box.png',
      ),
    );
  }

  Widget _showContent() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Card(
        elevation: 1,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.fastfood, size: 20.0, color: primaryColor,),
                  ),
                  Expanded(
                    child: Text(
                    promotion["promotion_name"],
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Divider(
                color: Colors.grey,
                height: 10.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Text(
                    promotion["description_promotion"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87
                    ),
                    softWrap: true,
                    maxLines: descTextShowFlag ? promotion["description_promotion"].length : 6,
                  ),
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: () { 
                        setState(() {
                          descTextShowFlag = !descTextShowFlag; 
                        }); 
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          descTextShowFlag ? Text("Ver menos",style: TextStyle(color: Colors.blue),) :  Text("Ver mas",style: TextStyle(color: Colors.blue))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
            
          ],
        ),
      ),
    );
  }

  Widget _promotionTerms() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
            child: Text('Terminos y condiciones', style: TextStyle(color: Colors.lightBlue, fontSize: 12.0),),
            onPressed: () => _showTerms(),
          ),
        ),
      ),
    );
  }

  Widget _showLabelProducts() {
    if (promotion["products"] != null && promotion["products"].length > 0) {
      String label = promotion["type_promotion_id"] == "xYERseDSmVllNuaMFUmH" ? 'Obsequio' : 'Productos';
      return Container(
        padding: EdgeInsets.only(left: 20.0),
        child: Text(label, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 17.0),),
      );
    }
    return Container();
  }

  List<Widget> _buildProducts(List products) {
    List<Widget> widgets = [];
    products.forEach((product) {
      widgets.add(
        Card(
          child: ListTile(
            title: Text(product["description"], style: TextStyle(fontSize: 13.0),),
            subtitle: Text('Sección: ${product["section"]}', style: TextStyle(fontSize: 11.0),),
            // trailing: Icon(Icons.more_vert),
          ),
        ),
      );
    });
    return widgets;
  }

  Widget _showProducts() {
    if (["products"] != null && promotion["products"].length > 0) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: _buildProducts(promotion["products"]),
        ),
      );
    }
    return Container();
  }

  Widget _acceptBtn() {
    bool available;
    bool accepted;
    String date = promotion["date_init"];
    String hour = promotion["init_hour"];
    bool status = promotion["status"];
    final dateF = date.split('-');
    int year = int.parse(dateF[0]);
    int month = int.parse(dateF[1]);
    int day = int.parse(dateF[2]);
    final hourF = hour.split(':');
    int hou = int.parse(hourF[0]);
    int min = int.parse(hourF[1]);
    DateTime time = DateTime(
      year,month,day,hou,min
    );
    if(!widget.statusPrm){
      accepted = false;
      if(DateTime.now().isAfter(time)){
        available = true;
      }else{
        available = false;
      }
    }else{
      available = false;
      accepted = true;
    }
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 50.0,
        child: RaisedButton(
          onPressed: available?_openConfirmDialog:(){},
          color: available?Color.fromRGBO(148, 3, 123, 1.0):Colors.grey,
          child: Text(accepted?"Promoción aceptada":'Aceptar Promoción', style: TextStyle(color: Colors.white),),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(title: 'Detalle Promoción',),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: backgroundColor,
        child: Stack(
          children: <Widget>[
            _isLoading || _noDataFound ? Container() : _showBody(),
            _noDataFound ? NoDataFound() : Container(),
            DialogProgress(isLoading: _isLoading,),
          ],
        ),
      ),
    );
  }
}