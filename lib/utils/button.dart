import 'package:flutter/material.dart';
import 'package:payroll/utils/colors.dart';
import 'package:payroll/utils/container.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.width,
    required this.height,
    super.key,
    required this.text,
    required this.press,
  });
  final String text;
  final Function() press;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: AppColor.green,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.26),
                blurRadius: 14,
                offset: Offset(0, 7),
              )
            ]),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  height: 1.2,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColor.text)),
        ),
      ),
    );
  }
}

class DefaultButton extends StatelessWidget {
  const DefaultButton(
      {required this.child,
      required this.hight,
      required this.width,
      required this.borderRadius,
      required this.boxShadow,
      this.onTap,
      super.key});

  final double hight;
  final double width;
  final Function()? onTap;
  final Widget? child;
  final BorderRadiusGeometry? borderRadius;
  final dynamic boxShadow;

  @override
  Widget build(
    BuildContext context,
  ) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return GestureDetector(
        onTap: onTap,
        child: OutsideContainer(
            height: hight,
            width: width,
            boxBorder: Border.all(
              color: AppColor.green,
              width: 1,
            ),
            borderRadius: borderRadius,
            child: Center(
              child: child,
            )),
      );
    });
  }
}

//Add masters
InkWell addDefaultButton(BuildContext context, Function()? onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
        height: 52,
        width: 52,
        margin: EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColor.white,
          border: Border.all(
            width: 1,
            color: AppColor.lightgrey,
          ),
        ),
        child: Icon(
          Icons.add,
          color: AppColor.black,
        )),
  );
}
