import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/utils/container.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Dashboard'),
          flexibleSpace: OutsideContainer(child: Column())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: isLargeScreen ? 4 : 2,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
                mainAxisSpacing: 10,
                children: <Widget>[
                  // Information Cards
                  _buildInfoCard(
                      'Total Employees', '120', Icons.people, Colors.blue),
                  _buildInfoCard('Total Salary Paid', '₹5,00,000', Icons.money,
                      Colors.green),
                  _buildInfoCard(
                      'Due Payments', '₹1,20,000', Icons.payment, Colors.red),
                  _buildInfoCard(
                      'Departments', '5', Icons.business, Colors.orange),

                  // Bar Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Jan');
                                    case 1:
                                      return const Text('Feb');
                                    case 2:
                                      return const Text('Mar');
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(toY: 8, color: Colors.blue)
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(toY: 10, color: Colors.green)
                            ]),
                            BarChartGroupData(x: 2, barRods: [
                              BarChartRodData(toY: 14, color: Colors.red)
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Line Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1),
                                FlSpot(1, 1.5),
                                FlSpot(2, 1.4),
                                FlSpot(3, 3.4),
                                FlSpot(4, 2),
                                FlSpot(5, 2.2),
                                FlSpot(6, 1.8),
                              ],
                              isCurved: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                              color: Colors.purple,
                              barWidth: 3,
                            ),
                          ],
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),

                  // Pie Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                                color: Colors.red,
                                value: 40,
                                title: 'Expenses'),
                            PieChartSectionData(
                                color: Colors.green,
                                value: 30,
                                title: 'Income'),
                            PieChartSectionData(
                                color: Colors.blue,
                                value: 30,
                                title: 'Revenue'),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),

                  // Another Bar Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Apr');
                                    case 1:
                                      return const Text('May');
                                    case 2:
                                      return const Text('Jun');
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(toY: 12, color: Colors.blueGrey)
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(toY: 15, color: Colors.teal)
                            ]),
                            BarChartGroupData(x: 2, barRods: [
                              BarChartRodData(toY: 18, color: Colors.indigo)
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create an information card
  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
