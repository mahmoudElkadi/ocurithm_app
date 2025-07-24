import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Branch/presentation/views/branch_view.dart';
import 'package:ocurithm/modules/Examination%20Type/presentation/views/examination_type_view.dart';
import 'package:ocurithm/modules/Patient/presentation/views/Patient%20Dashboard/presentation/views/patient_view.dart';
import 'package:ocurithm/modules/Payment%20Methods/presentation/views/payment_method_view.dart';

import '../../../core/Network/shared.dart';
import '../../../core/utils/app_style.dart';
import '../../../modules/Appointment/presentation/views/appointment_view.dart';
import '../../../modules/Clinics/presentation/views/clinic_view.dart';
import '../../../modules/Dashboard/presentation/views/dashboard_view.dart';
import '../../../modules/Doctor/presentation/views/Doctor Dashboard/presentation/views/doctor_view.dart';
import '../../../modules/Login/presentation/view/login_view.dart';
import '../../../modules/Receptionist/presentation/views/Reception Dashboard/presentation/views/receptionist_view.dart';
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
  List<DrawerGroup> drawerGroups = [];
  List<Widget> pages = [];
  int selectedIndex = 0;
  Widget? currentView;

  // Add expansion state management
  int? _expandedGroupIndex;

  int? get expandedGroupIndex => _expandedGroupIndex;

  void toggleGroupExpansion(int groupIndex) {
    if (_expandedGroupIndex == groupIndex) {
      // Collapse the current group - allow all to be closed
      _expandedGroupIndex = null;
    } else {
      // Expand the new group (automatically collapses others)
      _expandedGroupIndex = groupIndex;
    }
    emit(GroupExpansionChanged(_expandedGroupIndex));
  }

  bool isGroupExpanded(int groupIndex) {
    return _expandedGroupIndex == groupIndex;
  }

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

  Future<List<DrawerGroup>> getStatusList({context}) async {
    List capabilities = CacheHelper.getStringList(key: "capabilities") ?? [];
    capabilities.add("dashboard");

    Map<String, List<dynamic>> statusMappings = {
      "dashboard": ["Dashboard", const DashboardView(), "assets/icons/dashboard.svg"],
      "showPatients": ["Patients", const AdminPatientView(), "assets/icons/patient.svg"],
      "showAppointments": ["Appointments", const AppointmentView(), "assets/icons/appointment.svg"],
      "manageClinics": ["Clinics", const ClinicView(), "assets/icons/clinic.svg"],
      "showBranches": ["Branches", const AdminBranchView(), "assets/icons/branch.svg"],
      "showDoctors": ["Doctors", const AdminDoctorView(), "assets/icons/doctor.svg"],
      "manageReciptionists": ["Receptionists", const ReceptionistView(), "assets/icons/receptionist.svg"],
      "manageExaminationTypes": ["Examination Types", const ExaminationTypeView(), "assets/icons/exam_type.svg"],
      "managePaymentMethods": ["Payment Methods", const PaymentMethodView(), "assets/icons/payment.svg"],
    };

    // Define groups structure
    Map<String, List<String>> groupStructure = {
      "dashboard": ["dashboard"],
      "Patient Management": ["showPatients", "showAppointments"],
      "Management": ["manageClinics", "showBranches", "showDoctors", "manageReciptionists"],
      "Configuration": ["manageExaminationTypes", "managePaymentMethods"],
    };

    drawerItems = [];
    drawerGroups = [];
    pages = [];
    int pageIndex = 0;

    if (capabilities.isNotEmpty) {
      int groupIndex = 0;
      for (var groupEntry in groupStructure.entries) {
        String groupName = groupEntry.key;
        List<String> groupCapabilities = groupEntry.value;
        List<DrawerItem> groupItems = [];

        for (String capability in groupCapabilities) {
          if (capabilities.contains(capability) && statusMappings.containsKey(capability)) {
            var mappingData = statusMappings[capability]!;

            DrawerItem item = DrawerItem(
              icon: mappingData[2],
              title: mappingData[0],
              index: pageIndex,
              capability: capability,
            );

            groupItems.add(item);
            drawerItems.add(item);
            pages.add(mappingData[1]);
            pageIndex++;
          }
        }

        if (groupItems.isNotEmpty) {
          drawerGroups.add(DrawerGroup(
            title: groupName == "dashboard" ? null : groupName,
            items: groupItems,
            groupIndex: groupIndex,
            isCollapsible: groupName != "dashboard", // Dashboard is not collapsible
          ));
          groupIndex++;
        }
      }

      if (pages.isNotEmpty && currentView == null) {
        currentView = pages[selectedIndex];
      }

      // Start with all groups collapsed
      _expandedGroupIndex = null;
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
    return drawerGroups;
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

    getx.Get.offAll(() => const LoginView());
    await CacheHelper.removeData(key: "token");
    await CacheHelper.removeData(key: "capabilities");
    await CacheHelper.removeData(key: "user");
    emit(LogOutUserSuccess());
  }
}

class DrawerItem {
  final String icon;
  final String title;
  final int index;
  final String capability;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.capability,
  });
}

class DrawerGroup {
  final String? title; // Null for dashboard (no group header)
  final List<DrawerItem> items;
  final int groupIndex;
  final bool isCollapsible;

  DrawerGroup({
    this.title,
    required this.items,
    required this.groupIndex,
    this.isCollapsible = true,
  });
}
