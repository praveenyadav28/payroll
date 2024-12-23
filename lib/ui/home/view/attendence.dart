// screens/salary_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/ui/home/transection/controller.dart';
import 'package:payroll/ui/home/transection/salaryModel.dart';
import 'package:payroll/utils/api.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/textformfield.dart';
import 'package:table_calendar/table_calendar.dart';

class Attendence extends StatefulWidget {
  const Attendence({super.key});

  @override
  State<Attendence> createState() => _AttendenceState();
}

class _AttendenceState extends State<Attendence> {
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
      WorkingShiftCalculator calculator1 = WorkingShiftCalculator();
      Map<String, dynamic> data1 = calculator1.calculate(
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
      WorkingHoursCalculator calculator0 = WorkingHoursCalculator();
      Map<String, dynamic> data0 = calculator0.calculate(
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
        workingHoursData = Preference.getString(PrefKeys.calculationType) == '1'
            ? data1
            : data0;
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
      appBar: AppBar(
        title: const Text('Attendance Screen'),
        flexibleSpace: const OutsideContainer(child: Column()),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                logoutPrefData();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              )),
          const Text(
            "Logout  ",
            style: TextStyle(color: Colors.red),
          ),
        ],
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
                      "Staff List",
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
                                  child: Text(
                                "Biomax Id",
                                style: TextStyle(
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold),
                              ))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text(
                                      Preference.getString(
                                                  PrefKeys.calculationType) ==
                                              '1'
                                          ? 'Working Shift'
                                          : "Working Days",
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontWeight: FontWeight.bold)))),
                          SizedBox(
                              height: Sizes.height * 0.05,
                              child: Center(
                                  child: Text(
                                      Preference.getString(
                                                  PrefKeys.calculationType) ==
                                              '1'
                                          ? 'Absent Shift'
                                          : 'Absent Days',
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
                                    child: Text(employeeData['employeeCode'],
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
                                child: IconButton(
                                  icon: Icon(Icons.visibility,
                                      color: AppColor.primery),
                                  onPressed: () {
                                    Preference.getString(
                                                PrefKeys.calculationType) ==
                                            '1'
                                        ? showShiftLog(
                                            employeeData['dailyPunchLogInfo'])
                                        : showActivityLog(
                                            employeeData['dailyPunchLogInfo'],
                                            employeeData[
                                                'employeeWorkingHours']);
                                  },
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

                    // Initialize variables
                    String workingHoursDiff = "No data";
                    String workingHoursStatusFormatted = "No data";

                    if (logs.isNotEmpty) {
                      if (logs.length == 1) {
                        // Single punch log case
                        workingHoursDiff = "Unknown";
                        workingHoursStatusFormatted = "0:0";
                      } else {
                        // Calculate total working duration
                        DateTime firstPunch = logs.first.punchTime;
                        DateTime lastPunch = logs.last.punchTime;
                        Duration duration = lastPunch.difference(firstPunch);

                        // Total hours and minutes worked
                        int hoursWorked = duration.inHours;
                        int minutesWorked = duration.inMinutes % 60;

                        // Format working hours
                        workingHoursDiff =
                            "$hoursWorked hours $minutesWorked minutes";

                        // Calculate status difference
                        double actualWorkedHours =
                            hoursWorked + minutesWorked / 60.0;
                        double statusDifference =
                            actualWorkedHours - workingHours;

                        // Handle negative and positive status differences
                        bool isNegative = statusDifference < 0;
                        int totalStatusMinutes =
                            (statusDifference.abs() * 60).round();
                        int statusHours = totalStatusMinutes ~/ 60;
                        int statusMinutes = totalStatusMinutes % 60;

                        // Format the working hours status
                        workingHoursStatusFormatted =
                            "${isNegative ? "-" : ""}$statusHours:$statusMinutes";
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColor.primery),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            workingHoursStatusFormatted.contains("-")
                                ? AppColor.red.withOpacity(.1)
                                : const Color(0xff4EB1C6).withOpacity(.4),
                            workingHoursStatusFormatted.contains("-")
                                ? AppColor.red.withOpacity(.2)
                                : const Color(0xff56C891).withOpacity(.4)
                          ],
                        ),
                      ),
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
                                  date,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Working Hours',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColor.black.withOpacity(.7),
                                      fontWeight: FontWeight.w600),
                                ),
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
                                        'Punch Time: ${log.punchTime.hour}:${log.punchTime.minute}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      );
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
                                      workingHoursDiff,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: workingHoursDiff == 'Unknown'
                                              ? AppColor.red
                                              : AppColor.black),
                                    ),
                                    Text(
                                      workingHoursStatusFormatted,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: workingHoursStatusFormatted
                                                  .contains("-")
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

  void showShiftLog(
    List<Map<String, String>> dailyPunchLogInfo,
  ) {
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
                  dailyPunchLogInfo.length,
                  (index) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.primery),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                "${dailyPunchLogInfo[index]['Difference']}"
                                        .contains("Less")
                                    ? AppColor.red.withOpacity(.1)
                                    : const Color(0xff4EB1C6).withOpacity(.4),
                                "${dailyPunchLogInfo[index]['Difference']}"
                                        .contains("Less")
                                    ? AppColor.red.withOpacity(.2)
                                    : const Color(0xff56C891).withOpacity(.4)
                              ],
                            ),
                          ),
                          width: Sizes.width < 700
                              ? double.infinity
                              : Sizes.width < 1100 && Sizes.width > 700
                                  ? Sizes.width * 0.38
                                  : Sizes.width * 0.26,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${dailyPunchLogInfo[index]['Punch In']}'
                                          .substring(
                                              0,
                                              '${dailyPunchLogInfo[index]['Punch In']}'
                                                      .length -
                                                  13),
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Working Hours',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: AppColor.black.withOpacity(.7),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Punch In: ${'${dailyPunchLogInfo[index]['Punch In']}'.substring(11, '${dailyPunchLogInfo[index]['Punch In']}'.length - 7)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "Punch Out: ${'${dailyPunchLogInfo[index]['Punch Out']}'.substring(11, '${dailyPunchLogInfo[index]['Punch Out']}'.length - 7)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${dailyPunchLogInfo[index]['Worked']}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.black),
                                        ),
                                        Text(
                                          '${dailyPunchLogInfo[index]['Difference']}'
                                                  .contains("Worked")
                                              ? ''
                                              : '${dailyPunchLogInfo[index]['Difference']}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  '${dailyPunchLogInfo[index]['Difference']}'
                                                          .contains("Less")
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
                        ),
                        "${dailyPunchLogInfo[index]['Difference']}"
                                .contains("Double")
                            ? const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(Icons.star,
                                    size: 35, color: Colors.amber),
                              )
                            : const SizedBox(width: 0, height: 0),
                      ],
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
