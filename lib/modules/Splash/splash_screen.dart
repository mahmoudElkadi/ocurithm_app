// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:page_transition/page_transition.dart';
import 'package:upgrader/upgrader.dart';

import '../../Main/presentation/views/main_view.dart';
import '../../core/Network/shared.dart';
import '../../core/utils/config.dart';
import '../../core/widgets/height_spacer.dart';
import '../../core/widgets/no_internet.dart';
import '../Login/presentation/view/login_view.dart';
import '../On boarding/presentation/onBoarding.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  static const String id = 'LoadingScreen';

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<Widget> checkConnection() async {
    try {
      dynamic onBoarding = CacheHelper.getData(key: 'onBoarding');
      if (onBoarding != null) {
        return const SplashScreen();
      } else {
        return OnBoardingScreen();
      }
    } catch (e) {
      // Return an error widget
      return Scaffold(body: Center(child: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedSplashScreen.withScreenFunction(
      splash: Lottie.asset("assets/files/splash_screen.json"),
      screenFunction: checkConnection,
      backgroundColor: Colors.white,
      splashTransition: SplashTransition.scaleTransition,
      splashIconSize: size.height * 0.9,
      pageTransitionType: PageTransitionType.bottomToTop,
      duration: 2500,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
  }

  bool? result;

  Future<void> checkAuthAndNavigate() async {
    try {
      // Get the stored token
      result = await InternetConnection().hasInternetAccess;
      setState(() {});
      if (result == true) {
        final String? token = CacheHelper.getData(key: "token");
        // Prepare headers with token if available
        final headers = {
          'Content-Type': 'application/json',
          if (token != null) 'Cookie': 'ocurithmToken=$token',
        };

        // Make API request to check auth status
        final response = await http.get(
          Uri.parse('${Config.baseUrl}/me'),
          headers: headers,
        );

        if (!mounted) return;

        final responseData = json.decode(response.body);

        if (response.statusCode == 201 && responseData['message'] != 'No user logged in') {
          // User is authenticated, navigate to Main View

          Get.offAll(
            () => UpgradeAlert(
              showIgnore: false,
              showReleaseNotes: false,
              dialogStyle: UpgradeDialogStyle.cupertino,
              upgrader: Upgrader(
                countryCode: 'EG',
                durationUntilAlertAgain: const Duration(hours: 2),
              ),
              child: MainView(),
            ),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 1),
          );
        } else {
          // User is not authenticated, navigate to Login View
          CacheHelper.removeData(key: "token");
          CacheHelper.removeData(key: "user");
          Get.offAll(
            () => UpgradeAlert(
                showIgnore: false,
                showReleaseNotes: false,
                dialogStyle: UpgradeDialogStyle.cupertino,
                upgrader: Upgrader(
                  countryCode: 'EG',
                  durationUntilAlertAgain: const Duration(hours: 2),
                ),
                child: const LoginView()),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 1),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking authentication: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      // Navigate to login view in case of error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: result != false
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.5 - 40),
                  Image.asset(
                    "assets/icons/logo.png",
                    width: 80,
                    height: 80,
                  ),
                  Spacer(),
                  Center(
                      child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colorz.primaryColor,
                          ))),
                  HeightSpacer(size: 70),
                ],
              )
            : NoInternet(
                onPressed: () async {
                  await checkAuthAndNavigate();
                },
              ));
  }
}
