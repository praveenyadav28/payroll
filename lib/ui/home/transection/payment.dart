// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/ui/home/master/ledger/ledger_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen(
      {super.key, required this.paymentVoucherNo, required this.employeeData});
  int paymentVoucherNo = 0;
  Map<String, dynamic>? employeeData;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  //Controller
  TextEditingController pvNoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController sattlementSalaryController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController searchController = TextEditingController();

//Voucher
  List<Map<String, dynamic>> voucherList = [];
  String voucherName = '';
  Map<String, dynamic>? voucherValue;
  int? voucherId;

// Date
  TextEditingController pvDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));

  Map<String, dynamic> paymentDetails = {};
  String payableAmount = '';
  String monthlySalary = '';
  String dueBalance = '0';

  @override
  void initState() {
    fatchledger().then((value) => setState(() {
          fatchDueBalance().then((value) => setState(() {}));
          fatchPvNumber().then((value) => setState(() {
                widget.paymentVoucherNo == 0
                    ? null
                    : fatchPaymentDetails().then((value) => setState(() {
                          paidController.text = paymentDetails['cash_Amount'];
                          sattlementSalaryController.text =
                              paymentDetails['total_Amount'];
                          payableAmount = paymentDetails['other2'];
                          monthlySalary = paymentDetails['other3'];
                          remarkController.text = paymentDetails['other1'];
                          voucherId = paymentDetails['voucher_Mode_Id'];
                          voucherName = voucherList.firstWhere(
                              (element) => element['id'] == voucherId)['name'];
                        }));
              }));
        }));
    nameController.text = widget.employeeData!['name'];
    super.initState();
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
            centerTitle: true,
            title:
                const Text("Payment Voucher", overflow: TextOverflow.ellipsis)),
        body: OutsideContainer(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Sizes.width * 0.9),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: CommonTextFormField(
                                  controller: pvNoController,
                                  textInputType: TextInputType.number,
                                  labelText: 'Voucher No.*'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Column(
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
                                            pvDate.text =
                                                DateFormat('yyyy/MM/dd')
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
                            )
                          ],
                        ),
                        CommonTextFormField(
                            controller: nameController,
                            labelText: 'Staff Name*'),
                        ReuseContainer(
                            title: double.parse(dueBalance) < 0
                                ? "Advance Balance"
                                : 'Due Balance',
                            subtitle: "${double.parse(dueBalance).abs()}"),
                      ]),
                      widget.employeeData!['dueSalary'] == 0
                          ? Container()
                          : addMasterOutside(context: context, children: [
                              ReuseContainer(
                                  title: "Monthly Salary",
                                  subtitle:
                                      "${widget.employeeData!['monthlySalary']}"),
                              ReuseContainer(
                                  title: "Payabe Amount",
                                  subtitle:
                                      "${widget.employeeData!['dueSalary'].toStringAsFixed(2)}"),
                              CommonTextFormField(
                                controller: sattlementSalaryController,
                                labelText: "Sattlement Amount*",
                              ),
                            ]),
                      addMasterOutside(context: context, children: [
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
                                var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LedgerMasterScreen(
                                          isNew: true, ledgerId: 0),
                                    ));
                                if (result != null) {
                                  voucherValue = null;
                                  fatchledger()
                                      .then((value) => setState(() {}));
                                }
                              },
                            )
                          ],
                        ),
                        CommonTextFormField(
                            controller: remarkController, labelText: "Remark"),
                      ]),
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
                            } else if (widget.employeeData!['dueSalary'] == 0
                                ? false
                                : sattlementSalaryController.text.isEmpty) {
                              showCustomSnackbar(
                                  context, "Please enter Sattlement Amount");
                            } else if (nameController.text.isEmpty) {
                              showCustomSnackbar(
                                  context, "Please enter Staff Name");
                            } else if (voucherId == null) {
                              showCustomSnackbar(
                                  context, "Please select voucher mode");
                            } else {
                              postPayment();
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

//Post Payment
  Future postPayment() async {
    try {
      Map<String, dynamic> response = await ApiService.postData(
          widget.paymentVoucherNo == 0
              ? "TransactionsPayroll/PostPaymentVoucherPayroll"
              : "TransactionsPayroll/UpdatePaymentVoucherPayroll?prefix=online&refno=${pvNoController.text}&locationid=${Preference.getString(PrefKeys.locationId)}",
          {
            "Location_Id": int.parse(Preference.getString(PrefKeys.locationId)),
            "Prefix_Name": "online",
            "Pv_No": int.parse(pvNoController.text),
            "Payment_Date": pvDate.text.toString(),
            "Ledger_Id": int.parse("${widget.employeeData!['id']}"),
            "Ledger_Name": widget.employeeData!['name'],
            "Total_Amount": widget.employeeData!['dueSalary'] == 0
                ? "0"
                : sattlementSalaryController.text.toString(),
            "Cash_Amount": paidController.text.toString(),
            "Balance_Amount":
                "${double.parse(dueBalance) + double.parse(paidController.text.toString())}",
            "Voucher_Mode_Id": voucherId,
            "Mode": voucherName,
            "Cheque_No": "",
            "Other1": remarkController.text.toString(),
            "Other2": widget.employeeData!['dueSalary'] == 0
                ? '0'
                : "${widget.employeeData!['dueSalary'].toStringAsFixed(2)}",
            "Other3": "${widget.employeeData!['monthlySalary']}",
            "Other4": "4",
            "Other5": "5",
            "OtherNo1": 0,
            "OtherNo2": 0,
            "OtherNo3": 0,
            "OtherNo4": 0,
            "OtherNo5": 0,
          });
      if (response["result"] == true) {
        Navigator.pop(context, "For fatch data in last screen");
        showCustomSnackbarSuccess(context, response["message"]);
      } else {
        showCustomSnackbar(context, response["message"]);
      }
    } catch (e) {
      print("$e error");
    }
  }

//Get ledger List
  Future fatchledger() async {
    var responseVoucher = await ApiService.fetchData(
        "MasterPayroll/GetLedgerAllLocationWisePayroll?locationId=${Preference.getString(PrefKeys.locationId)}");

    voucherList =
        List<Map<String, dynamic>>.from(responseVoucher.map((item) => {
              'id': item['ledger_Id'],
              'name': item['ledger_Name'],
            }));
  }

//Get Invoice Number
  Future fatchPvNumber() async {
    var response = await ApiService.fetchData(
        "TransactionsPayroll/GetInvoiceNoPayroll?Tblname=Payment&Fldname=Pv_No&transdatefld=Payment_Date&varprefixtblname=Prefix_Name&prefixfldnText=%27online%27&varlocationid=${Preference.getString(PrefKeys.locationId)}");
    pvNoController.text = widget.paymentVoucherNo != 0
        ? "${widget.paymentVoucherNo}"
        : "$response";
  }

//Get Due Balance
  Future fatchDueBalance() async {
    var response = await ApiService.fetchData(
        "TransactionsPayroll/GetBalanceSalaryAmountPayroll?StaffId=${widget.employeeData!['id']}&locationid=${Preference.getString(PrefKeys.locationId)}&dateto=${pvDate.text}");
    dueBalance = "$response";
  }

//Payment Datails Get
  Future fatchPaymentDetails() async {
    paymentDetails = await ApiService.fetchData(
        'TransactionsPayroll/GetPaymentVoucherPayroll?prefix=online&refno=${pvNoController.text}&locationid=${Preference.getString(PrefKeys.locationId)}');
  }
}
