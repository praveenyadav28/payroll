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

class AdvanceScreen extends StatefulWidget {
  const AdvanceScreen({super.key});
  @override
  State<AdvanceScreen> createState() => _AdvanceScreenState();
}

class _AdvanceScreenState extends State<AdvanceScreen> {
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
        title: const Text('Advance Payments'),
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
                    tableHeader("Advance Amount"),
                    tableHeader("Action"),
                  ]),
                  ...List.generate(filteredList.length, (index) {
                    final staff = filteredList[index];

                    double dueAmount = double.parse(staff['dueAmount']);

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
                                    'id': int.parse(staff['staffId']),
                                    'name': staff['staffName'],
                                    'monthlySalary': staff['monthlySalary'],
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
        'TransactionsPayroll/GetAdvanceSalaryAmountWithSTAFFPayroll?varlocationid=${Preference.getString(PrefKeys.locationId)}&dateto=${DateFormat('yyyy/MM/dd').format(DateTime.now())}');
    setState(() {
      staffList = response['due'];
    });
  }
}
