import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/daily_record_model.dart';

class OverviewChart extends StatelessWidget {
  final List<DailyRecord> records;
  const OverviewChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    print('OverviewChart: Building with ${records.length} records');
    if (records.isNotEmpty) {
      print('OverviewChart: First record - stress: ${records.first.stressLevel}, sleep: ${records.first.sleepQuality}, energy: ${records.first.energyLevel}');
      print('OverviewChart: Stress spots: ${records.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.stressLevel.toDouble())).toList()}');
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Overview',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            records.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No data available yet.\nStart tracking your stress, sleep, and energy levels!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : records.length == 1
                    ? SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Data for ${DateFormat('MMM dd, yyyy').format(records.first.date)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _DataPointWidget(label: 'Stress', value: records.first.stressLevel, color: Colors.red),
                                  _DataPointWidget(label: 'Sleep', value: records.first.sleepQuality * 5.0, color: Colors.blue),
                                  _DataPointWidget(label: 'Energy', value: records.first.energyLevel * 5.0, color: Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 200,
                        child: LineChart(
                LineChartData(
                  lineBarsData: [
                    // Stress line
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                          e.key.toDouble(),
                          e.value.stressLevel.toDouble(),
                        ),
                      )
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),

                    // Sleep line (scaled to 0–10)
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                          e.key.toDouble(),
                          e.value.sleepQuality * 5,
                        ),
                      )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),

                    // Energy line (scaled to 0–10)
                    LineChartBarData(
                      spots: records
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                          e.key.toDouble(),
                          e.value.energyLevel * 5,
                        ),
                      )
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < records.length) {
                            final date = records[value.toInt()].date;
                            return Text(DateFormat.E().format(date));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  maxY: 10,
                  minX: 0,
                  maxX: records.isEmpty ? 1 : (records.length - 1).toDouble(),
                  baselineY: 0,
                ),
                    ),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _LegendItem(color: Colors.red, label: 'Stress'),
                _LegendItem(color: Colors.blue, label: 'Sleep'),
                _LegendItem(color: Colors.green, label: 'Energy'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _DataPointWidget extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _DataPointWidget({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
