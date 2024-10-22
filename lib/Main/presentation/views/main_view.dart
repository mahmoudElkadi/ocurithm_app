import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/loading_internet.dart';
import '../manger/main_cubit.dart';
import '../manger/main_state.dart';
import 'main_screen.dart';

class MainView extends StatefulWidget {
  const MainView({super.key, this.capabilities = const []});
  final List capabilities;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  DateTime timeBackPressed = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MainCubit()
        ..getStatusList(context: context, capabilities: widget.capabilities)
        ..enableBack()
        ..check(),
      child: BlocBuilder<MainCubit, MainState>(
        builder: (BuildContext context, state) {
          final mainCubit = MainCubit.get(context);
          if (mainCubit.result == false) {
            return const NoInternetScreen();
          }

          if (mainCubit.drawerItems.isEmpty) {
            return const LoadingScreen();
          }

          return WillPopScope(
            onWillPop: () async {
              // if (!mainCubit.isBackEnabled) {
              //   return false;
              // }
              //
              // final difference = DateTime.now().difference(timeBackPressed);
              // final isExitWarning = difference >= const Duration(seconds: 2);
              // timeBackPressed = DateTime.now();
              //
              // if (isExitWarning) {
              //   const message = 'Press back again to exit';
              //   Fluttertoast.showToast(msg: message, fontSize: 14, backgroundColor: Colorz.primaryColor);
              //   return false;
              // } else {
              //   SystemNavigator.pop();
              //   Fluttertoast.cancel();
              //   return true;
              // }
              return false;
            },
            child: const MainScreen(),
          );
        },
      ),
    );
  }
}
