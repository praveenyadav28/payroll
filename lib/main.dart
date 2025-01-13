import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payroll/ui/home/dashboard.dart';
import 'package:payroll/ui/home/master/branch/branch_master.dart';
import 'package:payroll/ui/home/master/branch/branch_view.dart';
import 'package:payroll/ui/home/master/city_master.dart';
import 'package:payroll/ui/home/master/district_master.dart';
import 'package:payroll/ui/home/master/ledger/ledger_master.dart';
import 'package:payroll/ui/home/master/ledger/ledger_view.dart';
import 'package:payroll/ui/home/master/staff/staff_master.dart';
import 'package:payroll/ui/home/transection/salary.dart';
import 'package:payroll/ui/home/view/attendence.dart';
import 'package:payroll/ui/home/view/payment.dart';
import 'package:payroll/ui/onboarding/login.dart';
import 'package:payroll/ui/onboarding/splash.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/components/prefences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Preference.preferences = await SharedPreferences.getInstance();
  Preference.getBool(PrefKeys.userstatus);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    Sizes.init(context);
    return MaterialApp(
      title: 'Payroll App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/city': (context) => const CityMaster(),
        '/login': (context) => const LoginScreen(),
        '/district': (context) => const DistrictMaster(),
        '/dashboard': (context) => const DashboardScreen(),
        '/branch': (context) => BranchMasterScreen(isNew: true, branchId: 0),
        '/branchView': (context) => const BranchViewScreen(),
        '/staff': (context) => StaffMasterScreen(isNew: true, staffId: 0),
        '/ledger': (context) => LedgerMasterScreen(isNew: true, ledgerId: 0),
        '/ledgerView': (context) => const LedgerViewScreen(),
        '/salary': (context) => const SalaryScreen(),
        '/paymentView': (context) => const PaymentViewScreen(),
        '/attendance': (context) => const Attendence(),
        // '/voucher': (context) => const VoucherScreen(),
        // '/salaryDetails': (context) => const SalaryDetails(),
        // '/voucherView': (context) => const VoucherViewScreen(),
        // '/expanse_report': (context) => const ExpenseScreen(),
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class Employee {
//   final String name;
//   final String employeeCode;
//   final double monthlySalary;

//   Employee({
//     required this.name,
//     required this.employeeCode,
//     required this.monthlySalary,
//   });

//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       name: json['staff_Name'],
//       employeeCode: json['biomaxId'],
//       monthlySalary: double.parse(json['salary']),
//     );
//   }
// }

// class DeviceLog {
//   final String employeeCode;
//   final DateTime logDate;
//   final DateTime punchTime;

//   DeviceLog({
//     required this.employeeCode,
//     required this.logDate,
//     required this.punchTime,
//   });

//   factory DeviceLog.fromJson(Map<String, dynamic> json) {
//     return DeviceLog(
//       employeeCode: json['EmployeeCode'],
//       logDate: DateTime.parse("${json['LogDate']}"),
//       punchTime: DateTime.parse("${json['LogDate']}"),
//     );
//   }
// }

// class WorkingHoursCalculator {
//   Map<String, dynamic> calculate(
//     List<Employee> employees,
//     List<DeviceLog> logs,
//     List<String> publicHolidays,
//     int daysInMonth,
//   ) {
//     Map<String, dynamic> result = {};

//     // Convert public holidays to DateTime
//     List<DateTime> holidayDates =
//         publicHolidays.map((holiday) => DateTime.parse(holiday)).toList();

//     for (var employee in employees) {
//       List<DeviceLog> employeeLogs = logs
//           .where((log) => log.employeeCode == employee.employeeCode)
//           .toList();

//       // Initialize variables
//       int actualAbsentDays = 0;
//       int workingDays = 0;
//       int halfDaysCount = 0;
//       double totalHours = 0;
//       double dailySalary = employee.monthlySalary / daysInMonth;

//       Set<String> punchDays = {};
//       Set<String> absentDays = {};

//       // Group logs by date
//       Map<String, List<DeviceLog>> groupedLogs = {};
//       for (var log in employeeLogs) {
//         String logDate = log.logDate.toIso8601String().split('T')[0];
//         groupedLogs.putIfAbsent(logDate, () => []).add(log);
//       }

//       for (int day = 1; day <= daysInMonth; day++) {
//         String currentDate =
//             DateTime(DateTime.now().year, DateTime.now().month, day)
//                 .toIso8601String()
//                 .split('T')[0];

//         if (holidayDates.any((holiday) =>
//             holiday.toIso8601String().split('T')[0] == currentDate)) {
//           continue;
//         }

//         List<DeviceLog> logsForDay = groupedLogs[currentDate] ?? [];

//         if (logsForDay.isEmpty) {
//           absentDays.add(currentDate);
//           actualAbsentDays++;
//         } else {
//           punchDays.add(currentDate);
//           if (logsForDay.length == 1) {
//             totalHours += 8;
//             workingDays++;
//           } else {
//             DateTime firstPunch = logsForDay.first.punchTime;
//             DateTime lastPunch = logsForDay.last.punchTime;
//             Duration workedDuration = lastPunch.difference(firstPunch);
//             double hoursWorked =
//                 workedDuration.inHours + (workedDuration.inMinutes % 60) / 60.0;

//             totalHours += hoursWorked;
//             if (hoursWorked < 3) {
//               actualAbsentDays++;
//               absentDays.add(currentDate);
//             } else if (hoursWorked < 6) {
//               halfDaysCount++;
//             } else {
//               workingDays++;
//             }
//           }
//         }
//       }

//       // Apply Sandwich Rule
//       for (var holiday in holidayDates) {
//         String holidayDate = holiday.toIso8601String().split('T')[0];
//         DateTime dayBefore = holiday.subtract(Duration(days: 1));
//         DateTime dayAfter = holiday.add(Duration(days: 1));

//         if (absentDays.contains(dayBefore.toIso8601String().split('T')[0]) &&
//             absentDays.contains(dayAfter.toIso8601String().split('T')[0])) {
//           actualAbsentDays++;
//         }
//       }

//       double salaryDeduction =
//           (actualAbsentDays + (halfDaysCount / 2)) * dailySalary;
//       double dueSalary = employee.monthlySalary - salaryDeduction;

//       result[employee.employeeCode] = {
//         'name': employee.name,
//         'workingHours': totalHours,
//         'workingDays': workingDays,
//         'absentDays': actualAbsentDays,
//         'halfDays': halfDaysCount,
//         'monthlySalary': employee.monthlySalary,
//         'dueSalary': dueSalary,
//         'dailyPunchLogInfo': groupedLogs
//       };
//     }

//     return result;
//   }
// }

// class ApiService {
//   final String employeeApiUrl =
//       'http://lms.muepetro.com/api/MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=12';

//   Future<List<Employee>> fetchEmployees() async {
//     final response = await http.get(Uri.parse(employeeApiUrl));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Employee.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load employees');
//     }
//   }

//   Future<List<DeviceLog>> fetchLogs(String fromDate, String toDate) async {
//     final response = await http.get(Uri.parse(
//         "http://103.178.113.149:82/api/v2/WebAPI/GetDeviceLogs?APIKey=555312092406&FromDate=$fromDate&ToDate=$toDate"));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => DeviceLog.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load device logs');
//     }
//   }
// }

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Payroll App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const PayrollHomePage(),
//     );
//   }
// }

// class PayrollHomePage extends StatefulWidget {
//   const PayrollHomePage({super.key});

//   @override
//   _PayrollHomePageState createState() => _PayrollHomePageState();
// }

// class _PayrollHomePageState extends State<PayrollHomePage> {
//   late ApiService apiService;
//   Map<String, dynamic>? workingHoursData;
//   List<String> selectedPublicHolidays = [];
//   String selectedMonth = 'January';

//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService();
//     fetchData();
//   }

//   final Map<String, int> monthDays = {
//     'January': 31,
//     'February': 28,
//     'March': 31,
//     'April': 30,
//     'May': 31,
//     'June': 30,
//     'July': 31,
//     'August': 31,
//     'September': 30,
//     'October': 31,
//     'November': 30,
//     'December': 31,
//   };

//   bool isLeapYear(int year) {
//     return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
//   }

//   void fetchData() async {
//     try {
//       List<Employee> employees = await apiService.fetchEmployees();
//       int year = DateTime.now().year;
//       int daysInMonth = (selectedMonth == 'February' && isLeapYear(year))
//           ? 29
//           : monthDays[selectedMonth]!;

//       String fromDate =
//           '$year-${monthDays.keys.toList().indexOf(selectedMonth) + 1}-01';
//       String toDate =
//           '$year-${monthDays.keys.toList().indexOf(selectedMonth) + 1}-$daysInMonth';

//       List<DeviceLog> logs = await apiService.fetchLogs(fromDate, toDate);
//       WorkingHoursCalculator calculator = WorkingHoursCalculator();
//       Map<String, dynamic> data = calculator.calculate(
//           employees, logs, selectedPublicHolidays, daysInMonth);

//       setState(() {
//         workingHoursData = data;
//       });
//     } catch (e) {
//       _showErrorDialog('Failed to load data: $e');
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _selectPublicHoliday(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2022),
//       lastDate: DateTime(2025),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedPublicHolidays.add(picked.toLocal().toString().split(' ')[0]);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payroll Management'),
//       ),
//       body: Column(
//         children: [
//           DropdownButton<String>(
//             value: selectedMonth,
//             items: monthDays.keys.map((String month) {
//               return DropdownMenuItem<String>(
//                 value: month,
//                 child: Text(month),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 selectedMonth = value!;
//               });
//               fetchData();
//             },
//           ),
//           ElevatedButton(
//             onPressed: () => _selectPublicHoliday(context),
//             child: const Text('Select Public Holiday'),
//           ),
//           Expanded(
//             child: workingHoursData == null
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: workingHoursData!.length,
//                     itemBuilder: (context, index) {
//                       String employeeCode =
//                           workingHoursData!.keys.elementAt(index);
//                       Map<String, dynamic> employeeData =
//                           workingHoursData![employeeCode];
//                       return Card(
//                         child: ListTile(
//                           title: Text(
//                               '${employeeData['name']} - Due Salary: ₹${employeeData['dueSalary'].toStringAsFixed(2)}'),
//                           subtitle: Text(
//                               'Working Days: ${employeeData['workingDays']}, Absent Days: ${employeeData['absentDays']}, Half Days: ${employeeData['halfDays']}'),
//                           onTap: () {
//                             showActivityLog(employeeData['dailyPunchLogInfo']);
//                           },
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   void showActivityLog(Map<String, List<DeviceLog>> dailyPunchLogInfo) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Activity Log'),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: ListView.builder(
//               itemCount: dailyPunchLogInfo.keys.length,
//               itemBuilder: (context, index) {
//                 String date = dailyPunchLogInfo.keys.elementAt(index);
//                 List<DeviceLog> logs = dailyPunchLogInfo[date] ?? [];
//                 return ListTile(
//                   title: Text('Date: $date'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: logs.map((log) {
//                       return Text('Punch Time: ${log.punchTime}');
//                     }).toList(),
//                   ),
//                 );
//               },
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class Employee {
//   final int id;
//   final String name;
//   final String employeeCode;
//   final double monthlySalary;
//   final double workingHours;

//   Employee({
//     required this.id,
//     required this.name,
//     required this.employeeCode,
//     required this.monthlySalary,
//     required this.workingHours,
//   });

//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       id: json['id'],
//       name: json['staff_Name'],
//       employeeCode: json['biomaxId'],
//       monthlySalary: double.parse(json['salary']),
//       workingHours: double.parse(json['other1']),
//     );
//   }
// }

// class DeviceLog {
//   final String employeeCode;
//   final String punchDirection;
//   final String serialNumber;
//   final DateTime logDate;
//   final DateTime punchTime;

//   DeviceLog({
//     required this.employeeCode,
//     required this.punchDirection,
//     required this.serialNumber,
//     required this.logDate,
//     required this.punchTime,
//   });

//   factory DeviceLog.fromJson(Map<String, dynamic> json) {
//     return DeviceLog(
//       employeeCode: json['EmployeeCode'],
//       punchDirection: json['PunchDirection'],
//       serialNumber: json['SerialNumber'],
//       logDate: DateTime.parse("${json['LogDate']}"),
//       punchTime: DateTime.parse("${json['LogDate']}"),
//     );
//   }
// }

// class ApiService {
//   final String employeeApiUrl =
//       'http://lms.muepetro.com/api/MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=12';

//   Future<List<Employee>> fetchEmployees() async {
//     final response = await http.get(Uri.parse(employeeApiUrl));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Employee.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load employees');
//     }
//   }

//   Future<List<DeviceLog>> fetchLogs(String fromDate, String toDate) async {
//     final response = await http.get(Uri.parse(
//         "http://103.178.113.149:82/api/v2/WebAPI/GetDeviceLogs?APIKey=555312092406&FromDate=$fromDate&ToDate=$toDate"));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => DeviceLog.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load device logs');
//     }
//   }
// }

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: PayrollScreen(),
//     );
//   }
// }

// class PayrollScreen extends StatefulWidget {
//   @override
//   _PayrollScreenState createState() => _PayrollScreenState();
// }

// class _PayrollScreenState extends State<PayrollScreen> {
//   final ApiService apiService = ApiService();
//   List<Employee> employees = [];
//   List<DeviceLog> logs = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     try {
//       List<Employee> fetchedEmployees = await apiService.fetchEmployees();
//       List<DeviceLog> fetchedLogs = await apiService.fetchLogs(
//           "2024-12-01", "2024-12-31"); // Example date range
//       setState(() {
//         employees = fetchedEmployees;
//         logs = fetchedLogs;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error: $e");
//     }
//   }

//   void showShiftsDialog(BuildContext context, Employee employee) {
//     const double standardShiftHours = 8.0; // Standard working hours per shift
//     double dailySalary =
//         employee.monthlySalary / 30; // Approximate daily salary
//     double hourlyRate = dailySalary / standardShiftHours; // Hourly rate

//     // Filter logs for the specific employee
//     List<DeviceLog> employeeLogs = logs
//         .where((log) =>
//             log.employeeCode == employee.employeeCode && log.serialNumber == '')
//         .toList();

//     List<Map<String, String>> shifts = [];
//     int totalShifts = 0;
//     double calculatedMonthlySalary = 0;

//     for (int i = 0; i < employeeLogs.length; i++) {
//       if (employeeLogs[i].punchDirection == "in") {
//         DateTime punchInTime = employeeLogs[i].punchTime;
//         DateTime? punchOutTime;
//         double hoursWorked;

//         if (i + 1 < employeeLogs.length &&
//             employeeLogs[i + 1].punchDirection == "out") {
//           punchOutTime = employeeLogs[i + 1].punchTime;
//           hoursWorked =
//               punchOutTime.difference(punchInTime).inMinutes / 60.0; // Hours
//         } else {
//           punchOutTime = null;
//           hoursWorked = standardShiftHours; // Assume full shift worked
//         }

//         // Salary Calculation
//         double calculatedSalary;
//         int shiftsCount;
//         String differenceText;

//         if (hoursWorked < 6.0) {
//           // Half day logic
//           double missingHours = 8.0 - hoursWorked;
//           calculatedSalary = (hoursWorked * hourlyRate); // Deduct salary
//           differenceText =
//               "Less: ${missingHours.floor()}h ${(missingHours.remainder(1) * 60).round()}m";
//           shiftsCount = 1;
//         } else if (hoursWorked >= 6.0 && hoursWorked <= 8.0) {
//           calculatedSalary = dailySalary; // Full day pay
//           differenceText =
//               "Worked: ${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m";
//           shiftsCount = 1;
//         } else {
//           // Overtime logic
//           shiftsCount = (hoursWorked / 8).floor();
//           calculatedSalary = shiftsCount * dailySalary;
//           differenceText =
//               "Extra: ${(hoursWorked - 8.0).floor()}h ${(hoursWorked - 8.0).remainder(1) * 60}m";
//         }

//         totalShifts += shiftsCount;
//         calculatedMonthlySalary += calculatedSalary;

//         shifts.add({
//           "Punch In": punchInTime.toString(),
//           "Punch Out": punchOutTime?.toString() ?? "N/A (Assumed Full Shift)",
//           "Worked":
//               "${hoursWorked.floor()}h ${(hoursWorked.remainder(1) * 60).round()}m",
//           "Difference": differenceText,
//           "Salary": "₹${calculatedSalary.toStringAsFixed(2)}",
//         });
//       }
//     }

//     // Show dialog box
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Shifts for ${employee.name}"),
//         content: Container(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: shifts.length,
//             itemBuilder: (context, index) {
//               final shift = shifts[index];
//               return ListTile(
//                 title: Text("Shift ${index + 1}"),
//                 subtitle: Text(
//                   "Punch In: ${shift['Punch In']}\n"
//                   "Punch Out: ${shift['Punch Out']}\n"
//                   "Worked: ${shift['Worked']}\n"
//                   "Difference: ${shift['Difference']}\n"
//                   "Calculated Salary: ${shift['Salary']}",
//                 ),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payroll Application'),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: employees.length,
//               itemBuilder: (context, index) {
//                 final employee = employees[index];

//                 // Calculate total shifts, absent shifts, and salary
//                 int totalShifts = logs
//                     .where((log) =>
//                         log.employeeCode == employee.employeeCode &&
//                         log.employeeCode == employee.employeeCode &&
//                         log.serialNumber == '' &&
//                         log.punchDirection == "in")
//                     .length;
//                 int absentShifts = 30 - totalShifts; // Example assumption
//                 double calculatedMonthlySalary =
//                     totalShifts * (employee.monthlySalary / 30);

//                 return ListTile(
//                   title: Text(employee.name),
//                   subtitle: Text(
//                     "Total Shifts: $totalShifts\n"
//                     "Absent Shifts: $absentShifts\n"
//                     "Monthly Salary: ₹${employee.monthlySalary.toStringAsFixed(2)}\n"
//                     "Calculated Salary: ₹${calculatedMonthlySalary.toStringAsFixed(2)}",
//                   ),
//                   onTap: () => showShiftsDialog(context, employee),
//                 );
//               },
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  TimeOfDay? _selectedTime;

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _selectTime,
              child: const Text('Select Time'),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedTime?.format(context) ?? 'No time selected',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
    );
  }
}
