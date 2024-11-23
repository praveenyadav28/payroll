import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/model/branch.dart';
import 'package:payroll/ui/home/master/branch/branch_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:http/http.dart' as http;

class BranchViewScreen extends StatefulWidget {
  const BranchViewScreen({super.key});

  @override
  State<BranchViewScreen> createState() => _BranchViewScreenState();
}

class _BranchViewScreenState extends State<BranchViewScreen> {
  late StreamController<List<Branch>> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _fetchBranchesAndStream(); // Start fetching data and streaming it
  }

  // Fetch branches and add data to the stream
  Future<void> _fetchBranchesAndStream() async {
    try {
      List<Branch> branches = await fetchBranches();
      _streamController.add(branches); // Add data to the stream
    } catch (error) {
      _streamController.addError(error); // Add error to the stream
    }
  }

  @override
  void dispose() {
    _streamController.close(); // Close the stream when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Master'),
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
                      var result =
                          await Navigator.pushNamed(context, '/branch');
                      if (result != null) {
                        _fetchBranchesAndStream(); // Refresh data
                      }
                    }),
                const SizedBox(height: 3),
                Text(
                  "Add Branch",
                  style: TextStyle(fontSize: 11, color: AppColor.white),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const SideMenu(),
      body: StreamBuilder<List<Branch>>(
        stream: _streamController.stream, // Stream of branches
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No branches available'));
          }

          // List of branches
          final branchList = snapshot.data!;

          return SingleChildScrollView(
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
                      "Branch List",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Table(
                  border: TableBorder.all(
                    borderRadius: BorderRadius.circular(0),
                    color: const Color(0xff377785),
                  ),
                  children: [
                    TableRow(
                      children: [
                        tableHeader("Branch Name"),
                        tableHeader("City"),
                        tableHeader("Biomax Serial No."),
                        tableHeader("Device Name"),
                        tableHeader("Email Id"),
                        tableHeader("Password"),
                        tableHeader("Actions"),
                      ],
                    ),
                  ],
                ),
                Table(
                  border: TableBorder.all(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: const Color(0xff377785),
                  ),
                  children: branchList.map((branch) {
                    return TableRow(
                      children: [
                        tableCell(branch.bLocationName),
                        tableCell(branch.bCityName ?? 'N/A'),
                        tableCell(branch.bDeviceSerialNo ?? 'N/A'),
                        tableCell(branch.bDeviceName ?? 'N/A'),
                        tableCell(branch.bEmailId ?? 'N/A'),
                        tableCell(branch.other1 ?? 'N/A'),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: AppColor.primery),
                                onPressed: () async {
                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BranchMasterScreen(
                                        isNew: false,
                                        branchId: branch.bid,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    _fetchBranchesAndStream(); // Refresh data
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: AppColor.red),
                                onPressed: () {
                                  deleteBranchApi(branch.bid).then(
                                    (value) => _fetchBranchesAndStream(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
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

  // Fetch branches from API
  Future<List<Branch>> fetchBranches() async {
    final response = await http.get(Uri.parse(
        "http://lms.muepetro.com/api/MasterPayroll/GetBranchPayroll"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Branch.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load branches');
    }
  }

  // Delete Branch
  Future<void> deleteBranchApi(int? branchId) async {
    var response = await ApiService.postData(
        "MasterPayroll/DeleteBranchByIdPayroll?Id=$branchId", {});
    if (response['status'] == false) {
      showCustomSnackbar(context, response['message']);
    } else {
      showCustomSnackbarSuccess(context, response['message']);
    }
  }
}
