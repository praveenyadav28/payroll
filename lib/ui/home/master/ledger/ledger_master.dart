// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/ui/home/master/city_master.dart';
import 'package:payroll/ui/home/master/district_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class LedgerMasterScreen extends StatefulWidget {
  LedgerMasterScreen({required this.isNew, required this.ledgerId, super.key});
  bool isNew = true;
  int ledgerId = 0;

  @override
  _LedgerMasterScreenState createState() => _LedgerMasterScreenState();
}

class _LedgerMasterScreenState extends State<LedgerMasterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  //State
  List<Map<String, dynamic>> stateList = [];
  int? stateId;
  String stateName = '';
  Map<String, dynamic>? stateValue;

  //District
  List<Map<String, dynamic>> districtList = [];
  int? districtId;
  String districtName = '';
  Map<String, dynamic>? districtValue;

  //City
  List<Map<String, dynamic>> cityList = [];
  int? cityId;
  String cityName = '';
  Map<String, dynamic>? cityValue;

//GST Dealer Type
  List<Map<String, dynamic>> gestDealerList = [];
  int? gestDealerId = 27;

  @override
  void initState() {
    fetchDistrict().then((value) => setState(() {}));
    gstDealerData().then((value) => setState(() {
          widget.isNew ? null : fetchLedger().then((value) => setState(() {}));
        }));

    fetchCity().then((value) => setState(() {}));
    fetchState().then((value) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger Master'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      drawer: const SideMenu(),
      body: gestDealerList.isEmpty
          ? const CircularProgressIndicator()
          : LayoutBuilder(
              builder: (context, constraints) {
                return OutsideContainer(
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
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isNew
                                      ? 'Add Ledger Details'
                                      : 'Update Ledger Details',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                addMasterOutside(children: [
                                  CommonTextFormField(
                                    controller: _nameController,
                                    hintText: "Name",
                                    labelText: "Name",
                                    validator: (value) => value!.isEmpty
                                        ? 'Please enter a name'
                                        : null,
                                  ),
                                  CommonTextFormField(
                                    controller: _addressController,
                                    labelText: 'Address',
                                    hintText: 'Address',
                                    validator: (value) => value!.isEmpty
                                        ? 'Please enter father\'s name'
                                        : null,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: dropdownTextfield(
                                            context,
                                            "City",
                                            searchDropDown(
                                                context,
                                                cityName.isNotEmpty
                                                    ? cityName
                                                    : "Select City",
                                                cityList
                                                    .map((item) =>
                                                        DropdownMenuItem(
                                                          onTap: () {
                                                            setState(() {
                                                              cityId = item[
                                                                  'city_Id'];
                                                              cityName = item[
                                                                  'city_Name'];
                                                              districtId = item[
                                                                  'district_Id'];
                                                              districtName = item[
                                                                  'district_Name'];
                                                              stateId = item[
                                                                  'state_Id'];
                                                              stateName = item[
                                                                  'state_Name'];
                                                            });
                                                          },
                                                          value: item,
                                                          child: Text(
                                                            item['city_Name']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColor
                                                                    .black),
                                                          ),
                                                        ))
                                                    .toList(),
                                                cityValue,
                                                (value) {
                                                  setState(() {
                                                    cityValue = value;
                                                  });
                                                },
                                                searchController,
                                                (value) {
                                                  setState(() {
                                                    cityList
                                                        .where((item) => item[
                                                                'city_Name']
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(value
                                                                .toLowerCase()))
                                                        .toList();
                                                  });
                                                },
                                                'Search for a City...',
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
                                                builder: (context) =>
                                                    const CityMaster(),
                                              ));
                                          if (result != null) {
                                            cityValue = null;
                                            fetchCity().then(
                                                (value) => setState(() {}));
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: dropdownTextfield(
                                            context,
                                            "District",
                                            searchDropDown(
                                                context,
                                                districtName.isEmpty
                                                    ? "Select District"
                                                    : districtName,
                                                districtList
                                                    .map((item) =>
                                                        DropdownMenuItem(
                                                          onTap: () {
                                                            setState(() {
                                                              districtId = item[
                                                                  'district_Id'];
                                                              districtName = item[
                                                                  'district_Name'];
                                                              stateId = item[
                                                                  'state_Id'];
                                                              stateName = item[
                                                                  'state_Name'];
                                                            });
                                                          },
                                                          value: item,
                                                          child: Text(
                                                            item['district_Name']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColor
                                                                    .black),
                                                          ),
                                                        ))
                                                    .toList(),
                                                districtValue,
                                                (value) {
                                                  setState(() {
                                                    districtValue = value;
                                                  });
                                                },
                                                searchController,
                                                (value) {
                                                  setState(() {
                                                    districtList
                                                        .where((item) => item[
                                                                'district_Name']
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(value
                                                                .toLowerCase()))
                                                        .toList();
                                                  });
                                                },
                                                'Search for a District...',
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
                                                builder: (context) =>
                                                    const DistrictMaster(),
                                              ));
                                          if (result != null) {
                                            districtValue = null;
                                            fetchDistrict().then(
                                                (value) => setState(() {}));
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      dropdownTextfield(
                                          context,
                                          "State",
                                          searchDropDown(
                                              context,
                                              stateName.isNotEmpty
                                                  ? stateName
                                                  : "Select State",
                                              stateList
                                                  .map((item) =>
                                                      DropdownMenuItem(
                                                        onTap: () {
                                                          setState(() {
                                                            stateId = item[
                                                                'state_Id'];
                                                            stateName = item[
                                                                'state_Name'];
                                                          });
                                                        },
                                                        value: item,
                                                        child: Text(
                                                          item['state_Name']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColor
                                                                  .black),
                                                        ),
                                                      ))
                                                  .toList(),
                                              stateValue,
                                              (value) {
                                                setState(() {
                                                  stateValue = value;
                                                });
                                              },
                                              searchController,
                                              (value) {
                                                setState(() {
                                                  stateList
                                                      .where((item) => item[
                                                              'state_Name']
                                                          .toString()
                                                          .toLowerCase()
                                                          .contains(value
                                                              .toLowerCase()))
                                                      .toList();
                                                });
                                              },
                                              'Search for a State...',
                                              (isOpen) {
                                                if (!isOpen) {
                                                  searchController.clear();
                                                }
                                              })),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      dropdownTextfield(
                                        context,
                                        "GST Dealer Type",
                                        defaultDropDown(
                                            value: gestDealerList.firstWhere(
                                                (item) =>
                                                    item['id'] == gestDealerId),
                                            items: gestDealerList.map((data) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value: data,
                                                child: Text(
                                                  data['name'],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColor.black),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (selectedId) {
                                              setState(() {
                                                gestDealerId =
                                                    selectedId!['id'];
                                                // Call function to make API request
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                  CommonTextFormField(
                                    controller: _gstNumberController,
                                    labelText: 'GST Number',
                                    hintText: 'GST Number',
                                    validator: (value) => value!.isEmpty
                                        ? 'Please enter bank name'
                                        : null,
                                  ),
                                  Column(
                                    children: [
                                      DefaultButton(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () {
                                          postLedger();
                                        },
                                        hight: 50,
                                        width: double.infinity,
                                        boxShadow: const [BoxShadow()],
                                        child: Text(
                                          widget.isNew ? 'Save' : 'Update',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: AppColor.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ], context: context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

//Post Ledger
  Future postLedger() async {
    var response = await ApiService.postData(
        widget.isNew
            ? 'MasterPayroll/PostLedgerMasterPayroll?LocationId=${Preference.getString(PrefKeys.locationId)}'
            : 'MasterPayroll/UpdatePostLedgerMasterByIdPayroll?LedgerId=${widget.ledgerId}',
        {
          "Title_Id": 1,
          "Ledger_Name": _nameController.text.toString(),
          "Son_Off": "",
          "Address": _addressController.text.toString(),
          "Address2": "",
          "City_Id": cityId,
          "Std_Code": "",
          "Mob": "",
          "Pin_Code": "",
          "Ledger_Group_Id": 7,
          "Opening_Bal": "0",
          "Opening_Bal_Combo": "Dr",
          "Gst_No": _gstNumberController.text.toString(),
          "Address_TA": "",
          "Address2_TA": "",
          "Std_Code_TA": "",
          "Mob_TA": "",
          "Pin_Code_TA": "",
          "SubcidyIdNo": " ",
          "DueDate": "",
          "ClosingBal": "0",
          "ClosingBal_Type": "Dr",
          "Category_Id": 1,
          "Staff_Id": 1,
          "CreditLimit": "Address2_TA",
          "CreditDays": "",
          "WhatappNo": 0,
          "EmailId": "",
          "BirthdayDate": "",
          "AnniversaryDate": "",
          "DistanceKm": "",
          "DiscountSource": "0",
          "DiscountValid": "Dr",
          "Location_Id": int.parse(Preference.getString(PrefKeys.locationId)),
          "OtherNumber1": 1,
          "OtherNumber2": 2,
          "OtherNumber3": 3,
          "OtherNumber4": 4,
          "OtherNumber5": 5,
          "GSTTypeId": gestDealerId,
          "IGST": 28,
          "CGST": 14,
          "SGST": 14,
          "CESS": 1,
          "RCMStatus": 28,
          "ITCStatus": 14,
          "ExpencesTypeId": 14,
          "RCMCategory": 1,
          "AadharNo": "ADHAR",
          "PanNo": "PAN"
        });
    if (response['result'] == true) {
      showCustomSnackbarSuccess(context, '${response["message"]}');
      Navigator.pop(context, 'data');
    } else {
      showCustomSnackbar(context, '${response["message"]}');
    }
  }

// Get State List
  Future fetchState() async {
    final response =
        await ApiService.fetchData("MasterPayroll/GetStatePayroll");

    if (response is List) {
      // Assuming it's a list, convert each item to a Map
      stateList = response.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected data format for districts');
    }
  }

// Get District List
  Future fetchDistrict() async {
    final response =
        await ApiService.fetchData("MasterPayroll/GetDistrictPayroll");

    if (response is List) {
      // Assuming it's a list, convert each item to a Map
      districtList =
          response.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected data format for districts');
    }
  }

// Get City List
  Future fetchCity() async {
    final response =
        await ApiService.fetchData("MasterPayroll/GetCityAllDetailsPayroll");

    if (response is List) {
      // Assuming it's a list, convert each item to a Map
      cityList = response.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected data format for cities');
    }
  }

// Get Gst Dealer
  Future<void> gstDealerData() async {
    await fetchDataByMiscMaster(20, gestDealerList).then((_) {
      if (gestDealerList.isNotEmpty) {
        gestDealerId = gestDealerList.first['id'];
      }
    });
  }

// Get Ledger Details
  Future fetchLedger() async {
    final response = await ApiService.fetchData(
        "MasterPayroll/GetLedgerAllLocationWisePayroll?locationId=${Preference.getString(PrefKeys.locationId)}");

    _nameController.text = response[0]['ledger_Name'];
    _addressController.text = response[0]['address'];
    _gstNumberController.text = response[0]['gst_No'];
    gestDealerId = response[0]['gstTypeId'];
    cityId = response[0]['city_Id'];
    cityName = cityList
        .firstWhere((element) => element['city_Id'] == cityId)['city_Name'];
    districtName = cityList
        .firstWhere((element) => element['city_Id'] == cityId)['district_Name'];
    stateName = cityList
        .firstWhere((element) => element['city_Id'] == cityId)['state_Name'];
  }
}
