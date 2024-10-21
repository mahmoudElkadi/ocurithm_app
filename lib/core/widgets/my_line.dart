import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyLine extends StatelessWidget {
  const MyLine({super.key, this.height, this.color});
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      color: color ?? Colors.grey,
      height: height ?? 1.h,
    );
  }
}
