import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/loading_internet.dart';
import '../manger/main_cubit.dart';
import '../manger/main_state.dart';
import 'main_screen.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  DateTime timeBackPressed = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MainCubit()
        ..getStatusList(context: context)
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
              return false;
            },
            child: const MainScreen(),
          );
        },
      ),
    );
  }
}
