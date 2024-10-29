import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../core/Network/shared.dart';
import '../../../core/utils/app_style.dart';
import '../../../modules/Admin/Doctor/presentation/views/Doctor Dashboard/presentation/views/doctor_view.dart';
import '../../../modules/Admin/Patient/presentation/views/Patient Dashboard/presentation/views/patient_view.dart';
import '../../../modules/Admin/Receptionist/presentation/views/Reception Dashboard/presentation/views/receptionist_view.dart';
import '../../../modules/Login/presentation/view/login_view.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial());
  static MainCubit get(context) => BlocProvider.of(context);

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

  int _currentIndex = 0;
  bool _isTransitioning = false;

  int get currentIndex => _currentIndex;

  set currentIndex(int newIndex) {
    if (newIndex != _currentIndex && !_isTransitioning) {
      _isTransitioning = true;
      _currentIndex = newIndex;
      emit(PageTransitionStarted(newIndex));

      // Allow next transition after current one completes
      Future.delayed(const Duration(milliseconds: 300), () {
        _isTransitioning = false;
        emit(PageTransitionCompleted(newIndex));
      });
    }
  }

  bool? result;

  Future<void> check() async {
    result = await InternetConnection().hasInternetAccess;
    emit(ConnectionSuccess());
  }

  int notificationIndex = -1;

  Future<List<DrawerItem>> getStatusList({context, required List capabilities}) async {
    Map<String, List<dynamic>> statusMappings = {
      "doctor": ["Patients", const AdminPatientView(), "assets/icons/dashboard.svg"],
      "admin": ["Receptionist", const ReceptionistView(), "assets/icons/receptionist.svg"],
      "branch": ["Doctor", const AdminDoctorView(), "assets/icons/dashboard.svg"],
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

    if (drawerItems.isEmpty || pages.isEmpty || capabilities == []) {
      await logOut();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Login Failed"),
            content: const Text("You don't have permission to access this application"),
            actions: [
              TextButton(
                child: Text(
                  "OK",
                  style: appStyle(context, 18, Colors.black, FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          );
        },
      );
      emit(LogOutUserSuccess());
    }

    emit(DrawerItemsLoaded()); // Emit a new state when drawer items are loaded
    return drawerItems;
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
