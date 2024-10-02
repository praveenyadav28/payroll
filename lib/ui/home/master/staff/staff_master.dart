// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/side_menu.dart';
import 'package:payroll/ui/home/master/city_master.dart';
import 'package:payroll/ui/home/master/district_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';
import 'package:intl/intl.dart';

class StaffMasterScreen extends StatefulWidget {
  StaffMasterScreen({required this.isNew, required this.staffId, super.key});
  bool isNew = true;
  int staffId = 0;

  @override
  _StaffMasterScreenState createState() => _StaffMasterScreenState();
}

class _StaffMasterScreenState extends State<StaffMasterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _biomaxIdController = TextEditingController();
  final TextEditingController _monthlySalaryController =
      TextEditingController();
  final TextEditingController _bankAccountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscNumberController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  //Date
  TextEditingController dobDatePicker = TextEditingController(
    text: DateFormat('yyyy/MM/dd').format(DateTime.now()),
  );
  TextEditingController joingDatePicker = TextEditingController(
    text: DateFormat('yyyy/MM/dd')
        .format(DateTime.now().add(const Duration(days: 7))),
  );
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

  //Degination
  List<Map<String, dynamic>> deginationList = [];
  int? deginationId;

  //Department
  List<Map<String, dynamic>> departmentList = [];
  int? departmentId;

  @override
  void initState() {
    fetchDistrict().then((value) => setState(() {}));
    fetchCity().then((value) => setState(() {}));
    fetchState().then((value) => setState(() {}));
    deginationData().then((value) => setState(() {
          deginationId = deginationList.first['id'];
        }));
    departmentData().then((value) => setState(() {
          departmentId = departmentList.first['id'];
          widget.isNew ? null : fetchStaff().then((value) => setState(() {}));
        }));
    _bankNameController.text = 'N/A';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Master'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      drawer: const SideMenu(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return OutsideContainer(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.9,
                ),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: departmentList.isEmpty ||
                          deginationList.isEmpty ||
                          cityList.isEmpty ||
                          stateList.isEmpty ||
                          districtList.isEmpty
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isNew
                                      ? 'Add Staff Details'
                                      : 'Update Staff Details',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                addMasterOutside(children: [
                                  CommonTextFormField(
                                    controller: _nameController,
                                    labelText: "Name*",
                                    hintText: "Name",
                                  ),
                                  CommonTextFormField(
                                    controller: _fatherNameController,
                                    labelText: 'Father Name',
                                    hintText: 'Father Name',
                                  ),
                                  CommonTextFormField(
                                    controller: _employeeIdController,
                                    labelText: 'Employee ID',
                                    hintText: 'Employee ID',
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: dropdownTextfield(
                                            context,
                                            "City*",
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
                                                    CityMaster(),
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
                                                districtName.isNotEmpty
                                                    ? districtName
                                                    : "Select District",
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
                                                    DistrictMaster(),
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
                                  CommonTextFormField(
                                    controller: _addressController,
                                    labelText: 'Address',
                                    hintText: 'Address',
                                  ),
                                  CommonTextFormField(
                                    controller: _mobileNumberController,
                                    labelText: 'Mobile Number*',
                                    hintText: 'Mobile Number',
                                  ),
                                  CommonTextFormField(
                                    controller: _biomaxIdController,
                                    labelText: 'Biomax ID*',
                                    hintText: 'Biomax ID',
                                  ),
                                  Column(children: [
                                    dropdownTextfield(
                                      context,
                                      "Date of Birth",
                                      InkWell(
                                        onTap: () async {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                          ).then((selectedDate) {
                                            if (selectedDate != null) {
                                              dobDatePicker.text =
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
                                              dobDatePicker.text,
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
                                  ]),
                                  Column(children: [
                                    dropdownTextfield(
                                      context,
                                      "Joining Date",
                                      InkWell(
                                        onTap: () async {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                          ).then((selectedDate) {
                                            if (selectedDate != null) {
                                              joingDatePicker.text =
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
                                              joingDatePicker.text,
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
                                  ]),
                                  Column(
                                    children: [
                                      dropdownTextfield(
                                        context,
                                        "Degination",
                                        defaultDropDown(
                                            value: deginationList.firstWhere(
                                                (item) =>
                                                    item['id'] == deginationId),
                                            items: deginationList.map((data) {
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
                                                deginationId =
                                                    selectedId!['id'];
                                                // Call function to make API request
                                              });
                                            }),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      dropdownTextfield(
                                        context,
                                        "Department",
                                        defaultDropDown(
                                            value: departmentList.firstWhere(
                                                (item) =>
                                                    item['id'] == departmentId),
                                            items: departmentList.map((data) {
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
                                                departmentId =
                                                    selectedId!['id'];
                                                // Call function to make API request
                                              });
                                            }),
                                      )
                                    ],
                                  ),
                                  CommonTextFormField(
                                    controller: _monthlySalaryController,
                                    labelText: 'Monthly Salary*',
                                    hintText: 'Monthly Salary',
                                  ),
                                  CommonTextFormField(
                                    controller: _bankNameController,
                                    labelText: 'Bank Name',
                                    hintText: 'Bank Name',
                                  ),
                                  CommonTextFormField(
                                    controller: _bankAccountNumberController,
                                    labelText: 'Bank Account Number',
                                    hintText: 'Bank Account Number',
                                  ),
                                  CommonTextFormField(
                                    controller: _ifscNumberController,
                                    labelText: 'IFSC Number',
                                    hintText: 'IFSC Number',
                                  ),
                                ], context: context),
                                const SizedBox(height: 20),
                                DefaultButton(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    if (_nameController.text.isEmpty) {
                                      showCustomSnackbar(
                                          context, 'Please enter Staff Name');
                                    } else if (cityId == null) {
                                      showCustomSnackbar(
                                          context, 'Please enter City');
                                    } else if (_mobileNumberController
                                        .text.isEmpty) {
                                      showCustomSnackbar(context,
                                          'Please enter mobile number');
                                    } else if (_biomaxIdController
                                        .text.isEmpty) {
                                      showCustomSnackbar(
                                          context, 'Please enter Biomax Id');
                                    } else if (_monthlySalaryController
                                        .text.isEmpty) {
                                      showCustomSnackbar(context,
                                          'Please enter monthly salary');
                                    } else {
                                      postStaff();
                                    }
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
      throw Exception('Unexpected data format for citys');
    }
  }

  Future<void> deginationData() async {
    await fetchDataByMiscMaster(
      28,
      deginationList,
    );
  }

  Future<void> departmentData() async {
    await fetchDataByMiscMaster(
      27,
      departmentList,
    );
  }

//Post Staff
  Future postStaff() async {
    var response = await ApiService.postData(
        widget.isNew
            ? 'MasterPayroll/PostStaffPayroll'
            : 'MasterPayroll/UpdateStaffByIdPayroll?Id=${widget.staffId}',
        {
          "Title_Id": 1,
          "Staff_Name": _nameController.text.toString(),
          "Son_Off": _fatherNameController.text.toString(),
          "Address1": _addressController.text.toString(),
          "Address2": "Address2",
          "City_Id": "$cityId",
          "City_Name": cityName,
          "District_Name": districtName,
          "State_Name": stateName,
          "Pin_Code": "Pin_Code",
          "Std_Code": "Std_Code",
          "Mob": _mobileNumberController.text.toString(),
          "Staff_Degination_Id": deginationId,
          "Staff_Department_Id": departmentId,
          "Location_Id": 3,
          "Dob_Date": dobDatePicker.text.toString(),
          "Joining_Date": joingDatePicker.text.toString(),
          "Left_Date": "BJuridiction",
          "EmpId": _employeeIdController.text.toString(),
          "BiomaxId": _biomaxIdController.text.toString(),
          "Salary": _monthlySalaryController.text.toString(),
          "BankName": _bankNameController.text.toString(),
          "BankAccountNo": _bankAccountNumberController.text.toString(),
          "BankIFSC": _ifscNumberController.text.toString(),
          "Other1": "Other1",
          "Other2": "Other2",
          "Other3": "Other3",
          "Other4": "Other4",
          "Other5": "Other5"
        });
    if (response['result'] == true) {
      showCustomSnackbarSuccess(context, '${response["message"]}');
      Navigator.pop(context, "data");
    } else {
      showCustomSnackbar(context, '${response["message"]}');
    }
  }

// Get Staff Details
  Future fetchStaff() async {
    final response = await ApiService.fetchData(
        "MasterPayroll/GetStaffDetailsByStaffIdPayroll?StaffId=${widget.staffId}");
    _nameController.text = response[0]['staff_Name'];
    _fatherNameController.text = response[0]['son_Off'];
    _employeeIdController.text = response[0]['empId'];
    _addressController.text = response[0]['address1'];
    _mobileNumberController.text = response[0]['mob'];
    _biomaxIdController.text = response[0]['biomaxId'];
    _monthlySalaryController.text = response[0]['salary'];
    _bankAccountNumberController.text = response[0]['bankAccountNo'];
    _bankNameController.text = response[0]['bankName'];
    _ifscNumberController.text = response[0]['bankIFSC'];
    cityId = int.parse(response[0]['city_Id']);
    cityName = response[0]['city_Name'];
    districtName = response[0]['district_Name'];
    stateName = response[0]['state_Name'];
    deginationId = response[0]['staff_Degination_Id'];
    departmentId = response[0]['staff_Department_Id'];
    dobDatePicker.text = response[0]['dob_Date'];
    joingDatePicker.text = response[0]['joining_Date'];
  }
}
