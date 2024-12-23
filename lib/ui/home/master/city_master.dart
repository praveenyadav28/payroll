// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/components/prefences.dart';
import 'package:payroll/ui/home/master/district_master.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class CityMaster extends StatefulWidget {
  const CityMaster({super.key});
  @override
  State<CityMaster> createState() => _CityMasterState();
}

class _CityMasterState extends State<CityMaster> {
  TextEditingController cityController = TextEditingController();
  TextEditingController cityControllerEdit = TextEditingController();
  TextEditingController searchController = TextEditingController();
//City
  List cityList = [];

  //District
  List<Map<String, dynamic>> districtList = [];
  int? districtId;
  Map<String, dynamic>? districtValue;

  int selectedIndex = -1;

  int stateId = 0;
  @override
  void initState() {
    fetchDistrict().then((value) => setState(() {}));
    fatchCity().then((value) => setState(() {}));
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
          title: const Text('City Master'),
          flexibleSpace: const OutsideContainer(child: Column())),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              vertical: Sizes.height * 0.02, horizontal: Sizes.width * .03),
          child: Column(children: [
            addMasterOutside(context: context, children: [
              CommonTextFormField(
                  controller: cityController, labelText: "City"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: dropdownTextfield(
                        context,
                        "District",
                        searchDropDown(
                            context,
                            "Select District",
                            districtList
                                .map((item) => DropdownMenuItem(
                                      onTap: () {
                                        setState(() {
                                          districtId = item['district_Id'];
                                          stateId = item['state_Id'];
                                        });
                                      },
                                      value: item,
                                      child: Text(
                                        item['district_Name'].toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.black),
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
                                    .where((item) => item['district_Name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
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
                            builder: (context) => DistrictMaster(),
                          ));
                      if (result != null) {
                        districtValue = null;
                        fetchDistrict().then((value) => setState(() {}));
                      }
                    },
                  )
                ],
              ),
              Column(
                children: [
                  CustomButton(
                    text: "Save",
                    press: () {
                      if (cityController.text.isEmpty) {
                        showCustomSnackbar(context, "Please enter city");
                      } else if (districtId == null) {
                        showCustomSnackbar(context, "Please select district");
                      } else {
                        postCity().then((value) => setState(() {
                              fatchCity().then((value) => setState(() {}));
                            }));
                      }
                    },
                    height: 52,
                    width: double.infinity,
                  )
                ],
              )
            ]),
            Container(
              padding: const EdgeInsets.all(8),
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
                      // ignore: prefer_const_literals_to_create_immutables
                      colors: [
                        Color(0xff4EB1C6),
                        // Color(0xff4EB1C6),
                        Color(0xff56C891)
                      ])),
              margin: EdgeInsets.only(top: Sizes.height * 0.02),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Sr. No.',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'City Name',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'District Name',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Action',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColor.white,
                  border: Border.all(
                    color: const Color(0xff377785),
                  ),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Column(
                children: List.generate(cityList.length, (index) {
                  //District
                  int districtID = cityList[index]['district_Id'];
                  String districtName = districtList.firstWhere((element) =>
                      element['district_Id'] == districtID)['district_Name'];
                  return Container(
                    decoration: BoxDecoration(
                        color: AppColor.white,
                        border: Border.all(
                          color: AppColor.primery.withOpacity(.08),
                        )),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              cityList[index]["city_Name"],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              districtName,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: PopupMenuButton(
                            onOpened: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            onCanceled: () {
                              setState(() {
                                selectedIndex = -1;
                              });
                            },
                            position: PopupMenuPosition.under,
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry>[
                              PopupMenuItem(
                                  value: 'Edit',
                                  onTap: () {
                                    cityControllerEdit.text =
                                        cityList[index]["city_Name"];
                                    districtID = cityList[index]['district_Id'];
                                    districtName =
                                        cityList[index]['district_Name'];
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              insetPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal:
                                                          Sizes.width * .02,
                                                      vertical:
                                                          Sizes.height * 0.02),
                                              title: const Text('Edit City'),
                                              content: EditCity(
                                                  cityControllerEdit:
                                                      cityControllerEdit,
                                                  searchController:
                                                      searchController,
                                                  districtName: districtName,
                                                  districtList: districtList,
                                                  cityList: cityList,
                                                  districtId: districtID,
                                                  index: index,
                                                  stateId: stateId,
                                                  districtValue:
                                                      districtValue));
                                        });
                                  },
                                  child: const Text('Edit')),
                              PopupMenuItem(
                                  value: 'Delete',
                                  onTap: () {
                                    deletecityApi(cityList[index]["city_Id"])
                                        .then((value) => fatchCity()
                                            .then((value) => setState(() {})));
                                  },
                                  child: const Text('Delete')),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ),
            ),
          ])),
    );
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

//Add City
  Future postCity() async {
    var response = await ApiService.postData('MasterPayroll/PostCityPayroll', {
      "City_Name": cityController.text.toString(),
      "District_Id": districtId,
      "Location_Id": int.parse(Preference.getString(PrefKeys.locationId)),
    });
    if (response['result'] == true) {
      showCustomSnackbarSuccess(context, '${response["message"]}');
      Navigator.pop(context, "Update Data");
    } else {
      showCustomSnackbar(context, '${response["message"]}');
    }
  }

  //Get City List
  Future fatchCity() async {
    var response =
        await ApiService.fetchData("MasterPayroll/GetCityAllDetailsPayroll");
    cityList = response;
  }

  //Delete City
  Future deletecityApi(int? cityId) async {
    var response = await ApiService.postData(
        "MasterPayroll/DeleteCityByIdPayroll?Id=$cityId", {});

    if (response['status'] == false) {
      showCustomSnackbar(context, response['message']);
    } else {
      showCustomSnackbarSuccess(context, response['message']);
    }
  }
}

class EditCity extends StatefulWidget {
  EditCity({
    super.key,
    required this.cityControllerEdit,
    required this.searchController,
    required this.districtName,
    required this.districtList,
    required this.cityList,
    required this.districtId,
    required this.index,
    required this.stateId,
    required this.districtValue,
  });

  TextEditingController cityControllerEdit;
  TextEditingController searchController;
  String districtName = '';
  List<Map<String, dynamic>> districtList;
  List cityList;
  int? districtId;
  int? index;
  int? stateId;
  Map<String, dynamic>? districtValue;
  @override
  State<EditCity> createState() => _EditCityState();
}

class _EditCityState extends State<EditCity> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sizes.width,
      child: addMasterOutside(context: context, children: [
        CommonTextFormField(
            controller: widget.cityControllerEdit, labelText: "City"),
        Column(
          children: [
            dropdownTextfield(
                context,
                "District",
                searchDropDown(
                    context,
                    widget.districtName,
                    widget.districtList
                        .map((item) => DropdownMenuItem(
                              onTap: () {
                                setState(() {
                                  widget.districtId = item['district_Id'];
                                });
                              },
                              value: item,
                              child: Text(
                                item['district_Name'].toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.black),
                              ),
                            ))
                        .toList(),
                    widget.districtValue,
                    (value) {
                      setState(() {
                        widget.districtValue = value;
                      });
                    },
                    widget.searchController,
                    (value) {
                      setState(() {
                        widget.districtList
                            .where((item) => item['district_Name']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    'Search for a District...',
                    (isOpen) {
                      if (!isOpen) {
                        widget.searchController.clear();
                      }
                    })),
          ],
        ),
        Column(
          children: [
            CustomButton(
                text: "Update",
                press: () {
                  if (widget.cityControllerEdit.text.isEmpty) {
                    showCustomSnackbar(context, "Please enter city");
                  } else if (widget.districtId == null) {
                    showCustomSnackbar(context, "Please select district");
                  } else {
                    updateCity(widget.cityList[widget.index!]["city_Id"])
                        .then((value) => setState(() {
                              Navigator.pop(context);
                              widget.cityControllerEdit.clear();
                              widget.districtValue = null;
                              fatchCity().then((value) => setState(() {
                                    widget.cityControllerEdit.clear();
                                  }));
                            }));
                  }
                },
                height: 52,
                width: double.infinity)
          ],
        )
      ]),
    );
  }

// Get District List
  Future fetchDistrict() async {
    final response =
        await ApiService.fetchData("MasterPayroll/GetDistrictPayroll");

    if (response is List) {
      // Assuming it's a list, convert each item to a Map
      widget.districtList =
          response.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Unexpected data format for districts');
    }
  }

  //Get City List
  Future fatchCity() async {
    var response =
        await ApiService.fetchData("MasterPayroll/GetCityAllDetailsPayroll");
    widget.cityList = response;
  }

//Update City
  Future updateCity(id) async {
    var response = await ApiService.postData(
        'MasterPayroll/UpdateCityByIdPayroll?Id=$id', {
      "City_Name": widget.cityControllerEdit.text.toString(),
      "District_Id": widget.districtId,
      "Location_Id": int.parse(Preference.getString(PrefKeys.locationId))
    });
    if (response['result'] == true) {
      showCustomSnackbarSuccess(context, '${response["message"]}');
      Navigator.pop(context, "Refresh Data");
    } else {
      showCustomSnackbar(context, '${response["message"]}');
    }
  }
}
