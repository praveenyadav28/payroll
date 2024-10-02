// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({super.key, required this.paymentVoucherNo});
  int paymentVoucherNo = 0;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Map<String, dynamic>> staffList = [];

  // Function to add a new staff
  void addStaff() {
    setState(() {
      staffList.add({
        'staffName': 'John Doe', // Placeholder for staff name
        'monthlySalary': 10000, // Placeholder for monthly salary
        'dueSalary': 2000, // Placeholder for due salary
        'thisMonthSalary': 8000, // Placeholder for this month's salary
      });
    });
  }

  // Function to remove a staff
  void removeStaff(int index) {
    setState(() {
      staffList.removeAt(index);
    });
  }

  //Controller
  TextEditingController pvNoController = TextEditingController();
  TextEditingController chequeController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  //Ledger
  List<Map<String, dynamic>> ledgerList = [];
  String ledgerName = '';
  Map<String, dynamic>? ledgerValue;
  int? ledgerId;

  List<Map<String, dynamic>> voucherList = [];
  String voucherName = '';
  Map<String, dynamic>? voucherValue;
  int? voucherId;

  Map<String, dynamic> companyDetails = {};
  Map<String, dynamic> paymentDetails = {};
// Date
  TextEditingController pvDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));

  @override
  void initState() {
    // fatchledger().then((value) => setState(() {
    //       fatchPvNumber().then((value) => setState(() {
    //             widget.paymentVoucherNo == 0
    //                 ? null
    //                 : fatchPaymentDetails().then((value) => setState(() {
    //                       chequeController.text = paymentDetails['cheque_No'];
    //                       paidController.text = paymentDetails['cash_Amount'];
    //                       remarkController.text =
    //                           paymentDetails['other1'] ?? "";
    //                       ledgerId = paymentDetails['ledger_Id'];
    //                       ledgerName = paymentDetails['ledger_Name'];
    //                       voucherId = paymentDetails['voucher_Mode_Id'];
    //                       voucherName = voucherList.firstWhere(
    //                           (element) => element['id'] == voucherId)['name'];
    //                     }));
    //           }));
    //     }));
    // getAccountDetails().then((value) => setState(() {}));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: const OutsideContainer(child: Column()),
            centerTitle: true,
            title:
                const Text("Payment Voucher", overflow: TextOverflow.ellipsis)),
        body: OutsideContainer(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Sizes.width * 0.9,
              ),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Sizes.height * 0.02,
                      horizontal: Sizes.width * .03),
                  child: Column(
                    children: [
                      addMasterOutside(context: context, children: [
                        CommonTextFormField(
                            controller: pvNoController,
                            textInputType: TextInputType.number,
                            labelText: 'Payment Voucher No.*'),
                        Column(
                          children: [
                            dropdownTextfield(
                              context,
                              "Payment Voucher Date",
                              InkWell(
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2500),
                                  ).then((selectedDate) {
                                    if (selectedDate != null) {
                                      pvDate.text = DateFormat('yyyy/MM/dd')
                                          .format(selectedDate);
                                    }
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pvDate.text,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.black),
                                    ),
                                    Icon(Icons.edit_calendar,
                                        color: AppColor.black)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                      addMasterOutside(context: context, children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: dropdownTextfield(
                                  context,
                                  "Customer A/C*",
                                  searchDropDown(
                                      context,
                                      widget.paymentVoucherNo == 0
                                          ? "Select Customer Account*"
                                          : ledgerName,
                                      ledgerList
                                          .map((item) => DropdownMenuItem(
                                                onTap: () {
                                                  ledgerId = item['id'];
                                                  ledgerName = item['name'];
                                                },
                                                value: item,
                                                child: Text(
                                                  item['name'].toString(),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColor.black),
                                                ),
                                              ))
                                          .toList(),
                                      ledgerValue,
                                      (value) {
                                        setState(() {
                                          ledgerValue = value;
                                        });
                                      },
                                      searchController,
                                      (value) {
                                        setState(() {
                                          ledgerList
                                              .where((item) => item['name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(
                                                      value.toLowerCase()))
                                              .toList();
                                        });
                                      },
                                      'Search for a Customer...',
                                      (isOpen) {
                                        if (!isOpen) {
                                          searchController.clear();
                                        }
                                      })),
                            ),
                            const SizedBox(width: 10),
                            addDefaultButton(
                              context,
                              () async {
                                // var result = await pushTo(LedgerMaster(groupId: 10));
                                // if (result != null) {
                                //   ledgerValue = null;
                                //   fatchledger().then((value) => setState(() {}));
                                // }
                              },
                            )
                          ],
                        ),
                        CommonTextFormField(
                          controller: paidController,
                          labelText: "Paid Amount*",
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: dropdownTextfield(
                                  context,
                                  "Voucher Mode*",
                                  searchDropDown(
                                      context,
                                      voucherName.isEmpty
                                          ? "Select Voucher Mode*"
                                          : voucherName,
                                      voucherList
                                          .map((item) => DropdownMenuItem(
                                                onTap: () {
                                                  voucherId = item['id'];
                                                  voucherName = item['name'];
                                                },
                                                value: item,
                                                child: Text(
                                                  item['name'].toString(),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColor.black),
                                                ),
                                              ))
                                          .toList(),
                                      voucherValue,
                                      (value) {
                                        setState(() {
                                          voucherValue = value;
                                        });
                                      },
                                      searchController,
                                      (value) {
                                        setState(() {
                                          voucherList
                                              .where((item) => item['name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(
                                                      value.toLowerCase()))
                                              .toList();
                                        });
                                      },
                                      'Search for a voucher...',
                                      (isOpen) {
                                        if (!isOpen) {
                                          searchController.clear();
                                        }
                                      })),
                            ),
                            const SizedBox(width: 10),
                            addDefaultButton(
                              context,
                              () async {
                                // var result = await pushTo(LedgerMaster(groupId: 7));
                                // if (result != null) {
                                //   voucherValue = null;
                                //   fatchledger().then((value) => setState(() {}));
                                // }
                              },
                            )
                          ],
                        ),
                        CommonTextFormField(
                            controller: chequeController,
                            labelText: "Cheque Number"),
                        CommonTextFormField(
                            controller: remarkController, labelText: "Remark"),
                        Column(
                          children: [
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: addStaff,
                                child: Text('Add Staff'),
                              ),
                            ),
                          ],
                        ),
                      ]),
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                                label: Center(child: Text('Staff Name'))),
                            DataColumn(
                                label: Center(child: Text('Monthly Salary'))),
                            DataColumn(
                                label: Center(child: Text('Due Salary'))),
                            DataColumn(
                                label:
                                    Center(child: Text('This Month Salary'))),
                            DataColumn(label: Center(child: Text('Action'))),
                          ],
                          rows: List<DataRow>.generate(
                            staffList.length,
                            (index) => DataRow(
                              cells: <DataCell>[
                                DataCell(Center(
                                    child:
                                        Text(staffList[index]['staffName']))),
                                DataCell(Center(
                                  child: Text(staffList[index]['monthlySalary']
                                      .toString()),
                                )),
                                DataCell(Center(
                                  child: Text(
                                      staffList[index]['dueSalary'].toString()),
                                )),
                                DataCell(Center(
                                  child: Text(staffList[index]
                                          ['thisMonthSalary']
                                      .toString()),
                                )),
                                DataCell(
                                  Center(
                                    child: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        removeStaff(index);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      CustomButton(
                          text: "Save",
                          height: 52,
                          width: double.infinity,
                          press: () {
                            if (pvNoController.text.isEmpty) {
                              showCustomSnackbar(
                                  context, "Please enter PV Number");
                            } else if (paidController.text.isEmpty) {
                              showCustomSnackbar(
                                  context, "Please enter Paid Amount");
                            } else if (ledgerId == null) {
                              showCustomSnackbar(
                                  context, "Please select customer");
                            } else if (voucherId == null) {
                              showCustomSnackbar(
                                  context, "Please select voucher mode");
                            } else {
                              // postPayment();
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

// //Post Payment
//   Future postPayment() async {
//     try {
//       Map<String, dynamic> response = await ApiService.postData(
//           widget.paymentVoucherNo == 0
//               ? "Transactions/PostPaymentVoucherAW"
//               : "Transactions/UpdatePaymentVoucherAW?prefix=online&refno=${widget.paymentVoucherNo}&locationid=${Preference.getString(PrefKeys.locationId)}",
//           {
//             "Location_Id": int.parse(Preference.getString(PrefKeys.locationId)),
//             "Prefix_Name": "online",
//             "Pv_No": int.parse(pvNoController.text),
//             "Payment_Date": pvDate.text.toString(),
//             "Ledger_Id": ledgerId,
//             "Ledger_Name": ledgerName,
//             "Total_Amount": "",
//             "Cash_Amount": paidController.text.toString(),
//             "Balance_Amount": "0",
//             "Voucher_Mode_Id": voucherId,
//             "Mode": voucherName,
//             "Cheque_No": chequeController.text.toString(),
//             "Other1": remarkController.text.toString(),
//             "Other2": "2",
//             "Other3": "3",
//             "Other4": "4",
//             "Other5": "5",
//             "OtherNo1": 0,
//             "OtherNo2": 0,
//             "OtherNo3": 0,
//             "OtherNo4": 0,
//             "OtherNo5": 0
//           });
//       if (response["result"] == true) {
//         widget.paymentVoucherNo == 0
//             ? null
//             : Navigator.pop(context, "For fatch data in last screen");
//         fatchPaymentDetails().then((value) => setState(() {
//               generatePaymentPDF(0, companyDetails, paymentDetails);
//             }));
//         fatchPvNumber().then((value) => setState(() {}));
//         remarkController.clear();
//         paidController.clear();
//         chequeController.clear();
//         showCustomSnackbarSuccess(context, response["message"]);
//       } else {
//         showCustomSnackbar(context, response["message"]);
//       }
//     } catch (e) {
//       print("$e error");
//     }
//   }

// //Get ledger List
//   Future fatchledger() async {
//     var response = await ApiService.fetchData(
//         "MasterAW/GetLedgerByGroupId?LedgerGroupId=9,10");
//     var responseVoucher = await ApiService.fetchData(
//         "MasterAW/GetLedgerByGroupId?LedgerGroupId=7,8,11");

//     ledgerList = List<Map<String, dynamic>>.from(response.map((item) => {
//           'id': item['ledger_Id'],
//           'name': item['ledger_Name'],
//           "opening_Bal": item["opening_Bal"],
//         }));

//     voucherList =
//         List<Map<String, dynamic>>.from(responseVoucher.map((item) => {
//               'id': item['ledger_Id'],
//               'name': item['ledger_Name'],
//             }));
//   }

// //Fatch Company Details
//   Future getAccountDetails() async {
//     companyDetails = await ApiService.fetchData(
//         "MasterAW/GetLocationByIdAW?LocationId=${Preference.getString(PrefKeys.locationId)}");
//   }

// //Get Invoice Number
//   Future fatchPvNumber() async {
//     var response = await ApiService.fetchData(
//         "Transactions/GetInvoiceNoAW?Tblname=Payment&Fldname=Pv_No&transdatefld=Payment_Date&varprefixtblname=Prefix_Name&prefixfldnText=%27online%27&varlocationid=${Preference.getString(PrefKeys.locationId)}");
//     pvNoController.text = widget.paymentVoucherNo != 0
//         ? "${widget.paymentVoucherNo}"
//         : "$response";
//   }

// //Payment Datails Get
//   Future fatchPaymentDetails() async {
//     paymentDetails = await ApiService.fetchData(
//         'Transactions/GetPaymentVoucherAW?prefix=online&refno=${pvNoController.text}&locationid=${Preference.getString(PrefKeys.locationId)}');
//   }
}
