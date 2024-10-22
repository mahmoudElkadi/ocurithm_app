import 'package:flutter/material.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../../Main/presentation/manger/main_cubit.dart';
import '../utils/app_style.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Oops!",
              style: appStyle(context, 28, Colors.black, FontWeight.w600),
            ),
            const SizedBox(height: 35),
            Icon(
              Icons.wifi_off,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              "You Are Offline",
              style: appStyle(context, 20, Colors.black, FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Something Went Wrong. Try Refreshing The Page Or Checking Your Internet Connection.",
                textAlign: TextAlign.center,
                style: appStyle(context, 20, Colors.grey.shade600, FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colorz.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              onPressed: () {
                MainCubit.get(context)..check();
              },
              child: Text(
                "Try Again",
                style: appStyle(context, 20, Colors.white, FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
