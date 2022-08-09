import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final totalActive;
  final totalFinished;

  PieChart(this.seriesList, {this.animate, this.totalActive, this.totalFinished});

  factory PieChart.withSampleData() {
    return new PieChart(
      _createSampleData(),
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(
        arcRendererDecorators: [
          new charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.outside
          )
        ]
      )
    );
  }

  static List<charts.Series<LinearPromotions, dynamic>> _createSampleData() {
    final data = [];

    // data.addAll([
    //   LinearPromotions(this.totalActive["label"], this.totalActive["total"]),
    //   LinearPromotions(this.totalFinished["label"], this.totalFinished["total"]),
    // ]);

    return [
      new charts.Series<LinearPromotions, dynamic>(
        id: 'Promotions',
        domainFn: (LinearPromotions promotions, _) => promotions.type,
        measureFn: (LinearPromotions promotions, _) => promotions.total,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearPromotions row, _) => '${row.type}: ${row.total.toString()}',
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

  LinearPromotions(this.type, this.total);
}