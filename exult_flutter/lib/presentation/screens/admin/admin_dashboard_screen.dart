import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:exult_flutter/presentation/providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _selectedPeriod = 'This Month';

  void _selectPeriod(String period) {
    final now = DateTime.now();
    DateRange range;

    switch (period) {
      case 'Today':
        range = DateRange(
            start: DateTime(now.year, now.month, now.day), end: now);
        break;
      case 'This Week':
        // Start of Monday
        final weekday = now.weekday; // 1=Monday
        final monday = now.subtract(Duration(days: weekday - 1));
        range = DateRange(
            start: DateTime(monday.year, monday.month, monday.day), end: now);
        break;
      case 'This Month':
        range = DateRange(
            start: DateTime(now.year, now.month, 1), end: now);
        break;
      case 'This Quarter':
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        range = DateRange(
            start: DateTime(now.year, quarterStartMonth, 1), end: now);
        break;
      case 'This Year':
        range = DateRange(
            start: DateTime(now.year, 1, 1), end: now);
        break;
      default:
        return;
    }

    setState(() => _selectedPeriod = period);
    ref.read(dashboardDateRangeProvider.notifier).state = range;
  }

  Future<void> _selectCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );

    if (picked != null) {
      setState(() => _selectedPeriod = 'Custom');
      ref.read(dashboardDateRangeProvider.notifier).state = DateRange(
        start: picked.start,
        end: picked.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Date range filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Period:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 12),
                ...[
                  'Today',
                  'This Week',
                  'This Month',
                  'This Quarter',
                  'This Year',
                ].map((period) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(period, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        selected: _selectedPeriod == period,
                        onSelected: (_) => _selectPeriod(period),
                      ),
                    )),
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 19),
                  label: Text(
                      _selectedPeriod == 'Custom' ? 'Custom*' : 'Custom',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  onPressed: _selectCustomRange,
                ),
              ],
            ),
          ),

          // Charts area
          Expanded(
            child: metricsAsync.when(
              data: (metrics) {
                final dateRange = ref.watch(dashboardDateRangeProvider);
                final dateFormat = DateFormat('d MMM yyyy');
                final rangeLabel =
                    '${dateFormat.format(dateRange.start)} – ${dateFormat.format(dateRange.end)}';

                return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        // Date range label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              rangeLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        // Summary cards row
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Total Books Lent',
                                currentValue: metrics.totalBooksLent,
                                previousValue: metrics.previousBooksLent,
                                changePercent: metrics.booksLentChange,
                                icon: Icons.book,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MetricCard(
                                title: 'Books Under Management',
                                currentValue:
                                    metrics.totalBooksUnderManagement,
                                previousValue:
                                    metrics.previousBooksUnderManagement,
                                changePercent:
                                    metrics.booksManagementChange,
                                icon: Icons.inventory_2,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MetricCard(
                                title: 'Total Subscribers',
                                currentValue:
                                    metrics.totalActiveSubscribers,
                                previousValue:
                                    metrics.previousActiveSubscribers,
                                changePercent: metrics.subscribersChange,
                                icon: Icons.people,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Charts row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ChartCard(
                                title: 'Books Lent',
                                currentValue: metrics.totalBooksLent,
                                previousValue: metrics.previousBooksLent,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ChartCard(
                                title: 'Books Under Management',
                                currentValue:
                                    metrics.totalBooksUnderManagement,
                                previousValue:
                                    metrics.previousBooksUnderManagement,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ChartCard(
                                title: 'Subscribers',
                                currentValue:
                                    metrics.totalActiveSubscribers,
                                previousValue:
                                    metrics.previousActiveSubscribers,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading dashboard: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int currentValue;
  final int previousValue;
  final double changePercent;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.currentValue,
    required this.previousValue,
    required this.changePercent,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 14,
                        color: isPositive
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${changePercent.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPositive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$currentValue',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Previous period: $previousValue',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final int currentValue;
  final int previousValue;
  final Color color;

  const _ChartCard({
    required this.title,
    required this.currentValue,
    required this.previousValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxY =
        ([currentValue, previousValue].reduce((a, b) => a > b ? a : b) * 1.3)
            .clamp(1, double.infinity)
            .toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = groupIndex == 0
                            ? 'Previous'
                            : 'Current';
                        return BarTooltipItem(
                          '$label\n${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Previous',
                                  style: TextStyle(fontSize: 11));
                            case 1:
                              return const Text('Current',
                                  style: TextStyle(fontSize: 11));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                  ),
                  groupsSpace: 40,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: previousValue.toDouble(),
                          color: color.withOpacity(0.4),
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: currentValue.toDouble(),
                          color: color,
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
