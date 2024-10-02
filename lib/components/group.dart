// ignore_for_file: body_might_complete_normally_nullable, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously, avoid_print, empty_catches

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/components/api.dart';
import 'package:payroll/model/mismaster_group.dart';
import 'package:payroll/utils/button.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/mediaquery.dart';
import 'package:payroll/utils/textformfield.dart';

class AddGroupScreen extends StatefulWidget {
  int? sourecID;
  String? name;
  AddGroupScreen({super.key, this.sourecID, required this.name});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  var Groupcontroller = TextEditingController();
  bool isSearchMode = false;

  List<Map<String, dynamic>> listToUpdate = [];

  final TextEditingController _editController = TextEditingController();
  @override
  void initState() {
    fetchDataByMiscType().then((value) => setState(() {}));
    super.initState();
    // postData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add ${widget.name}"),
        flexibleSpace: const OutsideContainer(child: Column()),
        leading: IconButton(
            onPressed: () {
              fetchDataByMiscType().then((value) => setState(() {}));
              Navigator.pop(context, "refresh");
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      backgroundColor: AppColor.white,
      body: Container(
        height: double.infinity,
        color: AppColor.primery.withOpacity(.1),
        padding: EdgeInsets.symmetric(
            vertical: Sizes.height * 0.04, horizontal: Sizes.width * .04),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CommonTextFormField(
                controller: Groupcontroller,
                validator: (p0) {},
                labelText: "Group",
                // prefixIcon: Icon(
                //   Icons.code,
                //   color: AppColor.colGrey,
                // )
              ),
              SizedBox(height: Sizes.height * 0.05),
              DefaultButton(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  postData();
                },
                hight: 50,
                width: double.infinity,
                boxShadow: const [BoxShadow()],
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: Sizes.height * 0.02),
              ...List.generate(listToUpdate.length, (index) {
                return ListTile(
                  leading: Text("${index + 1}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.black)),
                  horizontalTitleGap: 0,
                  title: Text(
                    listToUpdate[index]['name'],
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColor.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Edit ${widget.name}'),
                                    content: CommonTextFormField(
                                        controller: _editController,
                                        labelText: "Edit"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          editMismaster(
                                                  listToUpdate[index]['id'],
                                                  _editController.text
                                                      .toString())
                                              .then((value) => setState(() {
                                                    fetchDataByMiscType().then(
                                                        (value) =>
                                                            setState(() {}));
                                                    Navigator.pop(context);
                                                    _editController.clear();
                                                  }));
                                        },
                                        child: Text(
                                          'Save',
                                          style: TextStyle(color: AppColor.red),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: Icon(
                            Icons.edit,
                            color: AppColor.primery,
                          )),
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete ${widget.name}'),
                                    content: Text(
                                        'Are you sure you want to delete ${listToUpdate[index]['name']} ?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deleteMismaster(
                                                  listToUpdate[index]['id'])
                                              .then((value) => setState(() {
                                                    fetchDataByMiscType().then(
                                                        (value) =>
                                                            setState(() {}));
                                                    Navigator.pop(context);
                                                  }));
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: AppColor.red),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: Icon(
                            Icons.delete,
                            color: AppColor.red,
                          )),
                    ],
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchDataByMiscType() async {
    final data = await ApiService.fetchData(
        "MasterAW/GetMiscMasterFixed?MiscTypeId=${widget.sourecID}");
    final List<Mismastermodel> mismastermodelList =
        mismastermodelFromJson(jsonEncode(data));
    listToUpdate.clear();
    for (var item in mismastermodelList) {
      listToUpdate.add({'id': item.id, 'name': item.name});
    }
    setState(() {});
  }

  Future<void> postData() async {
    final url =
        Uri.parse('http://lms.muepetro.com/api/UserController1/PostMiscMaster');
    final data = {
      "Name": Groupcontroller.text,
      "LocationId": 1,
      "MiscMasterId": widget.sourecID,
    };
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['result'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Details saved successfully"),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context);
        } else if (responseData['message'] == "Name already exists") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Name already exists. Please use a different name."),
            backgroundColor: Colors.red,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("An error occurred while saving the details"),
            backgroundColor: Colors.red,
          ));
        }
      } else {}
    } catch (e) {}
  }

  Future deleteMismaster(int? id) async {
    var response = await ApiService.postData(
        "UserController1/DeleteMiscMasterById?Id=$id", {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response['message']),
      backgroundColor: AppColor.primery,
    ));
  }

  Future editMismaster(
    int? id,
    controller,
  ) async {
    var response = await ApiService.postData(
        "UserController1/UpdateMiscMasterById?Id=$id", {
      "Name": controller,
      "LocationId": 1,
      "MiscMasterId": widget.sourecID,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response['message']),
      backgroundColor: AppColor.primery,
    ));
  }
}
