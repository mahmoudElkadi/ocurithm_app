import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ocurithm/modules/Login/presentation/view/widgets/login_view_body.dart';

import '../../../../core/utils/colors.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: Colorz.white,
        body: const LoginViewBody(),
        bottomNavigationBar: Platform.isIOS
            ? const SizedBox()
            : BottomAppBar(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                height: 70,
                elevation: 0,
                color: Colors.white,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    "assets/icons/circle.svg",
                    height: 70,
                  ),
                ),
              ),
      ),
    );
  }
}
