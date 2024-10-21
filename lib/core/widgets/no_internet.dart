import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';

import '../utils/app_style.dart';
import '../utils/colors.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key, this.onPressed});
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            "assets/icons/no_internet.svg",
            height: 150.h,
            width: 150.w,
          ),
          const HeightSpacer(size: 20),
          Text(
            "You Are Offline ",
            style: appStyle(context, 20, Colors.black, FontWeight.w600),
          ),
          const HeightSpacer(size: 20),
          Text(
            textAlign: TextAlign.center,
            "Something Went Wrong. \n Try Refreshing The Page Or Checking \nYour Internet Connection. \n We'll See You in A Moment!",
            style: appStyle(context, 20, Colors.grey.shade600, FontWeight.w500),
          ),
          const HeightSpacer(size: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colorz.blue),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            onPressed: onPressed,
            child: Text("Try Again", style: appStyle(context, 20, Colors.white, FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
