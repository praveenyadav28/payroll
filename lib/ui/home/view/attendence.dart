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
  TextEditingController fromDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));
  TextEditingController toDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));
  TextEditingController yearController = TextEditingController();

  late ApiSalary apiService;
  Map<String, dynamic>? workingHoursData;
  List<DateTime> selectedDates = [];
  DateTime focusedDay = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<String> selectedPublicHolidays = [];
  String selectedMonth = 'January';

  final Map<String, int> monthInt = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  @override
  void initState() {
    super.initState();
    apiService = ApiSalary();

    yearController.text = "${DateTime.now().year}";
    fromDate.text =
        "${yearController.text}/${selectedMonth == 'January' ? 1 : selectedMonth == 'February' ? 2 : selectedMonth == 'March' ? 3 : selectedMonth == 'April' ? 4 : selectedMonth == 'May' ? 5 : selectedMonth == 'June' ? 6 : selectedMonth == 'July' ? 7 : selectedMonth == 'August' ? 8 : selectedMonth == 'September' ? 9 : selectedMonth == 'October' ? 10 : selectedMonth == 'November' ? 11 : 12}/01";
    toDate.text = Preference.getString(PrefKeys.calculationType) == '1'
        ? toDate.text =
            "${selectedMonth == "December" ? int.parse(yearController.text.trim()) + 1 : yearController.text}/${selectedMonth == "December" ? 1 : monthInt[selectedMonth]! + 1}/01"
        : "${yearController.text}/${monthInt[selectedMonth]!}/${(selectedMonth == 'February' && isLeapYear(int.parse(yearController.text.toString()))) ? 29 : monthDays[selectedMonth]!}";

    yearController.text = "${DateTime.now().year}";
    fetchData();
  }

  int absentDaysCalculation(String fromDateText, String toDateText) {
    DateTime fromTheDate = DateFormat("yyyy/MM/dd").parse(fromDateText);
    DateTime toTheDate = DateFormat("yyyy/MM/dd").parse(toDateText);

    Duration difference = toTheDate.difference(fromTheDate);
    return difference.inDays;
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

      List<DeviceLog> logs =
          await apiService.fetchLogs(fromDate.text, toDate.text);

      int absentDaysCalculate =
          absentDaysCalculation(fromDate.text, toDate.text) +
              absentDaysCalculation(fromDate.text, toDate.text) +
              (Preference.getString(PrefKeys.calculationType) == '1' ? 0 : 1);

      WorkingShiftCalculator calculator1 = WorkingShiftCalculator();
      Map<String, dynamic> data1 = calculator1.calculate(
          employees,
          logs,
          selectedPublicHolidays,
          daysInMonth,
          int.parse(yearController.text.toString()),
          monthInt[selectedMonth]!,
          absentDaysCalculate);
      WorkingHoursCalculator calculator0 = WorkingHoursCalculator();
      Map<String, dynamic> data0 = calculator0.calculate(
          employees,
          logs,
          selectedPublicHolidays,
          daysInMonth,
          int.parse(yearController.text.toString()),
          monthInt[selectedMonth]!,
          absentDaysCalculate);

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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                        fromDate.text =
                                            "${yearController.text}/${selectedMonth == 'January' ? 1 : selectedMonth == 'February' ? 2 : selectedMonth == 'March' ? 3 : selectedMonth == 'April' ? 4 : selectedMonth == 'May' ? 5 : selectedMonth == 'June' ? 6 : selectedMonth == 'July' ? 7 : selectedMonth == 'August' ? 8 : selectedMonth == 'September' ? 9 : selectedMonth == 'October' ? 10 : selectedMonth == 'November' ? 11 : 12}/01";
                                        toDate.text = Preference.getString(
                                                    PrefKeys.calculationType) ==
                                                '1'
                                            ? toDate.text =
                                                "${selectedMonth == "December" ? int.parse(yearController.text.trim()) + 1 : yearController.text}/${selectedMonth == "December" ? 1 : monthInt[selectedMonth]! + 1}/01"
                                            : "${yearController.text}/${monthInt[selectedMonth]!}/${(selectedMonth == 'February' && isLeapYear(int.parse(yearController.text.toString()))) ? 29 : monthDays[selectedMonth]!}";
                                      });
                                    },
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(height: Sizes.height * 0.02),
                        Row(
                          children: [
                            Expanded(
                              child: dropdownTextfield(
                                context,
                                "From Date",
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2500),
                                    ).then((selectedDate) {
                                      if (selectedDate != null) {
                                        fromDate.text = DateFormat('yyyy/MM/dd')
                                            .format(selectedDate);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        fromDate.text,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.black),
                                      ),
                                      Icon(Icons.edit_calendar,
                                          color: AppColor.black)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: dropdownTextfield(
                                context,
                                "To Date",
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2500),
                                    ).then((selectedDate) {
                                      if (selectedDate != null) {
                                        toDate.text = DateFormat('yyyy/MM/dd')
                                            .format(selectedDate);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        toDate.text,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.black),
                                      ),
                                      Icon(Icons.edit_calendar,
                                          color: AppColor.black)
                                    ],
                                  ),
                                ),
                              ),
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
                                                'employeeWorkingHours'],
                                            employeeData['dailySalary']);
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

  void showActivityLog(Map<String, List<DeviceLog>> dailyPunchLogInfo,
      double workingHours, double dailySalary) {
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
                    List<DeviceLog> logsForDay = dailyPunchLogInfo[date] ?? [];
                    List<DeviceLog> validLogsForDay = logsForDay
                        .where((log) =>
                            log.punchDirection == 'in' ||
                            log.punchDirection == 'out')
                        .toList();
                    List<DeviceLog> unvalidLogsForDay = logsForDay
                        .where((log) =>
                            log.punchDirection == ' ' ||
                            log.punchDirection == '')
                        .toList();

                    List<DeviceLog> oddList = [];
                    List<DeviceLog> evenList = [];
                    for (int i = 0; i < validLogsForDay.length; i++) {
                      if (i % 2 == 0) {
                        oddList.add(validLogsForDay[i]); // Even index
                      } else {
                        evenList.add(validLogsForDay[i]); // Odd index
                      }
                    }
                    // Initialize variables
                    String workingHoursDiff = "No data";
                    String workingHoursStatusFormatted = "No data";
                    double totalWorkedHours = 0.0;
                    double salaryCalculated = 0.0;
                    if (validLogsForDay.isNotEmpty) {
                      if (validLogsForDay.length % 2 != 0) {
                        // Odd number of logs, so working hours are 0
                        workingHoursDiff = "Unknown";
                        workingHoursStatusFormatted = "0:0";
                      } else {
                        // Even number of logs, calculate total working duration by pairs

                        for (int i = 0; i < validLogsForDay.length; i += 2) {
                          Duration pairDuration = validLogsForDay[i + 1]
                              .punchTime
                              .difference(validLogsForDay[i].punchTime);
                          totalWorkedHours += pairDuration.inHours +
                              (pairDuration.inMinutes % 60) / 60.0;
                        }
                        salaryCalculated = totalWorkedHours >= workingHours
                            ? dailySalary * workingHours
                            : totalWorkedHours * dailySalary;
                        // Total hours and minutes worked
                        int totalHoursWorked = totalWorkedHours.floor();
                        int totalMinutesWorked =
                            ((totalWorkedHours - totalHoursWorked) * 60)
                                .round();

                        // Format working hours
                        workingHoursDiff =
                            "$totalHoursWorked hours $totalMinutesWorked minutes";

                        // Calculate status difference
                        double statusDifference =
                            totalWorkedHours - workingHours;

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
                              : Sizes.width * 0.285,
                      child: Column(
                        children: [
                          Text(
                            date,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('Punch In',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const Divider(),
                                    ...oddList
                                        .where((log) =>
                                            log.punchDirection.isNotEmpty)
                                        .map((log) {
                                      return Text(
                                        '${log.punchTime.hour}:${log.punchTime.minute}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('Punch Out',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const Divider(),
                                    ...evenList
                                        .where((log) =>
                                            log.punchDirection.isNotEmpty)
                                        .map((log) {
                                      return Text(
                                        '${log.punchTime.hour}:${log.punchTime.minute}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text('Break In/Out',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const Divider(),
                                    Wrap(direction: Axis.horizontal, children: [
                                      ...unvalidLogsForDay
                                          .where((log) =>
                                              log.punchDirection.trim().isEmpty)
                                          .map(
                                        (log) {
                                          return Container(
                                              decoration: BoxDecoration(
                                                  color: AppColor.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3,
                                                      horizontal: 4),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 5),
                                              child: Text(
                                                  '${log.punchTime.hour}:${log.punchTime.minute}'));
                                        },
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Text(
                                      'Working Hours',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: AppColor.black.withOpacity(.7),
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      workingHoursDiff,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: workingHoursDiff == 'Unknown'
                                              ? AppColor.red
                                              : AppColor.black),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      workingHoursStatusFormatted
                                              .contains("0:0")
                                          ? ""
                                          : workingHoursStatusFormatted
                                                  .contains("-")
                                              ? "Less $workingHoursStatusFormatted"
                                              : 'More - $workingHoursStatusFormatted',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: workingHoursStatusFormatted
                                                  .contains("-")
                                              ? AppColor.red
                                              : AppColor.black),
                                    ),
                                    Text(
                                      salaryCalculated.toStringAsFixed(2),
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
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
    List<Map<String, dynamic>> dailyPunchLogInfo,
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
                    List<DeviceLog> logsForDay =
                        dailyPunchLogInfo[index]['PunchTime'];
                    String date =
                        DateFormat('dd-MM-yyyy').format(logsForDay[0].logDate);
                    List<DeviceLog> validLogsForDay = logsForDay
                        .where((log) =>
                            log.punchDirection == 'in' ||
                            log.punchDirection == 'out')
                        .toList();
                    List<DeviceLog> unvalidLogsForDay = logsForDay
                        .where((log) => log.punchDirection.trim().isEmpty)
                        .toList();

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
                                "${dailyPunchLogInfo[index]['differenceText']}"
                                        .contains("Less")
                                    ? AppColor.red.withOpacity(.1)
                                    : const Color(0xff4EB1C6).withOpacity(.4),
                                "${dailyPunchLogInfo[index]['differenceText']}"
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
                          child: Column(children: [
                            Text(
                              date,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Punch In',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const Divider(),
                                      ...validLogsForDay
                                          .where((log) =>
                                              log.punchDirection.isNotEmpty)
                                          .map((log) {
                                        return Text(
                                          log.punchDirection == 'out'
                                              ? '-'
                                              : '${log.punchTime.hour}:${log.punchTime.minute}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Punch Out',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const Divider(),
                                      ...validLogsForDay
                                          .where((log) =>
                                              log.punchDirection.isNotEmpty)
                                          .map((log) {
                                        return Text(
                                          log.punchDirection == 'in'
                                              ? '-'
                                              : '${log.punchTime.hour}:${log.punchTime.minute}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Break In/Out',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const Divider(),
                                      Wrap(
                                          direction: Axis.horizontal,
                                          children: [
                                            ...unvalidLogsForDay
                                                .where((log) => log
                                                    .punchDirection
                                                    .trim()
                                                    .isEmpty)
                                                .map(
                                              (log) {
                                                return Container(
                                                    decoration: BoxDecoration(
                                                        color: AppColor.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 3,
                                                        horizontal: 4),
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4,
                                                        horizontal: 5),
                                                    child: Text(
                                                        '${log.punchTime.hour}:${log.punchTime.minute}'));
                                              },
                                            ),
                                          ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Working Hours',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                AppColor.black.withOpacity(.7),
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        validLogsForDay.length % 2 != 0 ||
                                                dailyPunchLogInfo[index]
                                                        ['workinghours'] ==
                                                    0.0
                                            ? "Unknown"
                                            : "${dailyPunchLogInfo[index]['workinghours'].floor()}hours ${(dailyPunchLogInfo[index]['workinghours'].remainder(1) * 60).round()}minutes",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: validLogsForDay.length % 2 !=
                                                        0 ||
                                                    dailyPunchLogInfo[index]
                                                            ['workinghours'] ==
                                                        0.0
                                                ? AppColor.red
                                                : AppColor.black),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Text(
                                        validLogsForDay.length % 2 != 0 ||
                                                dailyPunchLogInfo[index]
                                                        ['workinghours'] ==
                                                    0.0
                                            ? ""
                                            : '${dailyPunchLogInfo[index]['differenceText']}',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: dailyPunchLogInfo[index]
                                                        ['differenceText']
                                                    .contains("Less")
                                                ? AppColor.red
                                                : AppColor.black),
                                      ),
                                      Text(
                                        dailyPunchLogInfo[index]['Salary'],
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ]),
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
