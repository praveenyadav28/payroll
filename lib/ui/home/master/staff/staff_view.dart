// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/model/staff.dart';
import 'package:payroll/ui/home/master/staff/staff_master.dart';
import 'package:payroll/ui/home/transection/payment.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class StaffViewScreen extends StatefulWidget {
  StaffViewScreen({required this.staffListType, super.key});
  bool staffListType = true;
  @override
  State<StaffViewScreen> createState() => _StaffViewScreenState();
}

class _StaffViewScreenState extends State<StaffViewScreen> {
  TextEditingController searchController = TextEditingController();
  List<Staff> staffList = [];
  List<Staff> filteredList = [];
  List<Map<String, dynamic>> deginationList = [];

  @override
  void initState() {
    super.initState();
    deginationData().then((_) => setState(() {}));
    getStaffList().then((_) => setState(() {}));
  }

  void filterList(String searchText) {
    setState(() {
      filteredList = staffList.where((value) {
        return value.name.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }

  String _convertedTime = '';

  void _convertDoubleToTime(String hours) {
    String input = hours;
    if (input.isEmpty) {
      setState(() {
        _convertedTime = '';
      });
      return;
    }

    try {
      double inputDouble = double.parse(input);

      int hours = inputDouble.floor();
      double minutesDouble = (inputDouble - hours) * 60;
      int minutes = minutesDouble.round();

      setState(() {
        _convertedTime =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() {
        _convertedTime = 'Invalid input. Please enter a valid double value.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.staffListType == false ? 'Direct Payment' : 'Staff Master'),
        flexibleSpace: const OutsideContainer(child: Column()),
        centerTitle: true,
        actions: [
          widget.staffListType == false
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(right: 20, top: 5),
                  child: Column(
                    children: [
                      CustomButton(
                        width: 30,
                        height: 30,
                        text: "+",
                        press: () async {
                          var result =
                              await Navigator.pushNamed(context, '/staff');
                          if (result != null) {
                            getStaffList().then(
                                (value) => setState(() {})); // Refresh data
                          }
                        },
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Add Staff",
                        style: TextStyle(fontSize: 11, color: AppColor.white),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      drawer: const SideMenu(),
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
                    var staff = filteredList[index];
                    _convertDoubleToTime(staff.workingHours);
                    int deginationId = staff.designationId;
                    String deginationName = deginationList.isEmpty
                        ? ''
                        : deginationList.firstWhere(
                            (element) => element['id'] == deginationId)['name'];

                    return Container(
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
                          ExpansionTile(
                            title: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 7.5),
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    color: AppColor.primery,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Text(
                                  staff.biomaxId,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                              title: Text(
                                staff.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.black,
                                ),
                              ),
                            ),
                            children: [
                              datastylerow("Degination", deginationName),
                              datastylerow("Mobile No.", staff.mobile),
                              datastylerow(
                                  "Monthly Salary", staff.monthlySalary),
                              datastylerow("Working Hour", _convertedTime),
                              widget.staffListType == false
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor.primery),
                                      child: Text("Payment",
                                          style: TextStyle(
                                              color: AppColor.white,
                                              fontSize: 16)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                                paymentVoucherNo: 0,
                                                employeeData: {
                                                  'id': staff.id,
                                                  'name': staff.name,
                                                  'monthlySalary':
                                                      staff.monthlySalary,
                                                  'dueSalary': 0,
                                                }),
                                          ),
                                        );
                                      },
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                var result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StaffMasterScreen(
                                                            isNew: false,
                                                            staffId: staff.id),
                                                  ),
                                                );
                                                if (result != null) {
                                                  getStaffList().then((value) =>
                                                      setState(
                                                          () {})); // Refresh data
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColor.primery),
                                              child: Text(
                                                "Edit",
                                                style: TextStyle(
                                                    color: AppColor.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: Sizes.width * 0.05),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delete Staff'),
                                                    content: const Text(
                                                        "Are you sure you want to delete this staff from the list?"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Closes the dialog
                                                        },
                                                        child: const Text('No'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteStaffApi(
                                                                  staff.id)
                                                              .then((_) {
                                                            getStaffList().then(
                                                                (value) =>
                                                                    setState(
                                                                        () {}));
                                                          });
                                                        },
                                                        child:
                                                            const Text('Yes'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColor.red),
                                              child: Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: AppColor.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                              SizedBox(height: Sizes.height * 0.02)
                            ],
                          )
                        ],
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
                              tableHeader("Working Hours"),
                              tableHeader("Action"),
                            ]),
                            ...List.generate(filteredList.length, (index) {
                              final staff = filteredList[index];
                              _convertDoubleToTime(staff.workingHours);
                              int deginationId = staff.designationId;
                              String deginationName = deginationList.isEmpty
                                  ? ''
                                  : deginationList.firstWhere((element) =>
                                      element['id'] == deginationId)['name'];

                              return TableRow(children: [
                                tableCell(staff.name),
                                tableCell(deginationName),
                                tableCell(staff.biomaxId),
                                tableCell(staff.mobile),
                                tableCell(staff.monthlySalary),
                                tableCell(_convertedTime),
                                SizedBox(
                                  height: Sizes.height * 0.07,
                                  child: Center(
                                    child: widget.staffListType == false
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.receipt,
                                              color: AppColor.primery,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentScreen(
                                                          paymentVoucherNo: 0,
                                                          employeeData: {
                                                        'id': staff.id,
                                                        'name': staff.name,
                                                        'monthlySalary':
                                                            staff.monthlySalary,
                                                        'dueSalary': 0,
                                                      }),
                                                ),
                                              );
                                            },
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: AppColor.primery,
                                                ),
                                                onPressed: () async {
                                                  var result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StaffMasterScreen(
                                                              isNew: false,
                                                              staffId:
                                                                  staff.id),
                                                    ),
                                                  );
                                                  if (result != null) {
                                                    getStaffList().then(
                                                        (value) => setState(
                                                            () {})); // Refresh data
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          'Delete Staff'),
                                                      content: const Text(
                                                          "Are you sure you want to delete this staff from the list?"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Closes the dialog
                                                          },
                                                          child:
                                                              const Text('No'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deleteStaffApi(
                                                                    staff.id)
                                                                .then((_) {
                                                              getStaffList().then(
                                                                  (value) =>
                                                                      setState(
                                                                          () {}));
                                                            });
                                                          },
                                                          child:
                                                              const Text('Yes'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
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

  Future<void> deginationData() async {
    await fetchDataByMiscMaster(28, deginationList);
  }

  Future<void> getStaffList() async {
    final response = await ApiService.fetchData(
        "MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=${Preference.getString(PrefKeys.locationId)}");

    // Assuming the response is a list of maps
    staffList = (response as List)
        .map((staffData) => Staff.fromJson(staffData))
        .toList();
    setState(() {
      filteredList = staffList;
    });
  }

  // Delete Staff
  Future<void> deleteStaffApi(int staffId) async {
    var response = await ApiService.postData(
        "MasterPayroll/DeleteStaffByIdPayroll?Id=$staffId", {});
    if (response['status'] == false) {
      setState(() {});
      showCustomSnackbar(context, response['message']);
    } else {
      showCustomSnackbarSuccess(context, response['message']);
    }
  }
}
