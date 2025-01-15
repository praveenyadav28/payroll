// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/ui/home/transection/payment.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/textformfield.dart';

class DueScreen extends StatefulWidget {
  const DueScreen({super.key});
  @override
  State<DueScreen> createState() => _DueScreenState();
}

class _DueScreenState extends State<DueScreen> {
  TextEditingController searchController = TextEditingController();
  List staffList = [];
  List filteredList = [];

  @override
  void initState() {
    super.initState();
    getStaffList().then((_) => setState(() {
          filteredList = staffList;
        }));
  }

  void filterList(String searchText) {
    setState(() {
      filteredList = staffList.where((value) {
        return value['staffName']
            .toLowerCase()
            .contains(searchText.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Due Payments'),
        flexibleSpace: const OutsideContainer(child: Column()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.width * .05,
          vertical: Sizes.height * .02,
        ),
        child: Column(
          children: [
            addMasterOutside(children: [
              CommonTextFormField(
                  controller: searchController,
                  onchanged: (value) => filterList(value),
                  labelText: 'Search',
                  suffixIcon: Icon(
                    Icons.search,
                    size: 30,
                    color: AppColor.black,
                  )),
            ], context: context),
            Sizes.width < 800
                ? Column(
                    children: List.generate(filteredList.length, (index) {
                    final staff = filteredList[index];

                    double dueAmount = double.parse(staff['dueAmount']);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                                paymentVoucherNo: 0,
                                employeeData: {
                                  'id': staff['staffId'],
                                  'name': staff['staffName'],
                                  'monthlySalary': staff['monthlySalary'],
                                  'dueSalary': 0,
                                }),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: Sizes.height * 0.02),
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
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    color: AppColor.primery,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text(
                                  staff['biomaxId'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                staff['staffName'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.black,
                                ),
                              ),
                              trailing: Text(
                                "₹ ${dueAmount.abs()}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.red,
                                ),
                              ),
                            ),
                            ListTile(
                              dense: true,
                              title: Text(
                                staff['degination'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.black.withOpacity(.7),
                                ),
                              ),
                              trailing: Text(
                                staff['mobileNo'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.black.withOpacity(.7),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }))
                : Column(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        width: Sizes.width * 1,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border.all(
                            color: const Color(0xff377785),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff4EB1C6), Color(0xff56C891)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Staff List",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Sizes.width * 1,
                        child: Table(
                          border: TableBorder.all(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: const Color(0xff377785),
                          ),
                          children: [
                            TableRow(children: [
                              tableHeader("Name"),
                              tableHeader("Designation"),
                              tableHeader("Biomax Id"),
                              tableHeader("Mobile"),
                              tableHeader("Monthly Salary"),
                              tableHeader("Due Amount"),
                              tableHeader("Action"),
                            ]),
                            ...List.generate(filteredList.length, (index) {
                              final staff = filteredList[index];

                              double dueAmount =
                                  double.parse(staff['dueAmount']);

                              return TableRow(children: [
                                tableCell(staff['staffName']),
                                tableCell(staff['degination']),
                                tableCell(staff['biomaxId']),
                                tableCell(staff['mobileNo']),
                                tableCell(staff['monthlySalary']),
                                tableCell("${dueAmount.abs()}"),
                                IconButton(
                                  icon: Icon(
                                    Icons.receipt,
                                    color: AppColor.primery,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentScreen(
                                            paymentVoucherNo: 0,
                                            employeeData: {
                                              'id': staff['staffId'],
                                              'name': staff['staffName'],
                                              'monthlySalary':
                                                  staff['monthlySalary'],
                                              'dueSalary': 0,
                                            }),
                                      ),
                                    );
                                  },
                                )
                              ]);
                            }),
                          ],
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  // Utility function for creating table headers
  Widget tableHeader(String text) {
    return SizedBox(
      height: Sizes.height * 0.05,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: AppColor.primery,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Utility function for creating table cells
  Widget tableCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> getStaffList() async {
    var response = await ApiService.fetchData(
        'TransactionsPayroll/GetDueSalaryAmountWithSTAFFPayroll?varlocationid=${Preference.getString(PrefKeys.locationId)}&dateto=${DateFormat('yyyy/MM/dd').format(DateTime.now())}');
    setState(() {
      staffList = response['due'];
    });
  }
}
