// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:payroll/utils/colors.dart';

class OutsideContainer extends StatelessWidget {
  const OutsideContainer(
      {required this.child,
      this.height,
      this.width,
      this.borderRadius,
      this.boxBorder,
      this.BoxShadow,
      Key? key})
      : super(key: key);

  final Widget? child;
  final double? height;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? boxBorder;
  final BoxShadow;
  @override
  Widget build(
    BuildContext context,
  ) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: boxBorder,
            boxShadow: BoxShadow,
            borderRadius: borderRadius,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff4EB1C6), Color(0xff56C891)],
            )),
        child: child,
      );
    });
  }
}

//Reuse Conatiner
class ReuseContainer extends StatelessWidget {
  ReuseContainer({super.key, required this.title, required this.subtitle});
  String title;
  String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.white,
              border: Border.all(
                color: AppColor.grey,
              ),
              boxShadow: [BoxShadow(blurRadius: 2, color: AppColor.white)]),
          child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                                color: AppColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ))),
                  Expanded(
                      child: Container(
                          height: 50,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 10),
                          color: AppColor.primery.withOpacity(.1),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                                color: AppColor.primery,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ))),
                ],
              )),
        ),
      ],
    );
  }
}

datastylerow(String title, String subtitle) {
  return ListTile(
    dense: true,
    title: Text(
      title,
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.black),
    ),
    trailing: Text(
      subtitle.trim(),
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.grey),
      textAlign: TextAlign.end,
    ),
  );
}
