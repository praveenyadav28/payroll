import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/ui/home/details/advance.dart';
import 'package:payroll/ui/home/details/due_list.dart';
import 'package:payroll/ui/home/master/staff/staff_view.dart';
import 'package:payroll/utils/container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List branchList = [];
  List staffList = [];
  double dueAmount = 0;
  double advanceAmount = 0;
  double paidAmount = 0;
  @override
  void initState() {
    super.initState();
    fetchBranches().then((value) => setState(() {}));
    fetchPaid().then((value) => setState(() {}));
    fetchDue().then((value) => setState(() {}));
    fetchAdvance().then((value) => setState(() {}));
    fetchStaff().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Dashboard'),
          flexibleSpace: const OutsideContainer(child: Column())),
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
                  _buildInfoCard('Total Employees', '${staffList.length}',
                      Icons.people, Colors.blue, onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StaffViewScreen(staffListType: true)));
                  }),
                  _buildInfoCard('Total Salary Paid', '₹ $paidAmount',
                      Icons.money, Colors.green, onTap: () {
                    Navigator.pushReplacementNamed(context, '/paymentView');
                  }),
                  _buildInfoCard(
                      'Due Payments', '₹ $dueAmount', Icons.payment, Colors.red,
                      onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DueScreen()));
                  }),
                  _buildInfoCard(
                      'Advance Payments',
                      '₹ $advanceAmount',
                      Icons.payments,
                      const Color.fromARGB(255, 76, 163, 175), onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdvanceScreen()));
                  }),
                  _buildInfoCard('Departments', '${branchList.length}',
                      Icons.business, Colors.orange, onTap: () {
                    Navigator.pushReplacementNamed(context, '/branchView');
                  }),

                  // Bar Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 800,
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
                                        case 7:
                                          return const Text('Aug');
                                        case 8:
                                          return const Text('Sep');
                                        case 9:
                                          return const Text('Oct');
                                        case 10:
                                          return const Text('Nov');
                                        default:
                                          return const Text('Dec');
                                      }
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
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
                                BarChartGroupData(x: 7, barRods: [
                                  BarChartRodData(toY: 14, color: Colors.purple)
                                ]),
                                BarChartGroupData(x: 8, barRods: [
                                  BarChartRodData(
                                      toY: 14, color: Colors.orangeAccent)
                                ]),
                                BarChartGroupData(x: 9, barRods: [
                                  BarChartRodData(
                                      toY: 14, color: Colors.blueGrey)
                                ]),
                                BarChartGroupData(x: 10, barRods: [
                                  BarChartRodData(
                                      toY: 14, color: Colors.pinkAccent)
                                ]),
                                BarChartGroupData(x: 11, barRods: [
                                  BarChartRodData(toY: 14, color: Colors.red)
                                ]),
                              ],
                            ),
                          ),
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
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                              color: Colors.purple,
                              barWidth: 3,
                            ),
                          ],
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),

                  // Pie Chart
                  advanceAmount == 0 && dueAmount == 0 && paidAmount == 0
                      ? Container()
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                      color: Colors.red,
                                      value: dueAmount,
                                      title: 'Due'),
                                  PieChartSectionData(
                                      color: Colors.green,
                                      value: paidAmount,
                                      title: 'Paid'),
                                  PieChartSectionData(
                                      color: Colors.blue,
                                      value: advanceAmount,
                                      title: 'Advance'),
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
  Widget _buildInfoCard(String title, String value, IconData icon, Color color,
      {required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 37, color: color),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // Fetch branches from API
  Future fetchBranches() async {
    branchList = await ApiService.fetchData('MasterPayroll/GetBranchPayroll');
  }

  // Fetch Due
  Future fetchDue() async {
    var response = await ApiService.fetchData(
        'TransactionsPayroll/GetDueSalaryAmountWithSTAFFPayroll?varlocationid=${Preference.getString(PrefKeys.locationId)}&dateto=${DateFormat('yyyy/MM/dd').format(DateTime.now())}');
    final List<dynamic> staffList = response['due'];

    double totalDue = 0;
    for (var staff in staffList) {
      totalDue += double.parse(staff['dueAmount']);
    }

    setState(() {
      dueAmount = totalDue;
    });
  }

  // Fetch advance
  Future fetchAdvance() async {
    var response = await ApiService.fetchData(
        'TransactionsPayroll/GetAdvanceSalaryAmountWithSTAFFPayroll?varlocationid=${Preference.getString(PrefKeys.locationId)}&dateto=${DateFormat('yyyy/MM/dd').format(DateTime.now())}');
    final List<dynamic> staffList = response['due'];

    double totalDue = 0;
    for (var staff in staffList) {
      double dueAmount = double.parse(staff['dueAmount']);
      totalDue += dueAmount.abs();
    }

    setState(() {
      advanceAmount = totalDue;
    });
  }

  // Fetch advance
  Future fetchPaid() async {
    var response = await ApiService.fetchData(
        'TransactionsPayroll/GetTOTALPAIDSalaryAmountPayroll?varlocationid=${Preference.getString(PrefKeys.locationId)}&dateto=${DateFormat('yyyy/MM/dd').format(DateTime.now())}');
    paidAmount = double.parse(response.toString());
  }

  // Fetch branches from API
  Future fetchStaff() async {
    staffList = await ApiService.fetchData(
        'MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=${Preference.getString(PrefKeys.locationId)}');
  }
}
