import 'package:flutter/material.dart';
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
              ListTile(
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
                  Navigator.pushReplacementNamed(context, '/staffView');
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
                title: const Text('Vouchers'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/voucher');
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
                title: const Text('Vouchers'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/voucherView');
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text("Reports"),
            leading: const Icon(Icons.report),
            children: [
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Expanse'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/expanse_report');
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
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
