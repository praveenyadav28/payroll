import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/model/staff.dart';
import 'package:payroll/ui/home/master/staff/staff_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';

class StaffViewScreen extends StatefulWidget {
  const StaffViewScreen({super.key});

  @override
  State<StaffViewScreen> createState() => _StaffViewScreenState();
}

class _StaffViewScreenState extends State<StaffViewScreen> {
  List<Staff> staffList = [];
  List<Map<String, dynamic>> deginationList = [];
  @override
  void initState() {
    super.initState();
    deginationData().then((_) => setState(() {}));
    getStaffList().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Master'),
        flexibleSpace: const OutsideContainer(child: Column()),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 5),
            child: Column(
              children: [
                CustomButton(
                  width: 30,
                  height: 30,
                  text: "+",
                  press: () async {
                    var result = await Navigator.pushNamed(context, '/staff');
                    if (result != null) {
                      getStaffList()
                          .then((value) => setState(() {})); // Refresh data
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
                    tableHeader("Action"),
                  ]),
                  ...List.generate(staffList.length, (index) {
                    final staff = staffList[index];
                    int deginationId = staff.designationId;
                    String deginationName = deginationList.isEmpty
                        ? ''
                        : deginationList.firstWhere(
                            (element) => element['id'] == deginationId)['name'];

                    return TableRow(children: [
                      tableCell(staff.name),
                      tableCell(deginationName),
                      tableCell(staff.biomaxId),
                      tableCell(staff.mobile),
                      tableCell(staff.monthlySalary),
                      SizedBox(
                        height: Sizes.height * 0.07,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColor.primery,
                                ),
                                onPressed: () async {
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StaffMasterScreen(
                                          isNew: false, staffId: staff.id),
                                    ),
                                  );
                                  if (result != null) {
                                    getStaffList().then((value) =>
                                        setState(() {})); // Refresh data
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteStaffApi(staff.id).then((_) {
                                    getStaffList()
                                        .then((value) => setState(() {}));
                                  });
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
        "MasterPayroll/GetStaffDetailsLocationwisePayroll?locationId=3");

    // Assuming the response is a list of maps
    staffList = (response as List)
        .map((staffData) => Staff.fromJson(staffData))
        .toList();
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
