import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Admin/Home/presentation/views/admin_home_view.dart';

import '../../../core/Network/shared.dart';
import '../../../modules/Admin/Receptionist/presentation/views/receptionist_view.dart';
import '../../../modules/Login/presentation/view/login_view.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial());
  static MainCubit get(context) => BlocProvider.of(context);

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int newIndex) {
    _currentIndex = newIndex;
    emit(MainSuccess());
  }

  bool isBackEnabled = false;
  void enableBack() {
    Timer(const Duration(seconds: 2), () {
      isBackEnabled = true;
    });
    emit(EnableBack());
  }

  List<DrawerItem> drawerItems = [];
  List<Widget> pages = [];
  int selectedIndex = 0;
  Widget? currentView;

  Widget currentScreen(int index) {
    if (index < 0 || index >= pages.length) {
      return pages[0];
    }
    return pages[index];
  }

  bool? result;

  Future<void> check() async {
    result = await InternetConnection().hasInternetAccess;
    emit(ConnectionSuccess());
  }

  int notificationIndex = -1;

  List<DrawerItem> getStatusList() {
    List capabilities = ["receptionist", "doctor"];

    Map<String, List<dynamic>> statusMappings = {
      "doctor": ["Dashboard", const AdminHomeView(), "assets/icons/dashboard.svg"],
      "receptionist": ["Receptionist", const ReceptionistView(), "assets/icons/receptionist.svg"],
      "branch": ["Branch", const AdminHomeView(), "assets/icons/dashboard.svg"],
    };

    drawerItems = [];
    pages = [];
    int pageIndex = 0;

    if (capabilities.isNotEmpty) {
      for (var entry in statusMappings.entries) {
        String capability = entry.key;
        if (capabilities.contains(capability)) {
          drawerItems.add(DrawerItem(
            icon: entry.value[2],
            title: entry.value[0],
            index: pageIndex,
          ));
          pages.add(entry.value[1]);
          pageIndex++;
        }
      }

      if (pages.isNotEmpty && currentView == null) {
        currentView = pages[selectedIndex];
      }
    }

    emit(DrawerItemsLoaded()); // Emit a new state when drawer items are loaded
    return drawerItems;
  }

  void navigateToPage(BuildContext context, int index) {
    if (index >= 0 && index < pages.length) {
      selectedIndex = index;
      log("Selected index: $index");
      currentView = pages[index];
      getx.Get.offAll(() => pages[index], transition: getx.Transition.rightToLeft, duration: const Duration(milliseconds: 500));
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => pages[index]),
      // );
      emit(NavigateToPageState());
    }
  }

  void changeView(int index) {
    if (index >= 0 && index < pages.length) {
      selectedIndex = index;
      currentView = pages[index];
      emit(ChangeViewState());
    }
  }

  Future<void> logOut() async {
    emit(LogOutUserLoading());
    await CacheHelper.removeData(key: "token");
    await CacheHelper.removeData(key: "id");
    await CacheHelper.removeData(key: "domain");
    getx.Get.offAll(() => const LoginView());
    emit(LogOutUserSuccess());
  }
}

class DrawerItem {
  final String icon;
  final String title;
  final int index;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}
