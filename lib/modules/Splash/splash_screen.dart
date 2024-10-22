// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Main/presentation/views/main_view.dart';
import '../../core/Network/shared.dart';
import '../../core/widgets/height_spacer.dart';
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
          return const SplashScreen();
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

  Future<void> checkAuthAndNavigate() async {
    try {
      // Get the stored token
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = CacheHelper.getData(key: "token");
      log("token: $token");

      // Prepare headers with token if available
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Cookie': 'ocurithmToken=',
      };

      // Make API request to check auth status
      final response = await http.get(
        Uri.parse('http://192.168.0.106:3000/api/me'),
        headers: headers,
      );

      if (!mounted) return;
      log('${response.statusCode} ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['message'] != 'No user logged in') {
        // User is authenticated, navigate to Main View

        Get.offAll(
            () => MainView(
                  capabilities: responseData['user']['capabilities'],
                ),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 1));
      } else {
        // User is not authenticated, navigate to Login View
        CacheHelper.removeData(key: "token");
        CacheHelper.removeData(key: "user");
        Get.offAll(() => const LoginView(), transition: Transition.fadeIn, duration: const Duration(seconds: 1));
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
        body: Column(
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
                  color: Colorz.blue,
                ))),
        HeightSpacer(size: 70),
      ],
    ));
  }
}

// You might want to create an API service class for better organization
class ApiService {
  static const String baseUrl = 'http://192.168.0.106:3000/api';

  static Future<Map<String, dynamic>> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    log(response.body.toString());
    return json.decode(response.body);
  }
}

class AuthService {
  static const String baseUrl = 'http://192.168.0.106:3000/api';

  Future<bool> checkAuthStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers like authorization token if needed
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);
      return data['message'] != 'No user logged in';
    } catch (e) {
      print('Auth check error: $e');
      return false;
    }
  }
}

// Modified Splash Screen with auth checking
class MyCustomSplashScreen extends StatefulWidget {
  @override
  _MyCustomSplashScreenState createState() => _MyCustomSplashScreenState();
}

class _MyCustomSplashScreenState extends State<MyCustomSplashScreen> with TickerProviderStateMixin {
  double _fontSize = 2;
  double _containerSize = 1.5;
  double _textOpacity = 0.0;
  double _containerOpacity = 0.0;
  bool _showLoader = false;

  late AnimationController _controller;
  late Animation<double> animation1;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 3));

    animation1 = Tween<double>(begin: 40, end: 20).animate(CurvedAnimation(parent: _controller, curve: Curves.fastLinearToSlowEaseIn))
      ..addListener(() {
        setState(() {
          _textOpacity = 1.0;
        });
      });

    _controller.forward();

    Timer(Duration(seconds: 2), () {
      setState(() {
        _fontSize = 1.06;
      });
    });

    Timer(Duration(seconds: 2), () {
      setState(() {
        _containerSize = 2;
        _containerOpacity = 1;
      });
    });

    // Show loader after text animation
    Timer(Duration(seconds: 3), () {
      setState(() {
        _textOpacity = 0.0; // Fade out text
      });

      // Small delay before showing loader
      Timer(Duration(milliseconds: 200), () {
        setState(() {
          _showLoader = true; // Show loader
        });
      });
    });

    // Check auth and navigate
    Timer(Duration(seconds: 4), () async {
      bool isAuthenticated = await _authService.checkAuthStatus();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            isAuthenticated ? MainView() : LoginView(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 2000),
                curve: Curves.fastLinearToSlowEaseIn,
                height: _height / _fontSize,
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 1000),
                opacity: _textOpacity,
                child: Text(
                  'OCURITHM',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: animation1.value,
                  ),
                ),
              ),
              if (_showLoader)
                AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: 1.0,
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
          Center(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 2000),
              curve: Curves.fastLinearToSlowEaseIn,
              opacity: _containerOpacity,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 2000),
                curve: Curves.fastLinearToSlowEaseIn,
                height: _width / _containerSize,
                width: _width / _containerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Image.asset('assets/icons/logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing PageTransition class
class PageTransition extends PageRouteBuilder {
  final Widget page;

  PageTransition(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: Duration(milliseconds: 2000),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
              curve: Curves.fastLinearToSlowEaseIn,
              parent: animation,
            );
            return Align(
              alignment: Alignment.bottomCenter,
              child: SizeTransition(
                sizeFactor: animation,
                child: page,
                axisAlignment: 0,
              ),
            );
          },
        );
}
