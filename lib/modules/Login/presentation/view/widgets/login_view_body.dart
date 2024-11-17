import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocurithm/generated/l10n.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/height_spacer.dart';
import 'form_login.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200.h,
            child: CustomPaint(
                painter: QuadrilateralPainter(),
                child: Column(
                  children: [
                    HeightSpacer(size: 40.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colorz.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/icons/logo.png",
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Text("OCURITHM", style: appStyle(context, 40, Colorz.white, FontWeight.bold)),
                  ],
                )),
          ),
          HeightSpacer(size: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [
                  Text(S.of(context).hello, style: GoogleFonts.trocchi(color: Colorz.primaryColor, fontSize: 40.spMin)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset("assets/icons/login_icon.svg"),
                      Text(S.of(context).pleaseSignInToYourAccount, style: appStyle(context, 16, Colorz.primaryColor, FontWeight.w400)),
                      SvgPicture.asset(
                        "assets/icons/login_icon.svg",
                        colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ]),
                HeightSpacer(size: 30.h),
                const LoginForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuadrilateralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colorz.primaryColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0) // Top-left point
      ..lineTo(size.width, 0) // Top-right point
      ..lineTo(size.width, size.height * 0.5) // Bottom-right point
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 1.5, // Control point for the curve
        0, size.height * 0.5, // Bottom-left point
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
