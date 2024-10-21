// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:async';
import 'dart:developer';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

import '../../core/Network/shared.dart';
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
      bool result = await InternetConnection().hasInternetAccess;
      if (result == true) {
        dynamic onBoarding = CacheHelper.getData(key: 'onBoarding');
        if (onBoarding != null) {
          if (CacheHelper.getData(key: "token") == null || CacheHelper.getData(key: "role") == null) {
            return const LoginView();
          } else if (CacheHelper.getData(key: "role") == "receptionist") {
            // return const MainView();
            // For now, return a placeholder widget
            return const Scaffold(body: Center(child: Text('Main View')));
          } else {
            // Handle other roles or return a default widget
            return const Scaffold(body: Center(child: Text('Default View')));
          }
        } else {
          log('onBoarding is null');
          return OnBoardingScreen();
        }
      } else {
        // Handle no internet connection
        return const Scaffold(body: Center(child: Text('No Internet Connection')));
      }
    } catch (e) {
      log('$e in loading screen');
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
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: size.height * 0.9,
      pageTransitionType: PageTransitionType.bottomToTop,
      duration: 2500,
    );
  }
}
