import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopkeeper/utils/classes/date.dart';
import 'package:shopkeeper/utils/widgets/dialog_progress.dart';
import 'package:shopkeeper/utils/widgets/nav_bar.dart';
import 'package:shopkeeper/services/status_service.dart';
import 'package:shopkeeper/utils/widgets/status.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:shopkeeper/services/chart_service.dart';
import 'package:shopkeeper/utils/widgets/pie_chart_auto_label.dart';
import 'package:shopkeeper/utils/widgets/grouped_chart.dart';
import 'package:intl/intl.dart';
import 'package:shopkeeper/utils/widgets/list_providers.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StatusService _statusService = new StatusService();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ChartService _chartService = new ChartService();
  bool _validated = false;
  bool _isLoading = true;
  DateTime selectedDate = DateTime.now();
  TextEditingController _selectedDate = new TextEditingController(text: null);
  Map chartsData = {
    "active_promotions": [],
    "finished_promotions": [],
    "total_active": {"label": "active", "total": 0},
    "total_finished": {"label": "finished", "total": 0}
  };
  bool _renderCharts = true;
  Map _providers = {};
  String typeSelected = "active_promotions_providers";
  final formatCurrency = new NumberFormat.simpleCurrency();
  List selectedProviders = [];
  List _types = [
    {"label": "Activas", "value": "active_promotions_providers "},
    {"label": "Finalizadas", "value": "finished_promotions_providers "},
  ];

  @override
  void initState() {
    super.initState();
    _statusService.shoopkeeperValidated().then((val) {
      print(val);
      if (mounted)
        setState(() {
          _validated = val;
          _isLoading = false;
        });
    });
  }

  void getChartsData() {
    if (_selectedDate.text != null && _selectedDate.text.isNotEmpty) {
      setState(() => _isLoading = true);
      FocusScope.of(context).requestFocus(FocusNode());
      _chartService.getChartsData(_selectedDate.text).then((result) {
        print('Result => $result');
        setState(() => _isLoading = false);
        if (result["status"] != 400 && result["data"] != null) {
          // print(result["data"]);
          setState(() {
            chartsData = result["data"];
            _renderCharts = true;
          });
          _chartService.getSales(_selectedDate.text).then((res) {
            if (res["data"] != null) {
              setState(() {
                _providers = res["data"];
                selectedProviders = res["data"]["active_promotions_providers"];
              });
              print(res);
            }
          }).catchError((error) {
            print(error);
          });
        } else {
          _showSnackbar('No se han encontrado estadisticas');
        }
      }).catchError((onError) {
        setState(() => _isLoading = false);
        print(onError);
      });
    }
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

  Widget _showPop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text('Filtrar'),
        Align(
          alignment: Alignment.centerRight,
          child: _showPopup(),
        ),
      ],
    );
  }

  Widget _showBody() {
    return Container(
      child: ListView(
        padding: EdgeInsets.all(15.0),
        children: <Widget>[
          _showSelectedDate(),
          _renderCharts ? _showConventions() : Container(),
          _renderCharts ? _showGroupedChart() : Container(),
          _renderCharts ? _showPieChart() : Container(),
          _renderCharts ? _showPop() : Container(),
          _renderCharts
              ? ListProviders(
                  providers: selectedProviders,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showConventions() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Promociones Activas',
                    style: TextStyle(color: Colors.grey, fontSize: 11.0),
                  )),
              Container(
                width: 15,
                height: 15,
                decoration: painting.BoxDecoration(
                  shape: painting.BoxShape.rectangle,
                  color: Colors.blueAccent,
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      'Promociones Finalizadas',
                      style: TextStyle(color: Colors.grey, fontSize: 11.0),
                    )),
                Container(
                  width: 15,
                  height: 15,
                  decoration: painting.BoxDecoration(
                    shape: painting.BoxShape.rectangle,
                    color: Colors.greenAccent,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _showGroupedChart() {
    return Container(
      height: 300,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Align(
              alignment: painting.Alignment.centerLeft,
              child: Text(
                'Promociones activas/finalizadas por día',
                style: painting.TextStyle(
                    fontWeight: painting.FontWeight.w700, fontSize: 14.0),
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 2.0,
              child: Container(
                padding: EdgeInsets.all(15.0),
                child: GroupedBarChart.withSampleData(
                    chartsData["active_promotions"],
                    chartsData["finished_promotions"]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _showPieChart() {
    return Container(
      height: 320,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Align(
              alignment: painting.Alignment.centerLeft,
              child: Text(
                'Consolidado total',
                style: painting.TextStyle(
                    fontWeight: painting.FontWeight.w700, fontSize: 14.0),
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 2.0,
              child: Container(
                padding: EdgeInsets.all(15.0),
                child: chartsData["total_active"]["total"] > 0 ||
                        chartsData["total_finished"]["total"] > 0
                    ? PieChartAutoLabel.withSampleData(
                        chartsData["total_active"],
                        chartsData["total_finished"])
                    : Center(
                        child: Text('No hay información'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap() {
    FocusScope.of(context).requestFocus(new FocusNode());
    DateTime now = DateTime.now();
    DatePicker.showDatePicker(
      context,
      maxTime: now,
      minTime: DateTime(2015, now.month, now.day - 30),
      currentTime: DateTime.now(),
      locale: LocaleType.es,
      onConfirm: (DateTime date) {
        print(date);
        String formattedDate = Date.formatDate(date, "yyyy-MM-dd'");
        _selectedDate.text = formattedDate;
        getChartsData();
      },
      showTitleActions: true,
      theme: DatePickerTheme(
          cancelStyle: TextStyle(
              fontFamily: 'Raleway', color: Colors.red, fontSize: 12.0),
          doneStyle: TextStyle(fontFamily: 'Raleway', fontSize: 12.0)),
    );
  }

  Widget _showSelectedDate() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          TextField(
            enableInteractiveSelection: false,
            onTap: _onTap,
            controller: _selectedDate,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(8.0),
                ),
              ),
              prefixIcon: Icon(FontAwesomeIcons.calendar, size: 15.0),
              labelText: "Seleccione la fecha",
              labelStyle: TextStyle(fontSize: 12.0),
              errorStyle: TextStyle(fontSize: 10.0, color: Colors.redAccent),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Divider(color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _showPopup() {
    return PopupMenuButton(
        onSelected: (result) {
          print(result);
          if (_providers.length > 0) {
            setState(() {
              selectedProviders = _providers[result];
            });
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: "active_promotions_providers",
                child: Text('Activas'),
              ),
              const PopupMenuItem(
                value: "finished_promotions_providers",
                child: Text('Finalizadas'),
              ),
            ]);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: NavBar(
          title: 'Dashboard',
        ),
        body: Stack(
          children: <Widget>[
            _validated ? _showBody() : _isLoading ? Container() : Status(),
            DialogProgress(
              isLoading: _isLoading,
            )
          ],
        ));
  }
}
