// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/prefences.dart';
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
  TextEditingController fromDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));
  TextEditingController toDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));
  TextEditingController searchController = TextEditingController();

  late ApiSalary apiService;
  Map<String, dynamic>? workingHoursData;
  List<DateTime> selectedDates = [];
  DateTime focusedDay = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<String> selectedPublicHolidays = [];
  String selectedMonth = 'January';

  DateTime _startDate =
      DateTime.now().add(const Duration(days: 1)); // Default: 1 day ahead
  DateTime _endDate =
      DateTime.now().add(const Duration(days: 1)); // Default: 1 day ahead

  @override
  void initState() {
    super.initState();
    apiService = ApiSalary();
    yearController.text = "${DateTime.now().year}";
    fromDate.text = "${yearController.text}/${monthInt[selectedMonth]!}/01";
    toDate.text = Preference.getString(PrefKeys.calculationType) == '1'
        ? toDate.text =
            "${selectedMonth == "December" ? int.parse(yearController.text.trim()) + 1 : yearController.text}/${selectedMonth == "December" ? 1 : monthInt[selectedMonth]! + 1}/01"
        : "${yearController.text}/${monthInt[selectedMonth]!}/${(selectedMonth == 'February' && isLeapYear(int.parse(yearController.text.toString()))) ? 29 : monthDays[selectedMonth]!}";
    fatchDate().then((value) => setState(() {
          fetchData();
        }));
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
        absentDaysCalculate,
        _startDate,
        _endDate.add(const Duration(days: 1)),
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

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyD &&
          event.isControlPressed &&
          event.isAltPressed) {
        _showDialog();
      }
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Use StatefulBuilder for UI updates
            return AlertDialog(
              title: const Text("Select Dates"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("${_startDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () {
                      _pickDate(context, true).then((_) {
                        setState(() {}); // Updates only the dialog UI
                      });
                    },
                  ),
                  ListTile(
                    title: Text("${_endDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () {
                      _pickDate(context, false).then((_) {
                        setState(() {}); // Updates only the dialog UI
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: AppColor.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    postDate(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyPress,
      child: Scaffold(
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
              if (Sizes.width < 800)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Sizes.width * 0.03,
                      vertical: Sizes.height * 0.02),
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xff377785),
                    ),
                  ),
                  child: Column(
                    children: [
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          "Select Public Holidays",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppColor.black),
                        ),
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
                      SizedBox(height: Sizes.height * 0.02),
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
                                          "${yearController.text}/${monthInt[selectedMonth]!}/01";
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
                  ),
                )
              else
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
                                        items:
                                            monthDays.keys.map((String month) {
                                          return DropdownMenuItem<String>(
                                            value: month,
                                            child: Text(month),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedMonth = value!;
                                            fromDate.text =
                                                "${yearController.text}/${monthInt[selectedMonth]!}/01";
                                            toDate.text = Preference.getString(
                                                        PrefKeys
                                                            .calculationType) ==
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
                                            fromDate.text =
                                                DateFormat('yyyy/MM/dd')
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
                                            toDate.text =
                                                DateFormat('yyyy/MM/dd')
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
              if (workingHoursData == null)
                Container()
              else
                Sizes.width < 800
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
                                colors: [
                                  Color(0xff4EB1C6),
                                  Color(0xff56C891)
                                ])),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            IconButton(
                              icon: Icon(Icons.file_download_outlined,
                                  color: AppColor.white),
                              onPressed: () async {
                                await generatePDF();
                              },
                            ),
                            Center(
                                child: Text(
                              "Salary List",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor.black,
                                  fontWeight: FontWeight.bold),
                            )),
                          ],
                        ),
                      ),
              workingHoursData == null
                  ? Container()
                  : Sizes.width < 800
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              CircleAvatar(
                                backgroundColor: AppColor.primery,
                                child: IconButton(
                                  icon: Icon(Icons.file_download_outlined,
                                      color: AppColor.white),
                                  onPressed: () async {
                                    await generatePDF();
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(workingHoursData!.length,
                                  (index) {
                                String employeeCode =
                                    workingHoursData!.keys.elementAt(index);
                                var employeeData =
                                    workingHoursData![employeeCode];
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: Sizes.height * 0.02),
                                  alignment: Alignment.topCenter,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xff377785),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 7.5),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              color: AppColor.primery,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Text(
                                            "${employeeData['employeeCode']}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.white,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          employeeData['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.black,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.visibility,
                                                  color: AppColor.primery),
                                              onPressed: () {
                                                Preference.getString(PrefKeys
                                                            .calculationType) ==
                                                        '1'
                                                    ? showShiftLog(employeeData[
                                                        'dailyPunchLogInfo'])
                                                    : showActivityLog(
                                                        employeeData[
                                                            'dailyPunchLogInfo'],
                                                        employeeData[
                                                            'employeeWorkingHours'],
                                                        employeeData[
                                                            'dailySalary'],
                                                      );
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.payment,
                                                  color: AppColor.black),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaymentScreen(
                                                            paymentVoucherNo: 0,
                                                            employeeData:
                                                                employeeData),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      ExpansionTile(
                                        title: Text(
                                          'Other Details',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.black,
                                          ),
                                        ),
                                        children: [
                                          datastylerow("Working Days",
                                              '${employeeData['workingDays']} Days'),
                                          datastylerow("Absent Days",
                                              '${employeeData['absentDays']} Days'),
                                          datastylerow("Monthly Salary",
                                              '₹${employeeData['monthlySalary'].toStringAsFixed(2)}'),
                                          datastylerow("Payable Amount",
                                              '₹${employeeData['dueSalary'].toStringAsFixed(2)}'),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              })
                            ])
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
                                            Preference.getString(PrefKeys
                                                        .calculationType) ==
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
                                            Preference.getString(PrefKeys
                                                        .calculationType) ==
                                                    '1'
                                                ? 'Absent Shift'
                                                : 'Absent Days',
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
                              ...List.generate(workingHoursData!.length,
                                  (index) {
                                String employeeCode =
                                    workingHoursData!.keys.elementAt(index);
                                var employeeData =
                                    workingHoursData![employeeCode];

                                return TableRow(children: [
                                  SizedBox(
                                      height: Sizes.height * 0.07,
                                      child: Center(
                                          child: Text(employeeData['name'],
                                              style: TextStyle(
                                                  color: AppColor.black)))),
                                  SizedBox(
                                      height: Sizes.height * 0.07,
                                      child: Center(
                                          child: Text(
                                              "${employeeData['workingDays']}",
                                              style: TextStyle(
                                                  color: AppColor.black)))),
                                  SizedBox(
                                      height: Sizes.height * 0.07,
                                      child: Center(
                                          child: Text(
                                              "${employeeData['absentDays']}",
                                              style: TextStyle(
                                                  color: AppColor.black)))),
                                  SizedBox(
                                      height: Sizes.height * 0.07,
                                      child: Center(
                                          child: Text(
                                              "₹${employeeData['monthlySalary'].toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: AppColor.black)))),
                                  SizedBox(
                                      height: Sizes.height * 0.07,
                                      child: Center(
                                          child: Text(
                                              "₹${employeeData['dueSalary'].toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: AppColor.black)))),
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
                                              Preference.getString(PrefKeys
                                                          .calculationType) ==
                                                      '1'
                                                  ? showShiftLog(employeeData[
                                                      'dailyPunchLogInfo'])
                                                  : showActivityLog(
                                                      employeeData[
                                                          'dailyPunchLogInfo'],
                                                      employeeData[
                                                          'employeeWorkingHours'],
                                                      employeeData[
                                                          'dailySalary'],
                                                    );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.payment,
                                                color: AppColor.black),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentScreen(
                                                          paymentVoucherNo: 0,
                                                          employeeData:
                                                              employeeData),
                                                ),
                                              );
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
      ),
    );
  }

//Post Date
  Future postDate(context) async {
    try {
      Map<String, dynamic> response = await ApiService.postData(
          "TransactionsPayroll/PostFixedDateLocationIdPayroll", {
        "Location_Id": int.parse(Preference.getString(PrefKeys.locationId)),
        "From_Date": DateFormat('yyyy/MM/dd').format(_startDate),
        "To_Date": DateFormat('yyyy/MM/dd').format(_endDate)
      });
      if (response["result"] == true) {
        Navigator.pop(context);
        showCustomSnackbarSuccess(context, response["message"]);
      } else {
        showCustomSnackbar(context, response["message"]);
      }
    } catch (e) {
      print("$e error");
    }
  }

//Get Date
  Future fatchDate() async {
    var response = await ApiService.fetchData(
        "TransactionsPayroll/GetFixedDateLocationIdPayroll?locationId=${Preference.getString(PrefKeys.locationId)}");
    _startDate = "${response[0]['from_Date']}".isEmpty
        ? DateTime.now().add(Duration(days: 1))
        : DateFormat("d/M/yyyy h:mm:ss a").parse(response[0]['from_Date']);
    _endDate = "${response[0]['to_Date']}".isEmpty
        ? DateTime.now().add(Duration(days: 1))
        : DateFormat("d/M/yyyy h:mm:ss a").parse(response[0]['to_Date']);
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
                    List<DeviceLog> duplicateList = [];
                    List<DeviceLog> logsForDay = dailyPunchLogInfo[date] ?? [];

                    // Filter logs with a time gap of more than 10 minutes between consecutive punches
                    List<DeviceLog> filteredLogsForDay = [];
                    if (logsForDay.isNotEmpty) {
                      filteredLogsForDay
                          .add(logsForDay.first); // Keep the first log
                      for (int i = 1; i < logsForDay.length; i++) {
                        Duration diff = logsForDay[i]
                            .punchTime
                            .difference(logsForDay[i - 1].punchTime);
                        if (diff.inMinutes > 10) {
                          filteredLogsForDay
                              .add(logsForDay[i]); // Add log if gap > 10 min
                        } else {
                          duplicateList.add(logsForDay[
                              i]); // Add to invalid logs if gap <= 10 min
                        }
                      }
                    }

                    // Filter logs for working hours calculation (exclude direction ' ')
                    List<DeviceLog> validLogsForDay = filteredLogsForDay
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
                                    }),
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
                                    }),
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
                              duplicateList.isEmpty
                                  ? Container()
                                  : const SizedBox(width: 5),
                              duplicateList.isEmpty
                                  ? Container()
                                  : Expanded(
                                      child: Column(
                                        children: [
                                          const Text('Duplicate',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          const Divider(),
                                          Column(children: [
                                            ...duplicateList
                                                .where((log) =>
                                                    log.punchDirection != null)
                                                .map(
                                              (log) {
                                                return Text(
                                                  '${log.punchTime.hour}:${log.punchTime.minute} ${log.punchDirection}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                );
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
                                              : 'More  $workingHoursStatusFormatted',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: workingHoursStatusFormatted
                                                  .contains("-")
                                              ? AppColor.red
                                              : AppColor.black),
                                    ),
                                    Text(
                                      "₹ ${salaryCalculated.toStringAsFixed(2)}",
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
                    List<DeviceLog> duplicateList =
                        dailyPunchLogInfo[index]['Duplicate'];
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
                                      }),
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
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Break',
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
                                duplicateList.isEmpty
                                    ? Container()
                                    : const SizedBox(width: 5),
                                duplicateList.isEmpty
                                    ? Container()
                                    : Expanded(
                                        child: Column(
                                          children: [
                                            const Text('Duplicate',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            const Divider(),
                                            Column(children: [
                                              ...duplicateList
                                                  .where((log) =>
                                                      log.punchDirection !=
                                                      null)
                                                  .map(
                                                (log) {
                                                  return Text(
                                                    '${log.punchTime.hour}:${log.punchTime.minute} ${log.punchDirection}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  );
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

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    // Define page size and orientation
    const pageFormat = PdfPageFormat.a4;

    // Define table headers
    final List<String> headers = [
      'Name',
      'Biomax Id',
      Preference.getString(PrefKeys.calculationType) == '1'
          ? 'Working Shift'
          : "Working Days",
      Preference.getString(PrefKeys.calculationType) == '1'
          ? 'Absent Shift'
          : 'Absent Days',
      "Monthly Salary",
      "Payable Amount"
    ];

    // Create a list to store table rows
    final List<List<String>> tableRows = [];

    for (var index = 0; index < workingHoursData!.length; index++) {
      String employeeCode = workingHoursData!.keys.elementAt(index);
      var employeeData = workingHoursData![employeeCode];
      final List<String> rowData = [
        employeeData['name'],
        employeeData['employeeCode'],
        "${employeeData['workingDays']}",
        "${employeeData['absentDays']}",
        "${employeeData['monthlySalary'].toStringAsFixed(2)}",
        "${employeeData['dueSalary'].toStringAsFixed(2)}",
      ];

      // Add rowData to tableRows
      tableRows.add(rowData);
    }

    // Add the table to the PDF document
    pdf.addPage(
      pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          build: (context) => pw.Column(children: [
                pw.Text("Staff Attendence",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Table.fromTextArray(
                  headers: headers,
                  data: tableRows,
                  cellAlignment: pw.Alignment.center,
                  border: pw.TableBorder.all(),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(),
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
              ])),
    );

    // Save the PDF to the device
    // ignore: unused_local_variable
    final output = await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );

    final file = File('example.pdf');
    await file.writeAsBytes(await pdf.save());
  }
}
