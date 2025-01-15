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
  WidgetsFlutterBinding.ensureInitialized();
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
      },
    );
  }
}
