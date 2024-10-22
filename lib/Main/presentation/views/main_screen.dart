import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/colors.dart';
import '../manger/main_cubit.dart';
import '../manger/main_state.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        final mainCubit = MainCubit.get(context);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.grey.shade400, Colorz.background, Colorz.background],
              ),
            ),
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (
                child,
                animation,
                secondaryAnimation,
              ) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                  fillColor: Colors.transparent,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(mainCubit.currentIndex),
                child: mainCubit.currentScreen(mainCubit.currentIndex),
              ),
            ),
          ),
        );
      },
    );
  }
}
