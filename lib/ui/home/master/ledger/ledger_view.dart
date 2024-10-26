import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/ui/home/master/ledger/ledger_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';

class LedgerViewScreen extends StatefulWidget {
  const LedgerViewScreen({super.key});

  @override
  State<LedgerViewScreen> createState() => _LedgerViewScreenState();
}

class _LedgerViewScreenState extends State<LedgerViewScreen> {
  List ledgerList = [];
  List<Map<String, dynamic>> cityList = [];

  List<Map<String, dynamic>> gestDealerList = [];

  @override
  void initState() {
    fetchCity().then((value) => setState(() {}));
    gstDealerData().then((value) => setState(() {}));
    getLedgerList().then((value) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ledger Master'),
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
                            await Navigator.pushNamed(context, '/ledger');
                        if (result != null) {
                          getLedgerList()
                              .then((value) => setState(() {})); // Refresh data
                        }
                      }),
                  const SizedBox(height: 3),
                  Text(
                    "Add Ledger",
                    style: TextStyle(fontSize: 11, color: AppColor.white),
                  )
                ],
              ),
            ),
          ],
        ),
        drawer: const SideMenu(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: Sizes.width * .05, vertical: Sizes.height * .02),
          child: Column(
            children: [
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
                  "Ledger List",
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
                      tableHeader("Name"),
                      tableHeader("City"),
                      tableHeader("Opening Balance"),
                      tableHeader("Credit Type"),
                      tableHeader("GST Type"),
                      tableHeader("GST Number"),
                      tableHeader("Actions"),
                    ]),
                    ...List.generate(ledgerList.length, (index) {
                      final ledger = ledgerList[index];
                      int cityId = ledger['city_Id'];
                      String cityName = cityList.firstWhere((element) =>
                          element['city_Id'] == cityId)['city_Name'];

                      int gstDealerId = ledger['gstTypeId'];
                      String gstDealerName = gestDealerList.firstWhere(
                          (element) => element['id'] == gstDealerId)['name'];

                      return TableRow(children: [
                        tableCell(ledger['ledger_Name']),
                        tableCell(cityName),
                        tableCell(ledger['opening_Bal']),
                        tableCell(ledger['opening_Bal_Combo']),
                        tableCell(gstDealerName),
                        tableCell("${ledger['gst_No']}"),
                        SizedBox(
                            height: Sizes.height * 0.07,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          color: AppColor.primery),
                                      onPressed: () async {
                                        var result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LedgerMasterScreen(
                                              isNew: false,
                                              ledgerId: ledger['ledger_Id'],
                                            ),
                                          ),
                                        );
                                        if (result != null) {
                                          getLedgerList().then((value) =>
                                              setState(() {})); // Refresh data
                                        }
                                      }),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteLedgerApi(ledger['ledger_Id'])
                                          .then((value) {
                                        getLedgerList()
                                            .then((value) => setState(() {}));
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ]);
                    })
                  ],
                ),
              )
            ],
          ),
        ));
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

// Get City List
  Future fetchCity() async {
    final response =
        await ApiService.fetchData("MasterPayroll/GetCityAllDetailsPayroll");

    if (response is List) {
      // Assuming it's a list, convert each item to a Map
      cityList = response.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected data format for citys');
    }
  }

  Future getLedgerList() async {
    ledgerList = await ApiService.fetchData(
        "MasterPayroll/GetLedgerAllLocationWisePayroll?locationId=3");
  }

  //Delete Ledger
  Future deleteLedgerApi(int? ledgerId) async {
    var response = await ApiService.postData(
        "MasterPayroll/DeleteLedgerByIdPayroll?LedgerId=$ledgerId", {});
    if (response['status'] == false) {
      showCustomSnackbar(context, response['message']);
    } else {
      showCustomSnackbarSuccess(context, response['message']);
    }
  }

// Get Gst Dealer
  Future<void> gstDealerData() async {
    await fetchDataByMiscMaster(20, gestDealerList);
  }
}
