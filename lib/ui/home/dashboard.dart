import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/utils/container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
                  _buildInfoCard('Advance Payments', '₹10,000', Icons.payments,
                      const Color.fromARGB(255, 76, 163, 175)),
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
                                    case 3:
                                      return const Text('Apr');
                                    case 4:
                                      return const Text('May');
                                    case 5:
                                      return const Text('Jun');
                                    case 6:
                                      return const Text('Jul');
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
                            BarChartGroupData(x: 3, barRods: [
                              BarChartRodData(toY: 14, color: Colors.purple)
                            ]),
                            BarChartGroupData(x: 4, barRods: [
                              BarChartRodData(toY: 14, color: Colors.yellow)
                            ]),
                            BarChartGroupData(x: 5, barRods: [
                              BarChartRodData(toY: 14, color: Colors.orange)
                            ]),
                            BarChartGroupData(x: 6, barRods: [
                              BarChartRodData(toY: 14, color: Colors.green)
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
