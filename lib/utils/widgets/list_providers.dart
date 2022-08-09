import 'package:flutter/material.dart';
import 'package:shopkeeper/utils/options.dart';
import 'package:intl/intl.dart';

class ListProviders extends StatelessWidget {
  final List providers;
  final formatCurrency = new NumberFormat.simpleCurrency();
  ListProviders({this.providers});

  List<Widget> _buildCards() {
    List<Widget> providers = [];
    this.providers.forEach((provider) {
      providers.add(Container(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    provider["name"],
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17.0),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    '${formatCurrency.format(provider["debt"])}',
                    style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    });
    return providers;
  }

  Widget noProviders() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Center(
        child: Text('No se encontraron datos'),
      ),
    );
  }

  Widget _showList() {
    return ListView(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      children: _buildCards(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Proveedores',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.0),
              ),
            ),
          ),
          providers.length > 0 ? _showList() : noProviders(),
        ],
      ),
    );
  }
}
