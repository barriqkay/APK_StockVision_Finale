import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';

/// ==========================================
/// Stock Price Chart Widget
/// ==========================================
class StockChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> dates;
  final bool showDates;
  final double minX, maxX, minY, maxY;
  final String title;

  const StockChart({
    Key? key,
    required this.spots,
    required this.dates,
    this.showDates = true,
    this.minX = 0,
    this.maxX = 6,
    this.minY = 0,
    this.maxY = 100,
    this.title = 'Price Chart',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return _buildEmptyChart();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Icon(Icons.show_chart, color: AppColors.primary, size: 20),
            SizedBox(width: AppSpacing.xs),
            Text(title, style: AppTextStyles.titleMedium),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        
        // Chart
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: AppShadows.small,
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: _calculateInterval(minY, maxY),
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: ChartColors.gridColor,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: ChartColors.gridColor,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showDates,
                    reservedSize: 32,
                    interval: (maxX / 4).clamp(1.0, double.infinity),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < dates.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            dates[index],
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textLight,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: _calculateInterval(minY, maxY),
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          _formatPrice(value),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: ChartColors.lineColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: ChartColors.lineColor,
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ChartColors.fillColor,
                        ChartColors.fillColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: AppColors.textPrimary.withOpacity(0.9),
                  tooltipRoundedRadius: AppRadius.medium,
                  tooltipPadding: EdgeInsets.all(AppSpacing.sm),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${_formatPrice(spot.y)}\n${dates.isNotEmpty && spot.x.toInt() < dates.length ? dates[spot.x.toInt()] : ''}',
                        TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList();
                  },
                ),
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  // Handle touch events
                },
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.small,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: AppColors.textLight),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada data untuk ditampilkan',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateInterval(double min, double max) {
    final range = max - min;
    if (range <= 0) return 10;
    return (range / 4).clamp(1.0, double.infinity);
  }

  String _formatPrice(double value) {
    if (value >= 1000000) {
      return 'Rp${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'Rp${(value / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp${value.toStringAsFixed(0)}';
  }
}

/// ==========================================
/// OHLCV Chart (Candlestick)
/// ==========================================
class CandlestickChart extends StatelessWidget {
  final List<Map<String, dynamic>> ohlcvData;
  final String title;

  const CandlestickChart({
    Key? key,
    required this.ohlcvData,
    this.title = 'Candlestick Chart',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ohlcvData.isEmpty) {
      return _buildEmptyChart();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.candlestick_chart, color: AppColors.primary, size: 20),
            SizedBox(width: AppSpacing.xs),
            Text(title, style: AppTextStyles.titleMedium),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: AppShadows.small,
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ohlcvData.length,
            itemBuilder: (context, index) {
              final data = ohlcvData[index];
              final isBullish = (data['close'] ?? 0) >= (data['open'] ?? 0);
              
              return _buildCandlestick(data, isBullish, index == ohlcvData.length - 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCandlestick(Map<String, dynamic> data, bool isBullish, bool isLast) {
    final open = (data['open'] ?? 0).toDouble();
    final close = (data['close'] ?? 0).toDouble();
    final high = (data['high'] ?? 0).toDouble();
    final low = (data['low'] ?? 0).toDouble();
    
    final maxPrice = high;
    final minPrice = low;
    final priceRange = maxPrice - minPrice;
    final chartHeight = 200.0;
    
    final bodyTop = chartHeight - ((close - minPrice) / priceRange * chartHeight);
    final bodyBottom = chartHeight - ((open - minPrice) / priceRange * chartHeight);
    final bodyHeight = (bodyBottom - bodyTop).abs().clamp(2.0, double.infinity);
    final bodyY = (bodyTop + bodyBottom) / 2;
    
    final wickTop = chartHeight - ((high - minPrice) / priceRange * chartHeight);
    final wickBottom = chartHeight - ((low - minPrice) / priceRange * chartHeight);
    
    final color = isBullish ? AppColors.bullish : AppColors.bearish;

    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              SizedBox(
                height: chartHeight,
                child: Stack(
                  children: [
                    // Wick
                    Positioned(
                      left: 13,
                      top: wickTop,
                      child: Container(
                        width: 2,
                        height: wickBottom - wickTop,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                    // Body
                    Positioned(
                      left: 10,
                      top: bodyY - bodyHeight / 2,
                      child: Container(
                        width: 8,
                        height: bodyHeight,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                data['date']?.toString().substring(0, 5) ?? '',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
        if (!isLast) SizedBox(width: 4),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.small,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.candlestick_chart, size: 48, color: AppColors.textLight),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada data OHLCV',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// Mini Sparkline Chart
/// ==========================================
class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const SparklineChart({
    Key? key,
    required this.values,
    this.color = AppColors.primary,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: height);
    }

    final spots = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range * 0.1;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: minY - padding,
          maxY: maxY + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// Chart Data Helper
/// ==========================================
class ChartDataHelper {
  static List<FlSpot> createSpots(List<Map<String, dynamic>> data, String priceKey) {
    return data.asMap().entries.map((entry) {
      final value = (entry.value[priceKey] ?? 0).toDouble();
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  static List<String> extractDates(List<Map<String, dynamic>> data) {
    return data.map((item) {
      final dateStr = item['date']?.toString() ?? '';
      if (dateStr.length >= 10) {
        return dateStr.substring(5); // MM-DD format
      }
      return dateStr;
    }).toList();
  }

  static double calculateMinY(List<FlSpot> spots, {double padding = 0.1}) {
    if (spots.isEmpty) return 0;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    return minY * (1 - padding);
  }

  static double calculateMaxY(List<FlSpot> spots, {double padding = 0.1}) {
    if (spots.isEmpty) return 100;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return maxY * (1 + padding);
  }
}

