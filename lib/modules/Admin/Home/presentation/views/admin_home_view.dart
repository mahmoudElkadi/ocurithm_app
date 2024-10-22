import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';

import '../../../../Splash/splash_screen.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        body: GestureDetector(
            onTap: () {
              Get.to(() => LoadingScreen());
            },
            child: Text("Admin Home")),
        title: "Admin Home");
  }
}
