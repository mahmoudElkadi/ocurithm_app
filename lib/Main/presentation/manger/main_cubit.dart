import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:ocurithm/core/api/api_handler.dart';
import 'package:ocurithm/core/utils/network_connection.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/modules/Login/data/repos/login_repo.dart';
import 'package:ocurithm/modules/Accounting/presentation/views/accounts_view.dart';
import 'package:ocurithm/modules/Accounting/presentation/views/transactions/transactions_view.dart';
import 'package:ocurithm/modules/Branch/presentation/views/branch_view.dart';
import 'package:ocurithm/modules/Category/presentation/views/category_view.dart';
import 'package:ocurithm/modules/Chat/presentation/manager/chat_socket_bloc/chat_socket_bloc.dart';
import 'package:ocurithm/modules/Examination%20Type/presentation/views/examination_type_view.dart';
import 'package:ocurithm/modules/Order/presentation/views/order_view.dart';
import 'package:ocurithm/modules/Patient/presentation/views/Patient%20Dashboard/presentation/views/patient_view.dart';
import 'package:ocurithm/modules/Payment%20Methods/presentation/views/payment_method_view.dart';
import 'package:ocurithm/modules/Save%20Reasons/presentation/views/save_reason_view.dart';
import 'package:ocurithm/modules/Product/presentation/views/product_view.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/views/purchase_order_view.dart';
import 'package:ocurithm/modules/SubCategory/presentation/views/sub_category_view.dart';
import 'package:ocurithm/modules/Supplier/presentation/views/supplier_view.dart';

import '../../../core/Network/shared.dart';
import '../../../core/utils/app_style.dart';
import '../../../core/utils/capability_keys.dart';
import '../../../modules/Appointment/presentation/views/appointment_view.dart';
import '../../../modules/Clinics/presentation/views/clinic_view.dart';
import '../../../modules/Dashboard/presentation/views/dashboard_view.dart';
import '../../../modules/Doctor/presentation/views/Doctor Dashboard/presentation/views/doctor_view.dart';
import '../../../modules/Login/presentation/view/login_view.dart';
import '../../../modules/Medicine/presentation/views/medicine_view.dart';
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
    result = await NetworkStatus().hasInternetConnection();
    emit(ConnectionSuccess());
  }

  int notificationIndex = -1;

  Future<List<DrawerGroup>> getStatusList({context}) async {
    List<String> capabilities =
        List.from(CacheHelper.getStringList(key: "capabilities"));
    if (!capabilities.contains("dashboard")) {
      capabilities.add("dashboard");
    }

    // Mirrors the web sidebar in apps/web/src/app/admin/layout.tsx. An empty
    // `anyOf` means the entry is ungated there, so it is ungated here too.
    //
    // Previously this was two parallel maps keyed by capability, which is what
    // let the keys drift apart: `manageProducts` was listed as a group member
    // but the view was registered under `showProducts`, so Products could never
    // resolve and the screen was unreachable dead code.
    const Map<String, List<_DrawerEntry>> groupStructure = {
      "dashboard": [
        _DrawerEntry(
          title: "Dashboard",
          page: DashboardView(),
          icon: "assets/icons/dashboard.svg",
        ),
      ],
      "Patient Management": [
        _DrawerEntry(
          title: "Patients",
          page: AdminPatientView(),
          icon: "assets/icons/patient.svg",
          anyOf: [CapabilityKeys.showPatients],
        ),
        _DrawerEntry(
          title: "Appointments",
          page: AppointmentView(),
          icon: "assets/icons/appointment.svg",
          anyOf: [CapabilityKeys.showAppointments],
        ),
      ],
      "Management": [
        _DrawerEntry(
          title: "Clinics",
          page: ClinicView(),
          icon: "assets/icons/clinic.svg",
          anyOf: [CapabilityKeys.manageClinics],
        ),
        _DrawerEntry(
          title: "Branches",
          page: AdminBranchView(),
          icon: "assets/icons/branch.svg",
          anyOf: [CapabilityKeys.showBranches],
        ),
        _DrawerEntry(
          title: "Doctors",
          page: AdminDoctorView(),
          icon: "assets/icons/doctor.svg",
          anyOf: [CapabilityKeys.showDoctors],
        ),
        // Was `manageReciptionists` — a typo the backend never issues.
        _DrawerEntry(
          title: "Receptionists",
          page: ReceptionistView(),
          icon: "assets/icons/receptionist.svg",
          anyOf: [CapabilityKeys.manageReceptionists],
        ),
      ],
      "Configuration": [
        _DrawerEntry(
          title: "Examination Types",
          page: ExaminationTypeView(),
          icon: "assets/icons/exam_type.svg",
          anyOf: [CapabilityKeys.manageExaminationTypes],
        ),
        _DrawerEntry(
          title: "Payment Methods",
          page: PaymentMethodView(),
          icon: "assets/icons/payment.svg",
          anyOf: [CapabilityKeys.managePaymentMethods],
        ),
        _DrawerEntry(
          title: "Save Reasons",
          page: SaveReasonView(),
          icon: "assets/icons/payment.svg",
          anyOf: [CapabilityKeys.manageSaveReasons],
        ),
        _DrawerEntry(
          title: "Medicines",
          page: MedicineView(),
          icon: "assets/icons/medicine.svg",
          anyOf: [CapabilityKeys.manageMedicines],
        ),
      ],
      "Product": [
        _DrawerEntry(
          title: "Categories",
          page: CategoryView(),
          icon: "assets/icons/category.svg",
          anyOf: [CapabilityKeys.manageCategories],
        ),
        // Was `manageSubCategories`; the backend calls it `showSubcategories`.
        _DrawerEntry(
          title: "Sub-Categories",
          page: SubCategoryView(),
          icon: "assets/icons/subcategories.svg",
          anyOf: [CapabilityKeys.showSubcategories],
        ),
        // Either capability reveals it: the two maps disagreed about which one
        // gated this screen, and a user who can manage products must be able to
        // reach them.
        _DrawerEntry(
          title: "Products",
          page: ProductView(),
          icon: "assets/icons/products.svg",
          anyOf: [CapabilityKeys.showProducts, CapabilityKeys.manageProducts],
        ),
        // Ungated, matching web — the backend has no supplier or
        // purchase-order capability, so the old `manageSuppliers` /
        // `managePurchaseOrders` strings could never match.
        _DrawerEntry(
          title: "Suppliers",
          page: SupplierView(),
          icon: "assets/icons/suppliers.svg",
        ),
        _DrawerEntry(
          title: "Purchase Orders",
          page: PurchaseOrderView(),
          icon: "assets/icons/po.svg",
        ),
        _DrawerEntry(
          title: "Orders",
          page: OrderView(),
          icon: "assets/icons/po.svg",
          anyOf: [CapabilityKeys.showOrders],
        ),
      ],
      "Accounting": [
        _DrawerEntry(
          title: "Accounts",
          page: AccountsView(),
          icon: "assets/icons/payment.svg",
          anyOf: [CapabilityKeys.showAccounts],
        ),
        _DrawerEntry(
          title: "Transactions",
          page: TransactionsView(),
          icon: "assets/icons/po.svg",
          anyOf: [CapabilityKeys.showTransactions],
        ),
      ],
    };

    // Turns the next drawer typo into a loud debug failure instead of a
    // silently missing menu entry.
    CapabilityKeys.debugAssertKnown(
      groupStructure.values.expand((e) => e).expand((e) => e.anyOf),
      context: 'the navigation drawer',
    );

    drawerItems = [];
    drawerGroups = [];
    pages = [];
    int pageIndex = 0;

    int groupIndex = 0;
    for (var groupEntry in groupStructure.entries) {
      String groupName = groupEntry.key;
      List<DrawerItem> groupItems = [];

      for (final entry in groupEntry.value) {
        final bool hasAccess = entry.anyOf.isEmpty ||
            entry.anyOf.any(capabilities.contains) ||
            capabilities.contains(CapabilityKeys.manageCapability);

        if (hasAccess) {
          DrawerItem item = DrawerItem(
            icon: entry.icon,
            title: entry.title,
            index: pageIndex,
            capability: entry.anyOf.isEmpty ? '' : entry.anyOf.first,
          );

          groupItems.add(item);
          drawerItems.add(item);
          pages.add(entry.page);
          pageIndex++;
        }
      }

      if (groupItems.isNotEmpty) {
        drawerGroups.add(DrawerGroup(
          title: groupName == "dashboard" ? null : groupName,
          items: groupItems,
          groupIndex: groupIndex,
          isCollapsible:
              groupName != "dashboard", // Dashboard is not collapsible
        ));
        groupIndex++;
      }
    }

    if (pages.isNotEmpty && currentView == null) {
      currentView = pages[selectedIndex];
    }

    // Start with all groups collapsed
    _expandedGroupIndex = null;

    if (drawerItems.isEmpty || pages.isEmpty || capabilities.isEmpty) {
      if (context != null) {
        await logOut();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Login Failed"),
              content: const Text(
                  "You don't have permission to access this application"),
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

  /// [everywhere] invalidates every refresh token the user holds, not just
  /// this device's — used after a password change, matching web's
  /// ProfilePage (it calls `/auth/logout-all` once the new password is set).
  Future<void> logOut({bool everywhere = false}) async {
    emit(LogOutUserLoading());

    // Best-effort: a failed server call must never trap the user in a
    // logged-in shell, so local state is still cleared below regardless.
    // The refresh token has to be read before clearAuthData() removes it.
    try {
      final refreshToken = CacheHelper.getData(key: 'refreshToken');
      final loginRepo = sl<LoginRepo>();
      if (everywhere || refreshToken is! String || refreshToken.isEmpty) {
        await loginRepo.logoutAll();
      } else {
        await loginRepo.logout(refreshToken: refreshToken);
      }
    } catch (e) {
      log('Error calling server-side logout: $e');
    }

    // Disconnect chat socket
    try {
      sl<ChatSocketBloc>().add(DisconnectSocketEvent());
    } catch (e) {
      log('Error disconnecting socket during logout: $e');
    }

    getx.Get.offAll(() => const LoginView());
    await ApiHandler().clearAuthData();
    emit(LogOutUserSuccess());
  }
}

/// One navigation destination, with the capabilities that reveal it.
class _DrawerEntry {
  final String title;
  final Widget page;
  final String icon;

  /// Holding any one of these grants access. Empty means ungated — the same
  /// entries the web sidebar leaves without a `requiredCapability`.
  final List<String> anyOf;

  const _DrawerEntry({
    required this.title,
    required this.page,
    required this.icon,
    this.anyOf = const [],
  });
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
