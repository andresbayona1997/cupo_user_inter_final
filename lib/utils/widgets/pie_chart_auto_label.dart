import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class PieChartAutoLabel extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  PieChartAutoLabel(this.seriesList, {this.animate});

  factory PieChartAutoLabel.withSampleData(totalActive, totalFinished) {
    return new PieChartAutoLabel(
      _createSampleData(totalActive, totalFinished),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 60,
            arcRendererDecorators: [new charts.ArcLabelDecorator()]));
  }

  static List<charts.Series<LinearPromotions, dynamic>> _createSampleData(
      totalActive, totalFinished) {
    final data = [
      new LinearPromotions(type: "Activas", total: totalActive["total"]),
      new LinearPromotions(type: "Finalizadas", total: totalFinished["total"]),
    ];

    return [
      new charts.Series<LinearPromotions, dynamic>(
        id: 'Sales',
        domainFn: (LinearPromotions promotions, _) => promotions.type,
        measureFn: (LinearPromotions promotions, _) => promotions.total,
        data: data,
        labelAccessorFn: (LinearPromotions row, _) =>
            '${row.type}: ${row.total}',
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class LinearPromotions {
  final String type;
  final int total;

  LinearPromotions({this.type, this.total = 0});
}
