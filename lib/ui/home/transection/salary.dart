// screens/salary_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/ui/home/transection/controller.dart';
import 'package:payroll/ui/home/transection/payment.dart';
import 'package:payroll/ui/home/transection/salaryModel.dart';
import 'package:payroll/utils/api.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/textformfield.dart';
import 'package:table_calendar/table_calendar.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  TextEditingController yearController = TextEditingController();

  late ApiSalary apiService;
  Map<String, dynamic>? workingHoursData;
  List<DateTime> selectedDates = [];
  DateTime focusedDay = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<String> selectedPublicHolidays = [];
  String selectedMonth = 'January';

  @override
  void initState() {
    super.initState();
    apiService = ApiSalary();
    yearController.text = "${DateTime.now().year}";
    fetchData();
  }

  final Map<String, int> monthDays = {
    'January': 31,
    'February': 28,
    'March': 31,
    'April': 30,
    'May': 31,
    'June': 30,
    'July': 31,
    'August': 31,
    'September': 30,
    'October': 31,
    'November': 30,
    'December': 31,
  };

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  void fetchData() async {
    try {
      List<Employee> employees = await apiService.fetchEmployees();
      int year = int.parse(yearController.text.toString());
      int daysInMonth = (selectedMonth == 'February' && isLeapYear(year))
          ? 29
          : monthDays[selectedMonth]!;

      String fromDate =
          '$year-${monthDays.keys.toList().indexOf(selectedMonth) + 1}-01';
      String toDate =
          '$year-${monthDays.keys.toList().indexOf(selectedMonth) + 1}-$daysInMonth';

      List<DeviceLog> logs = await apiService.fetchLogs(fromDate, toDate);
      WorkingHoursCalculator calculator = WorkingHoursCalculator();
      Map<String, dynamic> data = calculator.calculate(
        employees,
        logs,
        selectedPublicHolidays,
        daysInMonth,
        int.parse(yearController.text.toString()),
        selectedMonth == 'January'
            ? 1
            : selectedMonth == 'February'
                ? 2
                : selectedMonth == 'March'
                    ? 3
                    : selectedMonth == 'April'
                        ? 4
                        : selectedMonth == 'May'
                            ? 5
                            : selectedMonth == 'June'
                                ? 6
                                : selectedMonth == 'July'
                                    ? 7
                                    : selectedMonth == 'August'
                                        ? 8
                                        : selectedMonth == 'September'
                                            ? 9
                                            : selectedMonth == 'October'
                                                ? 10
                                                : selectedMonth == 'November'
                                                    ? 11
                                                    : 12,
      );

      setState(() {
        workingHoursData = data;
      });
    } catch (e) {
      _showErrorDialog('Failed to load data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Salary Voucher'),
        flexibleSpace: const OutsideContainer(child: Column()),
        centerTitle: true,
      ),
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: Sizes.width * 0.02, vertical: Sizes.height * 0.02),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(1920, 1, 1),
                          lastDay: DateTime.utc(2330, 12, 31),
                          weekendDays: const [DateTime.sunday],
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) {
                            return selectedDates.contains(day);
                          },
                          onDaySelected: (selectedDay, newFocusedDay) {
                            setState(() {
                              focusedDay = newFocusedDay;

                              if (selectedDates.contains(selectedDay)) {
                                selectedDates.remove(selectedDay);
                                selectedPublicHolidays
                                    .remove(formatter.format(selectedDay));
                              } else {
                                selectedDates.add(selectedDay);
                                selectedPublicHolidays
                                    .add(formatter.format(selectedDay));
                              }
                            });
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide()),
                            ),
                            titleTextStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          calendarStyle: const CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xff4EB1C6),
                                    Color(0xff56C891)
                                  ]),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(color: Colors.black),
                            weekendTextStyle:
                                TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                      SizedBox(height: Sizes.height * 0.02),
                      ElevatedButton(
                          child: const Text("Clear public holidays"),
                          onPressed: () {
                            setState(() {
                              selectedDates.clear();
                              selectedPublicHolidays.clear();
                            });
                          }),
                    ],
                  ),
                ),
                SizedBox(width: Sizes.width * 0.02),
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: Sizes.height * .25,
                            child: Image.asset('assets/images/payment.jpg')),
                        Row(
                          children: [
                            Expanded(
                                child: CommonTextFormField(
                              controller: yearController,
                              labelText: "Year",
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                              child: dropdownTextfield(
                                  context,
                                  "Select Month",
                                  DropdownButton<String>(
                                    underline: Container(),
                                    isExpanded: true,
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_outlined),
                                    value: selectedMonth,
                                    items: monthDays.keys.map((String month) {
                                      return DropdownMenuItem<String>(
                                        value: month,
                                        child: Text(month),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMonth = value!;
                                      });
                                    },
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(height: Sizes.height * 0.02),
                        CustomButton(
                            width: double.infinity,
                            height: 50,
                            text: "Submit",
                            press: () {
                              setState(() {
                                fetchData();
                              });
                            })
                      ],
                    )),
              ],
            ),
            SizedBox(height: Sizes.height * 0.02),
            workingHoursData == null
                ? Container()
                : Container(
                    alignment: Alignment.topCenter,
                    width: Sizes.width * 1,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        border: Border.all(
                          color: const Color(0xff377785),
                        ),
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff4EB1C6), Color(0xff56C891)])),
                    child: Center(
                        child: Text(
                      "Salary List",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColor.black,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
            workingHoursData == null
                ? Container()
                : SizedBox(
                    width: Sizes.width * 1,
                    child: Table(
                      border: TableBorder.all(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          color: const Color(0xff377785)),
                      children: [
                        TableRow(children: [
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text(
                                "Name",
                                style: TextStyle(
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold),
                              ))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text("Working Days",
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold)))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text('Absent Days',
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold)))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text("Half Days",
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold)))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text("Monthly Salary",
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold)))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text("Payable Amount",
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold)))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text("Action",
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold)))),
                        ]),
                        ...List.generate(workingHoursData!.length, (index) {
                          String employeeCode =
                              workingHoursData!.keys.elementAt(index);
                          var employeeData = workingHoursData![employeeCode];

                          return TableRow(children: [
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: Center(
                                    child: Text(employeeData['name'],
                                        style:
                                            TextStyle(color: AppColor.black)))),
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: Center(
                                    child: Text(
                                        "${employeeData['workingDays']}",
                                        style:
                                            TextStyle(color: AppColor.black)))),
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: Center(
                                    child: Text("${employeeData['absentDays']}",
                                        style:
                                            TextStyle(color: AppColor.black)))),
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: Center(
                                    child: Text("${employeeData['halfDays']}",
                                        style:
                                            TextStyle(color: AppColor.black)))),
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: Center(
                                    child: Text(
                                        "₹${employeeData['monthlySalary'].toStringAsFixed(2)}",
                                        style:
                                            TextStyle(color: AppColor.black)))),
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: Center(
                                    child: Text(
                                        "₹${employeeData['dueSalary'].toStringAsFixed(2)}",
                                        style:
                                            TextStyle(color: AppColor.black)))),
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.visibility,
                                          color: AppColor.primery),
                                      onPressed: () {
                                        showActivityLog(
                                            employeeData['dailyPunchLogInfo'],
                                            employeeData[
                                                'employeeWorkingHours']);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.payment,
                                          color: AppColor.black),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                                paymentVoucherNo: 0,
                                                employeeData: employeeData),
                                          ),
                                        );
                                        // Handle edit action
                                      },
                                    ),
                                  ],
                                )),
                          ]);
                        })
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }

  void showActivityLog(
      Map<String, List<DeviceLog>> dailyPunchLogInfo, double workingHours) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Activity Log'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.spaceBetween,
              children: [
                ...List.generate(
                  dailyPunchLogInfo.keys.length,
                  (index) {
                    String date = dailyPunchLogInfo.keys.elementAt(index);
                    List<DeviceLog> logs = dailyPunchLogInfo[date] ?? [];

                    // Calculate working hour difference
                    String workingHoursDiff = "No data";
                    double workingHoursStatus = 0;
                    if (logs.isNotEmpty) {
                      if (logs.length == 1) {
                        // Only one punch, assume 8 hours as in the calculation logic
                        workingHoursDiff = "Unknown";
                      } else {
                        // Calculate the difference between first and last punch
                        DateTime firstPunch = logs.first.punchTime;
                        DateTime lastPunch = logs.last.punchTime;
                        Duration duration = lastPunch.difference(firstPunch);
                        double hoursWorked =
                            duration.inHours + (duration.inMinutes % 60) / 60.0;
                        workingHoursStatus = hoursWorked - workingHours;
                        workingHoursDiff =
                            "${hoursWorked.toStringAsFixed(1)} hours";
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.all(4),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColor.primery),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xff4EB1C6).withOpacity(.4),
                              Color(0xff56C891).withOpacity(.4)
                            ],
                          )),
                      width: Sizes.width < 700
                          ? double.infinity
                          : Sizes.width < 1100 && Sizes.width > 700
                              ? Sizes.width * 0.38
                              : Sizes.width * 0.26,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$date',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text('Working Hours',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppColor.black.withOpacity(.7),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...logs.map((log) {
                                      return Text(
                                          'Punch Time: ${log.punchTime}'
                                              .substring(
                                                  22,
                                                  'Punch Time: ${log.punchTime}'
                                                          .length -
                                                      7),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600));
                                    }).toList(),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$workingHoursDiff',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: workingHoursDiff == 'Unknown'
                                              ? AppColor.red
                                              : AppColor.black),
                                    ),
                                    Text(
                                      workingHoursStatus.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: workingHoursStatus < 0
                                              ? AppColor.red
                                              : AppColor.black),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
