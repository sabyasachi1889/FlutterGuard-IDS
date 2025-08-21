import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TrafficChart extends StatefulWidget {
  final List<Map<String, dynamic>> trafficData;
  final bool isMonitoring;

  const TrafficChart({
    super.key,
    required this.trafficData,
    required this.isMonitoring,
  });

  @override
  State<TrafficChart> createState() => _TrafficChartState();
}

class _TrafficChartState extends State<TrafficChart> {
  bool _showTooltip = false;
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Network Traffic',
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
            const Spacer(),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                    color: widget.isMonitoring
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(widget.isMonitoring ? 'Live' : 'Paused',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: widget.isMonitoring ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600))),
          ]),
          SizedBox(height: 3.h),
          SizedBox(
              height: 25.h,
              child: widget.trafficData.isNotEmpty
                  ? LineChart(LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.2),
                                strokeWidth: 1);
                          }),
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() <
                                        widget.trafficData.length) {
                                      final time =
                                          widget.trafficData[value.toInt()]
                                              ['time'] as String;
                                      return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(time,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: colorScheme
                                                          .onSurface
                                                          .withValues(
                                                              alpha: 0.6))));
                                    }
                                    return const Text('');
                                  })),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text('${value.toInt()}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    color: colorScheme.onSurface
                                                        .withValues(
                                                            alpha: 0.6))));
                                  }))),
                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.2))),
                      minX: 0,
                      maxX: (widget.trafficData.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                            spots:
                                widget.trafficData.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(),
                                  (entry.value['packets'] as num).toDouble());
                            }).toList(),
                            isCurved: true,
                            gradient: LinearGradient(colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.3),
                            ]),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                                show: _showTooltip,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                      radius: index == _touchedIndex ? 6 : 4,
                                      color: colorScheme.primary,
                                      strokeWidth: 2,
                                      strokeColor: colorScheme.surface);
                                }),
                            belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      colorScheme.primary
                                          .withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter))),
                      ],
                      lineTouchData: LineTouchData(
                          enabled: true,
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? touchResponse) {
                            setState(() {
                              if (touchResponse != null &&
                                  touchResponse.lineBarSpots != null) {
                                _showTooltip = true;
                                _touchedIndex =
                                    touchResponse.lineBarSpots!.first.spotIndex;
                              } else {
                                _showTooltip = false;
                                _touchedIndex = -1;
                              }
                            });
                          },
                          touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  return LineTooltipItem(
                                      '${barSpot.y.toInt()} packets',
                                      TextStyle(
                                          color: colorScheme.onInverseSurface,
                                          fontWeight: FontWeight.bold));
                                }).toList();
                              }))))
                  : Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          CustomIconWidget(
                              iconName: 'show_chart',
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.3),
                              size: 48),
                          SizedBox(height: 2.h),
                          Text('No traffic data available',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5))),
                        ]))),
        ]));
  }
}
