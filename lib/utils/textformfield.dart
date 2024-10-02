import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payroll/utils/colors.dart';

class CommonTextFormField extends StatelessWidget {
  const CommonTextFormField(
      {this.height,
      this.width,
      this.validator,
      required this.controller,
      this.hintText,
      this.labelText,
      this.suffixIcon,
      this.textInputType,
      this.onchanged,
      this.inputFormatters,
      this.contentPadding,
      super.key});

  final double? height;
  final double? width;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final String? hintText;
  final Widget? suffixIcon;
  final String? labelText;
  final TextInputType? textInputType;
  final dynamic onchanged;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(
    BuildContext context,
  ) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return SizedBox(
        height: height,
        width: width,
        child: TextFormField(
            controller: controller,
            onChanged: onchanged,
            validator: validator,
            keyboardType: textInputType,
            cursorColor: AppColor.primery,
            style: TextStyle(
                color: AppColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: AppColor.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.primery, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColor.lightgrey)),
                hintText: hintText,
                labelText: labelText,
                hintStyle: TextStyle(color: AppColor.lightgrey, fontSize: 15),
                labelStyle: TextStyle(color: AppColor.lightgrey, fontSize: 15),
                contentPadding: contentPadding),
            inputFormatters: inputFormatters),
      );
    });
  }
}

DropdownButtonHideUnderline searchDropDown(
    BuildContext context,
    String hintText,
    List<DropdownMenuItem<Map<String, dynamic>>>? items,
    Map<String, dynamic>? value,
    Function(Map<String, dynamic>?)? onChanged,
    TextEditingController? controller,
    Function(String)? onChangedText,
    String hintTextInside,
    Function(bool)? onMenuStateChange) {
  return DropdownButtonHideUnderline(
    child: DropdownButton2<Map<String, dynamic>>(
      isExpanded: true,
      // ignore: prefer_const_constructors
      iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down)),
      alignment: Alignment.centerLeft,

      hint: Text(hintText,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColor.black)),
      items: items,
      value: value,
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          width: 200),
      dropdownStyleData: const DropdownStyleData(maxHeight: 200),
      menuItemStyleData: const MenuItemStyleData(height: 40),
      dropdownSearchData: DropdownSearchData(
          searchController: controller,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Container(
            height: 50,
            padding:
                const EdgeInsets.only(top: 8, bottom: 4, right: 8, left: 8),
            child: TextFormField(
              expands: true,
              readOnly: false,
              maxLines: null,
              controller: controller,
              onChanged: onChangedText,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintText: hintTextInside,
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )),
      onMenuStateChange: onMenuStateChange,
    ),
  );
}

Widget dropdownTextfield(
    BuildContext context, String? labelText, Widget? widget) {
  return SizedBox(
    height: 55,
    child: TextFormField(
      readOnly: true,
      initialValue: " ",
      decoration: InputDecoration(
          fillColor: AppColor.white,
          filled: true,
          suffix: SizedBox(width: double.infinity, child: widget),
          labelText: labelText,
          labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColor.lightgrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.primery, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColor.lightgrey))),
    ),
  );
}

Widget defaultDropDown({
  required Map<String, dynamic>? value,
  required List<DropdownMenuItem<Map<String, dynamic>>>? items,
  required void Function(Map<String, dynamic>?)? onChanged,
}) {
  return DropdownButton<Map<String, dynamic>>(
    underline: Container(),
    value: value,
    items: items,
    icon: const Icon(Icons.keyboard_arrow_down_outlined),
    isExpanded: true,
    onChanged: onChanged,
  );
}
