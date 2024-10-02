// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

Widget addMasterOutside(
    {required List<Widget> children, required BuildContext context}) {
  return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: MediaQuery.of(context).size.width < 600
          ? MediaQuery.of(context).size.width >= 450
              ? 6
              : MediaQuery.of(context).size.width <= 450
                  ? 4
                  : 6
          : MediaQuery.of(context).size.width < 1100 &&
                  MediaQuery.of(context).size.width >= 600
              ? MediaQuery.of(context).size.width >= 800
                  ? 3.2
                  : 4
              : 4,
      shrinkWrap: true,
      crossAxisSpacing: MediaQuery.of(context).size.width * 0.02,
      crossAxisCount: MediaQuery.of(context).size.width < 600
          ? 1
          : MediaQuery.of(context).size.width < 1100 &&
                  MediaQuery.of(context).size.width >= 600
              ? MediaQuery.of(context).size.width >= 800
                  ? 3
                  : 2
              : 3,
      children: children);
}
