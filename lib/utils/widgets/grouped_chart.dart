/// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shopkeeper/utils/classes/date.dart';

class GroupedBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GroupedBarChart(this.seriesList, {this.animate});

  factory GroupedBarChart.withSampleData(active, finished) {
    return new GroupedBarChart(
      _createSampleData(active, finished),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalPromotions, String>> _createSampleData(
      List active, List finished) {
    // print('$active $finished');
    final List<OrdinalPromotions> activeData = [];
    final List<OrdinalPromotions> finishedData = [];

    if (active.length > 0) {
      active.forEach((a) {
        String parsedDate = Date.parseDate(a["day"], 'dd');
        activeData.add(new OrdinalPromotions(
            day: parsedDate, quantity: a["active_number"]));
      });
    }

    if (finished.length > 0) {
      finished.forEach((f) {
        String parsedDate = Date.parseDate(f["day"], 'dd');
        finishedData.add(new OrdinalPromotions(
            day: parsedDate, quantity: f["finished_number"]));
      });
    }

    return [
      new charts.Series<OrdinalPromotions, String>(
        id: 'Activas',
        domainFn: (OrdinalPromotions promotions, _) => promotions.day,
        measureFn: (OrdinalPromotions promotions, _) => promotions.quantity,
        data: activeData,
      ),
      new charts.Series<OrdinalPromotions, String>(
        id: 'Finalizadas',
        domainFn: (OrdinalPromotions promotions, _) => promotions.day,
        measureFn: (OrdinalPromotions promotions, _) => promotions.quantity,
        data: finishedData,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class OrdinalPromotions {
  final String day;
  final int quantity;

  OrdinalPromotions({this.day, this.quantity = 0});
}
