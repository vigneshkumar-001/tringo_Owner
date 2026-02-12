import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tringo_owner/Presentation/Home/Model/shops_response.dart';

class ReachLineChart extends StatelessWidget {
  final HomeChart chart;
  const ReachLineChart({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    final points = chart.series;
    if (points.isEmpty) return const SizedBox(height: 240);

    // Convert API series -> FlSpots (use index as X)
    final spots = <FlSpot>[];
    double maxY = 0;

    for (int i = 0; i < points.length; i++) {
      final y = points[i].value.toDouble();
      spots.add(FlSpot(i.toDouble(), y));
      if (y > maxY) maxY = y;
    }

    // Give some headroom so top dot doesn't touch the edge
    final paddedMaxY = _niceMax(max(maxY, 1));
    final interval = _niceInterval(paddedMaxY);

    // Highlight max point (big dot like your design)
    final maxIndex = _maxIndex(points);

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white12, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length)
                    return const SizedBox.shrink();

                  // show fewer labels if too many points
                  if (points.length > 10 && i % 2 == 1)
                    return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      points[i].label,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: paddedMaxY,

          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((s) {
                  final i = s.x.toInt();
                  final label = (i >= 0 && i < points.length)
                      ? points[i].key
                      : '';
                  return LineTooltipItem(
                    '$label\n${s.y.toInt()}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Colors.blueAccent,
              barWidth: 1.2,

              // ✅ Gradient fill under the line
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blueAccent.withOpacity(0.25), // top (near line)
                    Colors.transparent, // bottom fade
                  ],
                ),
              ),

              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final isMax = index == maxIndex;
                  return FlDotCirclePainter(
                    color: isMax ? Colors.blueAccent : Colors.white54,
                    radius: isMax ? 5 : 2,
                    strokeWidth: 0,
                  );
                },
              ),
            ),

            // LineChartBarData(
            //   spots: spots,
            //   isCurved: false,
            //   color: Colors.blueAccent,
            //   barWidth: 1.2,
            //   belowBarData: BarAreaData(show: false),
            //   dotData: FlDotData(
            //     show: true,
            //     getDotPainter: (spot, percent, barData, index) {
            //       final isMax = index == maxIndex;
            //       return FlDotCirclePainter(
            //         color: isMax ? Colors.blueAccent : Colors.white54,
            //         radius: isMax ? 5 : 2,
            //         strokeWidth: 0,
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  int _maxIndex(List<HomeSeriesPoint> points) {
    var idx = 0;
    var maxVal = -1;
    for (int i = 0; i < points.length; i++) {
      if (points[i].value > maxVal) {
        maxVal = points[i].value;
        idx = i;
      }
    }
    return idx;
  }

  double _niceMax(double v) {
    // make max like 10, 20, 50, 100, 200...
    final pow10 = pow(10, (log(v) / ln10).floor()).toDouble();
    final n = v / pow10;
    double nice;
    if (n <= 1)
      nice = 1;
    else if (n <= 2)
      nice = 2;
    else if (n <= 5)
      nice = 5;
    else
      nice = 10;
    return nice * pow10;
  }

  double _niceInterval(double maxY) {
    // aim ~5-6 horizontal lines
    final raw = maxY / 5;
    return _niceMax(raw);
  }
}
