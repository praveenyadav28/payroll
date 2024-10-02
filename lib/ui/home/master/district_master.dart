import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payroll/components/api.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/layout.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/snackbar.dart';
import 'package:payroll/utils/textformfield.dart';

class DistrictMaster extends StatefulWidget {
  const DistrictMaster({super.key});
  @override
  State<DistrictMaster> createState() => _DistrictMasterState();
}

class _DistrictMasterState extends State<DistrictMaster> {
  TextEditingController districtController = TextEditingController();
  TextEditingController districtControllerEdit = TextEditingController();
  TextEditingController searchController = TextEditingController();

  //State
  List<Map<String, dynamic>> statesList = [];
  int? stateId;
  Map<String, dynamic>? stateValue;

  //District
  List districtLists = [];

  @override
  void initState() {
    fatchState().then((value) => setState(() {}));
    fatchDistrict().then((value) => setState(() {}));
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
          title: const Text('District Master'),
          flexibleSpace: const OutsideContainer(child: Column())),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            vertical: Sizes.height * 0.02, horizontal: Sizes.width * .03),
        child: Column(
          children: [
            statesList.isEmpty
                ? Container()
                : addMasterOutside(context: context, children: [
                    CommonTextFormField(
                        controller: districtController, labelText: "District"),
                    Column(
                      children: [
                        dropdownTextfield(
                            context,
                            "State",
                            searchDropDown(
                                context,
                                "Select State",
                                statesList
                                    .map((item) => DropdownMenuItem(
                                          onTap: () {
                                            stateId = item['id'];
                                          },
                                          value: item,
                                          child: Text(
                                            item['name'].toString(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
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
                                    statesList
                                        .where((item) => item['name']
                                            .toString()
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
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
                        CustomButton(
                          text: "Save",
                          press: () {
                            if (districtController.text.isEmpty) {
                              showCustomSnackbar(
                                  context, "Please enter District Name");
                            } else if (stateId == null) {
                              showCustomSnackbar(
                                  context, "Please select State");
                            } else {
                              postDistrict().then((value) => setState(() {
                                    fatchDistrict()
                                        .then((value) => setState(() {}));
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
                      'District Name',
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
                      'State Name',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColor.white,
                  border: Border.all(
                    color: const Color(0xff377785),
                  ),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              margin: EdgeInsets.only(bottom: Sizes.height * 0.02),
              // height: 200,
              child: Column(
                children: List.generate(districtLists.length, (index) {
                  //State
                  int stateId = districtLists[index]['state_Id'];
                  String stateName = statesList.firstWhere(
                      (element) => element['id'] == stateId)['name'];
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
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              districtLists[index]["district_Name"],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              stateName,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: PopupMenuButton(
                            // onOpened: () {
                            //   setState(() {
                            //     selectedIndex = index;
                            //   });
                            // },
                            // onCanceled: () {
                            //   setState(() {
                            //     selectedIndex = -1;
                            //   });
                            // },
                            position: PopupMenuPosition.under,
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry>[
                              PopupMenuItem(
                                  value: 'Edit',
                                  onTap: () {
                                    districtControllerEdit.text =
                                        districtLists[index]["district_Name"];
                                    stateId = districtLists[index]['state_Id'];
                                    stateName =
                                        districtLists[index]['state_Name'];
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              insetPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: Sizes.width *
                                                          .02,
                                                      vertical:
                                                          Sizes.height * 0.02),
                                              title:
                                                  const Text('Edit District'),
                                              content: EditDistrict(
                                                  stateName: stateName,
                                                  districtControllerEdit:
                                                      districtControllerEdit,
                                                  searchController:
                                                      searchController,
                                                  statesList: statesList,
                                                  stateId: stateId,
                                                  stateValue: stateValue,
                                                  districtList: districtLists,
                                                  index: index));
                                        });
                                  },
                                  child: const Text('Edit')),
                              PopupMenuItem(
                                  value: 'Delete',
                                  onTap: () {
                                    deleteDistrictApi(
                                            districtLists[index]["district_Id"])
                                        .then((value) => fatchDistrict()
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
          ],
        ),
      ),
    );
  }

//Add District
  Future postDistrict() async {
    var response =
        await ApiService.postData('MasterPayroll/PostDistrictPayroll', {
      "District_Name": districtController.text.toString(),
      "State_Id": stateId,
      "Location_Id": 1
    });
    if (response['result'] == true) {
      showCustomSnackbarSuccess(context, '${response["message"]}');
      Navigator.pop(context, "Update Data");
    } else {
      showCustomSnackbar(context, '${response["message"]}');
    }
  }

  // //Delete District
  Future deleteDistrictApi(int? districtgggId) async {
    var response = await ApiService.postData(
        "MasterPayroll/DeleteDistrictByIdPayroll?Id=$districtgggId", {});

    if (response['status'] == false) {
      showCustomSnackbar(context, response['message']);
    } else {
      showCustomSnackbarSuccess(context, response['message']);
    }
  }

  //Get District
  Future fatchDistrict() async {
    var response =
        await ApiService.fetchData("MasterPayroll/GetDistrictPayroll");
    districtLists = response;
  }

  //Get State
  Future fatchState() async {
    var response = await ApiService.fetchData("MasterPayroll/GetStatePayroll");

    statesList = List<Map<String, dynamic>>.from(response.map((item) => {
          'id': item['state_Id'],
          'name': item['state_Name'],
        }));
  }
}

class EditDistrict extends StatefulWidget {
  EditDistrict({
    super.key,
    required this.districtControllerEdit,
    required this.searchController,
    required this.statesList,
    required this.stateId,
    required this.stateName,
    required this.stateValue,
    required this.districtList,
    required this.index,
  });

  TextEditingController districtControllerEdit;
  TextEditingController searchController;
  List<Map<String, dynamic>> statesList;
  int? stateId;
  String stateName;
  Map<String, dynamic>? stateValue;
  List districtList;
  int? index;
  @override
  State<EditDistrict> createState() => _EditDistrictState();
}

class _EditDistrictState extends State<EditDistrict> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sizes.width,
      child: addMasterOutside(context: context, children: [
        CommonTextFormField(
            controller: widget.districtControllerEdit, labelText: "District"),
        Column(
          children: [
            dropdownTextfield(
                context,
                "State",
                searchDropDown(
                    context,
                    widget.stateName,
                    widget.statesList
                        .map((item) => DropdownMenuItem(
                              onTap: () {
                                widget.stateId = item['id'];
                              },
                              value: item,
                              child: Text(
                                item['name'].toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.black),
                              ),
                            ))
                        .toList(),
                    widget.stateValue,
                    (value) {
                      setState(() {
                        widget.stateValue = value;
                      });
                    },
                    widget.searchController,
                    (value) {
                      setState(() {
                        widget.statesList
                            .where((item) => item['name']
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    'Search for a State...',
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
                  if (widget.districtControllerEdit.text.isEmpty) {
                    showCustomSnackbar(context, "Please enter District Name");
                  } else if (widget.stateId == 0) {
                    showCustomSnackbar(context, "Please select State");
                  } else {
                    updateDistrict(
                            widget.districtList[widget.index!]["district_Id"])
                        .then((value) => setState(() {
                              fatchDistrict().then((value) => setState(() {
                                    widget.districtControllerEdit.clear();
                                    Navigator.pop(context);
                                  }));
                            }));
                  }
                },
                width: double.infinity,
                height: 52)
          ],
        )
      ]),
    );
  }

  //Get District
  Future fatchDistrict() async {
    var response =
        await ApiService.fetchData("MasterPayroll/GetDistrictPayroll");
    widget.districtList = response;
  }

// ignore_for_file: must_be_immutable

//Update District
  Future updateDistrict(id) async {
    var response = await ApiService.postData(
        'MasterPayroll/UpdateDistrictByIdPayroll?Id=$id', {
      "District_Name": widget.districtControllerEdit.text.toString(),
      "State_Id": widget.stateId,
      "Location_Id": 1
    });
    if (response['result'] == true) {
      showCustomSnackbarSuccess(context, '${response["message"]}');
    } else {
      showCustomSnackbar(context, '${response["message"]}');
    }
  }
}
