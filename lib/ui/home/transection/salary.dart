// screens/salary_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/textformfield.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  TextEditingController _voucherController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List staffList = [];
  List<Map<String, dynamic>> deginationList = [];

  List<Map<String, dynamic>> branchList = [];
  int? branchId;
  String branchName = '';
  Map<String, dynamic>? branchValue;

  List<Map<String, dynamic>> monthList = [
    {'id': 1, 'name': 'January'},
    {'id': 2, 'name': 'February'},
    {'id': 3, 'name': 'March'},
    {'id': 4, 'name': 'Aprail'},
    {'id': 5, 'name': 'May'},
    {'id': 6, 'name': 'June'},
    {'id': 7, 'name': 'July'},
    {'id': 8, 'name': 'August'},
    {'id': 9, 'name': 'September'},
    {'id': 10, 'name': 'October'},
    {'id': 11, 'name': 'November'},
    {'id': 12, 'name': 'December'},
  ];
  int? monthId;
  String monthName = '';
  Map<String, dynamic>? monthValue;

  //Date
  TextEditingController voucherDatePicker = TextEditingController(
    text: DateFormat('yyyy/MM/dd').format(DateTime.now()),
  );
  TextEditingController fromDatePicker = TextEditingController(
    text: DateFormat('yyyy/MM/dd').format(DateTime.now()),
  );
  TextEditingController toDatePicker = TextEditingController(
    text: DateFormat('yyyy/MM/dd').format(DateTime.now()),
  );

  @override
  void initState() {
    deginationData().then((value) => setState(() {}));
    branchData().then((value) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Salary Voucher'),
        flexibleSpace: const OutsideContainer(child: Column()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: Sizes.width * .05, vertical: Sizes.height * .02),
        child: Column(
          children: [
            addMasterOutside(children: [
              Column(children: [
                dropdownTextfield(
                  context,
                  "Voucher Date",
                  InkWell(
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((selectedDate) {
                        if (selectedDate != null) {
                          voucherDatePicker.text =
                              DateFormat('yyyy/MM/dd').format(selectedDate);
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          voucherDatePicker.text,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColor.black),
                        ),
                        Icon(Icons.edit_calendar, color: AppColor.black)
                      ],
                    ),
                  ),
                ),
              ]),
              CommonTextFormField(
                controller: _voucherController,
                labelText: 'Voucher No.',
                hintText: 'Voucher No.',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dropdownTextfield(
                      context,
                      "Branch",
                      searchDropDown(
                          context,
                          "Select Branch",
                          branchList
                              .map((item) => DropdownMenuItem(
                                    onTap: () {
                                      setState(() {
                                        branchId = item['bid'];
                                        branchName = item['bLocation_Name'];
                                      });
                                    },
                                    value: item,
                                    child: Text(
                                      item['bLocation_Name'].toString(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.black),
                                    ),
                                  ))
                              .toList(),
                          branchValue,
                          (value) {
                            setState(() {
                              branchValue = value;
                            });
                          },
                          searchController,
                          (value) {
                            setState(() {
                              branchList
                                  .where((item) => item['name']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          'Search for a branch...',
                          (isOpen) {
                            if (!isOpen) {
                              searchController.clear();
                            }
                          })),
                ],
              ),
              Column(children: [
                dropdownTextfield(
                  context,
                  "From Date",
                  InkWell(
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((selectedDate) {
                        if (selectedDate != null) {
                          fromDatePicker.text =
                              DateFormat('yyyy/MM/dd').format(selectedDate);
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fromDatePicker.text,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColor.black),
                        ),
                        Icon(Icons.edit_calendar, color: AppColor.black)
                      ],
                    ),
                  ),
                ),
              ]),
              Column(children: [
                dropdownTextfield(
                  context,
                  "To Date",
                  InkWell(
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((selectedDate) {
                        if (selectedDate != null) {
                          toDatePicker.text =
                              DateFormat('yyyy/MM/dd').format(selectedDate);
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          toDatePicker.text,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColor.black),
                        ),
                        Icon(Icons.edit_calendar, color: AppColor.black)
                      ],
                    ),
                  ),
                ),
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dropdownTextfield(
                      context,
                      "Month",
                      searchDropDown(
                          context,
                          "Select Month",
                          monthList
                              .map((item) => DropdownMenuItem(
                                    onTap: () {
                                      setState(() {
                                        monthId = item['id'];
                                        monthName = item['name'];
                                      });
                                    },
                                    value: item,
                                    child: Text(
                                      item['name'].toString(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.black),
                                    ),
                                  ))
                              .toList(),
                          monthValue,
                          (value) {
                            setState(() {
                              monthValue = value;
                            });
                          },
                          searchController,
                          (value) {
                            setState(() {
                              monthList
                                  .where((item) => item['name']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          'Search for a month...',
                          (isOpen) {
                            if (!isOpen) {
                              searchController.clear();
                            }
                          })),
                ],
              ),
              Column(
                children: [
                  DefaultButton(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      branchId != null
                          ? getStaffList(branchId!)
                              .then((value) => setState(() {}))
                          : null;
                    },
                    hight: 50,
                    width: double.infinity,
                    boxShadow: const [BoxShadow()],
                    child: Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColor.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ], context: context),
            SizedBox(height: Sizes.height * 0.02),
            Container(
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
                "Salary List",
                style: TextStyle(
                    fontSize: 16,
                    color: AppColor.black,
                    fontWeight: FontWeight.bold),
              )),
            ),
            SizedBox(
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
                            child: Text("Designation",
                                style: TextStyle(
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold)))),
                    SizedBox(
                        height: Sizes.height * 0.05,
                        child: Center(
                            child: Text("Mobile",
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
                            child: Text("This month Salary",
                                style: TextStyle(
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold)))),
                    SizedBox(
                        height: Sizes.height * 0.05,
                        child: Center(
                            child: Text("Due Salary",
                                style: TextStyle(
                                    color: AppColor.black,
                                    fontWeight: FontWeight.bold)))),
                    SizedBox(
                        height: Sizes.height * 0.05,
                        child: Center(
                            child: Text("Date",
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
                  ...List.generate(staffList.length, (index) {
                    final staff = staffList[index];
                    int deginationId = staff['staff_Degination_Id'];
                    String deginationName = deginationList.firstWhere(
                        (element) => element['id'] == deginationId)['name'];

                    return TableRow(children: [
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                              child: Text(staffList[index]['staff_Name'],
                                  style: TextStyle(color: AppColor.black)))),
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                              child: Text(deginationName,
                                  style: TextStyle(color: AppColor.black)))),
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                              child: Text(staff['mob'].toString(),
                                  style: TextStyle(color: AppColor.black)))),
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                              child: Text("17000",
                                  style: TextStyle(color: AppColor.black)))),
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                              child: Text("14500",
                                  style: TextStyle(color: AppColor.black)))),
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                              child: Text("14500",
                                  style: TextStyle(color: AppColor.black)))),
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                              child: Text("12 Jan 2024",
                                  style: TextStyle(color: AppColor.black)))),
                      SizedBox(
                          height: Sizes.height * 0.07,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.visibility,
                                  color: AppColor.primery),
                              onPressed: () {
                                // Handle edit action
                              },
                            ),
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

  Future<void> deginationData() async {
    await fetchDataByMiscMaster(
      28,
      deginationList,
    );
  }

  Future getStaffList(int branchID) async {
    staffList = await ApiService.fetchData(
        "MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=$branchID");
  }

// Get Branch List
  Future branchData() async {
    final response =
        await ApiService.fetchData("MasterPayroll/GetBranchPayroll");

    if (response is List) {
      // Assuming it's a list, convert each item to a Map
      branchList =
          response.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected data format for citys');
    }
  }
}
