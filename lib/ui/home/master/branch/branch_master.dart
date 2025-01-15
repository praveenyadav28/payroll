// screens/branch_master_screen.dart
// ignore_for_file: library_private_types_in_public_api, must_be_immutable, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/ui/home/master/city_master.dart';
import 'package:payroll/ui/home/master/district_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class BranchMasterScreen extends StatefulWidget {
  BranchMasterScreen({required this.isNew, required this.branchId, super.key});
  bool isNew = true;
  int branchId = 0;
  @override
  _BranchMasterScreenState createState() => _BranchMasterScreenState();
}

class _BranchMasterScreenState extends State<BranchMasterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController biomaxIdController = TextEditingController();
  final TextEditingController deviceController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController();
  final TextEditingController staffPasswordController = TextEditingController();
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

  //calculation type
  int _selectedOption = 0;

  @override
  void initState() {
    fetchDistrict().then((value) => setState(() {}));
    fetchCity().then((value) => setState(() {}));
    fetchState().then((value) => setState(() {}));
    widget.isNew ? null : fetchbranch().then((value) => setState(() {}));
    super.initState();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return CommonTextFormField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Master'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return OutsideContainer(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 1200
                      ? 1200
                      : constraints.maxWidth * 0.9,
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
                                ? 'Add Branch Details'
                                : 'Update Branch Details',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          addMasterOutside(children: [
                            _buildTextField(
                              controller: branchNameController,
                              labelText: 'Branch Name*',
                              hintText: 'Branch Name',
                            ),
                            _buildTextField(
                              controller: descriptionController,
                              labelText: 'Description',
                              hintText: 'Description',
                            ),
                            _buildTextField(
                              controller: addressController,
                              labelText: 'Address',
                              hintText: 'Address',
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: dropdownTextfield(
                                      context,
                                      "City*",
                                      searchDropDown(
                                          context,
                                          cityName.isEmpty
                                              ? "Select City"
                                              : cityName,
                                          cityList
                                              .map((item) => DropdownMenuItem(
                                                    onTap: () {
                                                      setState(() {
                                                        cityId =
                                                            item['city_Id'];
                                                        cityName =
                                                            item['city_Name'];
                                                        districtId =
                                                            item['district_Id'];
                                                        districtName = item[
                                                            'district_Name'];
                                                        stateId =
                                                            item['state_Id'];
                                                        stateName =
                                                            item['state_Name'];
                                                      });
                                                    },
                                                    value: item,
                                                    child: Text(
                                                      item['city_Name']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              AppColor.black),
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
                                                  .where((item) =>
                                                      item['city_Name']
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
                                      fetchCity()
                                          .then((value) => setState(() {}));
                                    }
                                  },
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: dropdownTextfield(
                                      context,
                                      "District*",
                                      searchDropDown(
                                          context,
                                          districtName.isEmpty
                                              ? "Select District"
                                              : districtName,
                                          districtList
                                              .map((item) => DropdownMenuItem(
                                                    onTap: () {
                                                      setState(() {
                                                        districtId =
                                                            item['district_Id'];
                                                        districtName = item[
                                                            'district_Name'];
                                                        stateId =
                                                            item['state_Id'];
                                                        stateName =
                                                            item['state_Name'];
                                                      });
                                                    },
                                                    value: item,
                                                    child: Text(
                                                      item['district_Name']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              AppColor.black),
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
                                                  .where((item) =>
                                                      item['district_Name']
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
                                      fetchDistrict()
                                          .then((value) => setState(() {}));
                                    }
                                  },
                                )
                              ],
                            ),
                            Column(
                              children: [
                                dropdownTextfield(
                                    context,
                                    "State*",
                                    searchDropDown(
                                        context,
                                        stateName.isEmpty
                                            ? "Select State"
                                            : stateName,
                                        stateList
                                            .map((item) => DropdownMenuItem(
                                                  onTap: () {
                                                    setState(() {
                                                      stateId =
                                                          item['state_Id'];
                                                      stateName =
                                                          item['state_Name'];
                                                    });
                                                  },
                                                  value: item,
                                                  child: Text(
                                                    item['state_Name']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor.black),
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
                                                .where((item) =>
                                                    item['state_Name']
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
                            _buildTextField(
                              controller: biomaxIdController,
                              labelText: 'Biomax Serial No.*',
                              hintText: 'Biomax Serial No.',
                            ),
                            _buildTextField(
                              controller: deviceController,
                              labelText: 'Device Name',
                              hintText: 'Device Name',
                            ),
                            Column(
                              children: [
                                dropdownTextfield(
                                  context,
                                  '',
                                  Row(
                                    children: [
                                      Radio<int>(
                                        value: 0,
                                        groupValue: _selectedOption,
                                        onChanged: (int? value) {
                                          setState(() {
                                            _selectedOption = value!;
                                          });
                                        },
                                      ),
                                      Text('Institute',
                                          style: TextStyle(
                                              color: AppColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      const Spacer(),
                                      Radio<int>(
                                        value: 1,
                                        groupValue: _selectedOption,
                                        onChanged: (int? value) {
                                          setState(() {
                                            _selectedOption = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Petrol Pump ',
                                        style: TextStyle(
                                            color: AppColor.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            _buildTextField(
                              controller: emailController,
                              labelText: 'Email Id*',
                              hintText: 'Email Id',
                            ),
                            _buildTextField(
                              controller: adminPasswordController,
                              labelText: 'Admin Password*',
                              hintText: 'Admin Password',
                            ),
                            _buildTextField(
                              controller: staffPasswordController,
                              labelText: 'Staff Password*',
                              hintText: 'Staff Password',
                            ),
                          ], context: context),
                          const SizedBox(height: 20),
                          DefaultButton(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              if (branchNameController.text.isEmpty) {
                                showCustomSnackbar(
                                    context, 'Please enter Branch Name');
                              } else if (emailController.text.isEmpty) {
                                showCustomSnackbar(
                                    context, 'Please enter Email Id');
                              } else if (adminPasswordController.text.isEmpty ||
                                  staffPasswordController.text.isEmpty) {
                                showCustomSnackbar(
                                    context, 'Please enter password');
                              } else if (cityId == null) {
                                showCustomSnackbar(
                                    context, 'Please enter city');
                              } else if (biomaxIdController.text.isEmpty) {
                                showCustomSnackbar(
                                    context, 'Please enter biomax serial no.');
                              } else {
                                postBranch();
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

// Get Branch Details
  Future fetchbranch() async {
    final response = await ApiService.fetchData(
        "MasterPayroll/GetBranchAllDetailsPayroll?ID=${widget.branchId}");
    branchNameController.text = response[0]['bLocation_Name'];
    descriptionController.text = response[0]['bDes'];
    addressController.text = response[0]['bAddress1'];
    adminPasswordController.text = response[0]['other1'];
    emailController.text = response[0]['bEmailId'];
    biomaxIdController.text = response[0]['bDeviceSerialNo'];
    deviceController.text = response[0]['bDeviceName'];
    cityId = int.parse(response[0]['bCity_Id']);
    cityName = response[0]['bCity_Name'];
    districtName = response[0]['bDistrict_Name'];
    stateName = response[0]['bState_Name'];
    staffPasswordController.text = response[0]['other3'];
    _selectedOption = int.parse(response[0]['other5']);
  }

//Post Branch
  Future postBranch() async {
    var response = await ApiService.postData(
        widget.isNew
            ? 'MasterPayroll/PostBranchMasterPayroll'
            : 'MasterPayroll/UpdateBranchByIdPayroll?Id=${widget.branchId}',
        {
          "BLocation_Name": branchNameController.text.toString(),
          "BDes": descriptionController.text.toString(),
          "BLic_No": "BLic_No",
          "BAddress1": addressController.text.toString(),
          "BAddress2": "BAddress2",
          "BCity_Id": "$cityId",
          "BCity_Name": cityName,
          "BDistrict_Name": districtName,
          "BState_Name": stateName,
          "BPin_Code": "BPin_Code",
          "BStd_Code": "BStd_Code",
          "BContact_No": "BContact_No",
          "BEmailId": emailController.text.toString(),
          "BGSTINNO": "BGSTINNO",
          "BLogoPath": "BLogoPath",
          "BJuridiction": "BJuridiction",
          "BDealerCode": "BDealerCode",
          "BDeviceSerialNo": biomaxIdController.text.toString(),
          "BDeviceName": "${deviceController.text}",
          "Other1": adminPasswordController.text.toString(),
          "Other2": widget.branchId == 3 ? 'Admin' : 'Staff',
          "Other3": staffPasswordController.text.toString(),
          "Other4": "2",
          "Other5": "$_selectedOption"
        });
    if (response['result'] == true) {
      showCustomSnackbarSuccess(context, '${response["message"]}');
      Navigator.pop(context, "Data");
    } else {
      showCustomSnackbar(context, '${response["message"]}');
    }
  }
}
