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
import 'package:payroll/ui/home/master/staff/staff_view.dart';
import 'package:payroll/ui/home/transection/salary.dart';
import 'package:payroll/ui/onboarding/login.dart';
import 'package:payroll/ui/onboarding/splash.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/components/prefences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Preference.preferences = await SharedPreferences.getInstance();
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
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
        '/staffView': (context) => const StaffViewScreen(),
        '/ledger': (context) => LedgerMasterScreen(isNew: true, ledgerId: 0),
        '/ledgerView': (context) => const LedgerViewScreen(),
        '/salary': (context) => const SalaryScreen(),
        // '/monthView': (context) => const MonthView(),
        // '/voucher': (context) => const VoucherScreen(),
        // '/salaryDetails': (context) => const SalaryDetails(),
        // '/voucherView': (context) => const VoucherViewScreen(),
        // '/expanse_report': (context) => const ExpenseScreen(),
      },
    );
  }
}

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Staff with Biomax Logs',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: StaffListScreen(),
//     );
//   }
// }

// class StaffListScreen extends StatefulWidget {
//   @override
//   _StaffListScreenState createState() => _StaffListScreenState();
// }

// class _StaffListScreenState extends State<StaffListScreen> {
//   late Future<List<StaffWithTime>> _futureStaff;

//   @override
//   void initState() {
//     super.initState();
//     _futureStaff = fetchAndMergeData();
//   }

//   Future<List<StaffWithTime>> fetchAndMergeData() async {
//     List<Staff> staffList = await fetchStaffList();
//     List<BiomaxLog> biomaxLogs = await fetchBiomaxLogs();
//     return mergeStaffWithBiomax(staffList, biomaxLogs);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Staff List with Biomax Data"),
//       ),
//       body: FutureBuilder<List<StaffWithTime>>(
//         future: _futureStaff,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text("No data available"));
//           }

//           List<StaffWithTime> staffList = snapshot.data!;

//           return ListView.builder(
//             itemCount: staffList.length,
//             itemBuilder: (context, index) {
//               StaffWithTime staff = staffList[index];

//               return ListTile(
//                 title: Text(staff.staff.staffName),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Mobile: ${staff.staff.mobile}"),
//                     Text("Salary: ${staff.staff.salary}"),
//                     Text("Punch In: ${staff.punchIn ?? 'N/A'}"),
//                     Text("Punch Out: ${staff.punchOut ?? 'N/A'}"),
//                     Text(
//                         "Working Hours: ${staff.workingHours?.inHours ?? 'N/A'} hrs"),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// Future<List<Staff>> fetchStaffList() async {
//   final response = await http.get(Uri.parse(
//       'http://lms.muepetro.com/api/MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=3'));

//   if (response.statusCode == 200) {
//     List jsonResponse = json.decode(response.body);
//     return jsonResponse.map((data) => Staff.fromJson(data)).toList();
//   } else {
//     throw Exception('Failed to load staff list');
//   }
// }

// Future<List<BiomaxLog>> fetchBiomaxLogs() async {
//   final response = await http.get(Uri.parse(
//       'http://103.178.113.149:82/api/v2/WebAPI/GetDeviceLogs?APIKey=555312092406&FromDate=2024-10-1&ToDate=2024-10-1'));

//   if (response.statusCode == 200) {
//     List jsonResponse = json.decode(response.body);
//     return jsonResponse.map((data) => BiomaxLog.fromJson(data)).toList();
//   } else {
//     throw Exception('Failed to load biomax logs');
//   }
// }

// List<StaffWithTime> mergeStaffWithBiomax(
//     List<Staff> staffList, List<BiomaxLog> biomaxLogs) {
//   List<StaffWithTime> combinedList = [];

//   for (var staff in staffList) {
//     // Find punch-in and punch-out logs
//     List<BiomaxLog> staffLogs =
//         biomaxLogs.where((log) => log.employeeCode == staff.biomaxId).toList();

//     if (staffLogs.isNotEmpty) {
//       DateTime? punchIn = staffLogs.first.logDate;
//       DateTime? punchOut = staffLogs.length > 1
//           ? staffLogs.last.logDate
//           : null; // Assuming last log as punch out

//       Duration? workingHours =
//           punchOut != null ? punchOut.difference(punchIn!) : null;

//       combinedList.add(StaffWithTime(
//           staff: staff,
//           punchIn: punchIn,
//           punchOut: punchOut,
//           workingHours: workingHours));
//     }
//   }

//   return combinedList;
// }

// class Staff {
//   final int id;
//   final String staffName;
//   final String mobile;
//   final String biomaxId;
//   final String salary;

//   Staff({
//     required this.id,
//     required this.staffName,
//     required this.mobile,
//     required this.biomaxId,
//     required this.salary,
//   });

//   factory Staff.fromJson(Map<String, dynamic> json) {
//     return Staff(
//       id: json['id'],
//       staffName: json['staff_Name'],
//       mobile: json['mob'],
//       biomaxId: json['biomaxId'],
//       salary: json['salary'],
//     );
//   }
// }

// class BiomaxLog {
//   final String employeeCode;
//   final DateTime logDate;

//   BiomaxLog({
//     required this.employeeCode,
//     required this.logDate,
//   });

//   factory BiomaxLog.fromJson(Map<String, dynamic> json) {
//     return BiomaxLog(
//       employeeCode: json['EmployeeCode'],
//       logDate: DateTime.parse(json['LogDate']),
//     );
//   }
// }

// class StaffWithTime {
//   final Staff staff;
//   final DateTime? punchIn;
//   final DateTime? punchOut;
//   final Duration? workingHours;

//   StaffWithTime({
//     required this.staff,
//     required this.punchIn,
//     required this.punchOut,
//     required this.workingHours,
//   });
// }
