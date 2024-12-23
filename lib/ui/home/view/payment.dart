// ignore_for_file: prefer_is_empty

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/model/payment_model.dart';
import 'package:payroll/ui/home/transection/payment.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/utils/textformfield.dart';

class PaymentViewScreen extends StatefulWidget {
  const PaymentViewScreen({super.key});

  @override
  State<PaymentViewScreen> createState() => _PaymentViewScreenState();
}

class _PaymentViewScreenState extends State<PaymentViewScreen> {
  late StreamController<List<PaymentModel>> _streamController;

  TextEditingController fromDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));
  TextEditingController toDate = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(DateTime.now()));
  TextEditingController searchController = TextEditingController();

  List<PaymentModel> _allPayments = []; // List to hold all payments
  List<PaymentModel> _filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _fetchPaymentsAndStream(); // Start fetching data and streaming it

    searchController.addListener(_filterPaymentsByName);
  }

  // Filter payments based on the search input
  void _filterPaymentsByName() {
    String query = searchController.text.toLowerCase();
    setState(() {
      _filteredPayments = _allPayments
          .where((payment) =>
              payment.ledgerName!.toLowerCase().contains(query) ||
              payment.mode!.toLowerCase().contains(
                  query)) // Assuming `name` is a field in PaymentModel
          .toList();

      totalAmount = _filteredPayments.fold(
          0, (sum, payment) => sum + double.parse(payment.cashAmount!));
      _streamController.add(_filteredPayments);
    });
  }

  double totalAmount = 0;
  // Fetch payments and add data to the stream
  Future<void> _fetchPaymentsAndStream() async {
    try {
      List<PaymentModel> payments = await fetchPayments();
      _allPayments = payments;
      _filteredPayments = payments;

      totalAmount = _filteredPayments.fold(
          0, (sum, payment) => sum + double.parse(payment.cashAmount!));
      _streamController.add(payments); // Add data to the stream
    } catch (error) {
      _streamController.addError(error); // Add error to the stream
    }
  }

  @override
  void dispose() {
    _streamController.close();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment View'),
        flexibleSpace: const OutsideContainer(child: Column()),
        centerTitle: true,
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
              Column(
                children: [
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
                          lastDate: DateTime(2500),
                        ).then((selectedDate) {
                          if (selectedDate != null) {
                            fromDate.text =
                                DateFormat('yyyy/MM/dd').format(selectedDate);
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fromDate.text,
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
                ],
              ),
              Column(
                children: [
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
                          lastDate: DateTime(2500),
                        ).then((selectedDate) {
                          if (selectedDate != null) {
                            toDate.text =
                                DateFormat('yyyy/MM/dd').format(selectedDate);
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            toDate.text,
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
                ],
              ),
              Column(
                children: [
                  CustomButton(
                      width: double.infinity,
                      height: 50,
                      text: "Save",
                      press: () {
                        _fetchPaymentsAndStream();
                      }),
                ],
              )
            ], context: context),
            addMasterOutside(children: [
              CommonTextFormField(
                controller: searchController,
                labelText: "Search by Name or Mode",
                hintText: "Search by Name or Mode",
                onchanged: (value) {
                  setState(() {
                    _filterPaymentsByName();
                  });
                },
              )
            ], context: context),
            StreamBuilder<List<PaymentModel>>(
              stream: _streamController.stream, // Stream of Payments
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Payments available'));
                }

                // List of Payments
                final paymentList = snapshot.data!;

                return Column(
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
                          "Payment List",
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
                            tableHeader("PV Number"),
                            tableHeader("PV Date"),
                            tableHeader("Name"),
                            tableHeader("Paid Amount"),
                            tableHeader("Mode"),
                            tableHeader("Action"),
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
                        children: [
                          ...paymentList.map((payment) {
                            return TableRow(
                              children: [
                                tableCell("${payment.pvNo}"),
                                tableCell(payment.paymentDate!.substring(
                                    0, payment.paymentDate!.length - 12)),
                                tableCell(payment.ledgerName ?? 'N/A'),
                                tableCell(payment.cashAmount ?? 'N/A'),
                                tableCell(payment.mode ?? 'N/A'),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: AppColor.green),
                                        onPressed: () async {
                                          var result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PaymentScreen(
                                                paymentVoucherNo: payment.pvNo!,
                                                employeeData: {
                                                  'id': payment.ledgerId,
                                                  'name': payment.ledgerName,
                                                  'monthlySalary': double.parse(
                                                      payment.other3!.length ==
                                                              0
                                                          ? '0'
                                                          : payment.other3!),
                                                  'dueSalary': double.parse(
                                                      payment.other2!.length ==
                                                              0
                                                          ? '0'
                                                          : payment.other2!),
                                                },
                                              ),
                                            ),
                                          );
                                          if (result != null) {
                                            _fetchPaymentsAndStream(); // Refresh data
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.visibility,
                                            color: AppColor.primery),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Other Payment Details'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ReuseContainer(
                                                          title:
                                                              "Monthly Salary",
                                                          subtitle: payment
                                                                      .other3!
                                                                      .length ==
                                                                  0
                                                              ? '0'
                                                              : payment
                                                                      .other3 ??
                                                                  '0'),
                                                      SizedBox(
                                                          height: Sizes.height *
                                                              0.02),
                                                      ReuseContainer(
                                                          title:
                                                              "Payabe Amount",
                                                          subtitle:
                                                              payment.other2!),
                                                      SizedBox(
                                                          height: Sizes.height *
                                                              0.02),
                                                      ReuseContainer(
                                                          title:
                                                              "Sattlement Amount",
                                                          subtitle: payment
                                                              .totalAmount!),
                                                      SizedBox(
                                                          height: Sizes.height *
                                                              0.02),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: AppColor.white,
                                                                border: Border.all(
                                                                  color:
                                                                      AppColor
                                                                          .grey,
                                                                ),
                                                                boxShadow: [
                                                              BoxShadow(
                                                                  blurRadius: 2,
                                                                  color: AppColor
                                                                      .white)
                                                            ]),
                                                        child: ListTile(
                                                          title: Text("Remark",
                                                              style: TextStyle(
                                                                  color: AppColor
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                          subtitle: Text(
                                                              payment.other1!,
                                                              style: TextStyle(
                                                                  color: AppColor
                                                                      .primery,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child:
                                                          const Text('Close'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: AppColor.red),
                                        onPressed: () {
                                          deletePaymentApi(payment.pvNo).then(
                                            (value) =>
                                                _fetchPaymentsAndStream(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          TableRow(children: [
                            tableCell(''),
                            tableCell(''),
                            tableCell('Total'),
                            tableCell('₹ $totalAmount'),
                            tableCell(''),
                            SizedBox(
                                height: Sizes.height * 0.07,
                                child: tableCell('')),
                          ])
                        ]),
                  ],
                );
              },
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

  // Fetch payments from API
  Future<List<PaymentModel>> fetchPayments() async {
    final response = await http.get(Uri.parse(
        "http://lms.muepetro.com/api/TransactionsPayroll/GetPaymentVoucherALLocationwisePayroll?datefrom=${fromDate.text}&dateto=${toDate.text}&locationid=${Preference.getString(PrefKeys.locationId)}&StaffId=0"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PaymentModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  // Delete payment
  Future<void> deletePaymentApi(int? paymentId) async {
    var response = await ApiService.postData(
        "TransactionsPayroll/DeletePaymentVoucherPayroll?prefix=online&refno=$paymentId&locationid=${Preference.getString(PrefKeys.locationId)}",
        {});
    if (response['status'] == false) {
      showCustomSnackbar(context, response['message']);
    } else {
      showCustomSnackbarSuccess(context, response['message']);
    }
  }
}
