import 'package:flutter/material.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/ui/home/master/staff/staff_view.dart';
import 'package:payroll/utils/colors.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff4EB1C6), Color(0xff56C891)],
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 80, width: 80),
                const SizedBox(height: 10),
                const Text(
                  'MODERN PAYROLL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ExpansionTile(
            title: const Text("Masters"),
            leading: const Icon(Icons.difference_outlined),
            children: [
              Preference.getString(PrefKeys.userType) == 'Staff'
                  ? Container()
                  : ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Branches'),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/branchView');
                      },
                    ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Staff'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StaffViewScreen(staffListType: true)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Ledgers'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/ledgerView');
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text("Transections"),
            leading: const Icon(Icons.insert_chart),
            children: [
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Salaries'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/salary');
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Direct Payments'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StaffViewScreen(staffListType: false)));
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text("View"),
            leading: const Icon(Icons.preview),
            children: [
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Payments'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/paymentView');
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: AppColor.red,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: AppColor.red),
            ),
            onTap: () {
              logoutPrefData();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
