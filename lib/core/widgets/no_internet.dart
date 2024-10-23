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
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Oops!",
              style: appStyle(context, 24, Colors.black, FontWeight.w700),
            ),
            HeightSpacer(size: 20.h),
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
            AnimatedButton(
              onPressed: onPressed,
            )
          ],
        ),
      ),
    );
  }
}

// First, wrap your ElevatedButton with a StatefulWidget
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const AnimatedButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  AnimatedButtonState createState() => AnimatedButtonState(); // Removed asterisk
}

class AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  // Removed asterisk
  late AnimationController controller; // Removed asterisk
  late Animation<double> scale; // Removed asterisk

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      // Removed asterisk
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      // Removed asterisk
      CurvedAnimation(
        parent: controller, // Removed asterisk
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose(); // Removed asterisk
    super.dispose();
  }

  void _animateButton() async {
    await controller.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    await controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale, // Removed underscore
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colorz.blue), // Fixed MaterialStateProperty
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
        onPressed: _animateButton,
        child: Text("Try Again", style: appStyle(context, 20, Colors.white, FontWeight.w600)),
      ),
    );
  }
}
