import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Dashboard/data/repos/dashboard_repo_impl.dart';
import 'package:ocurithm/modules/Dashboard/presentation/views/widgets/dashboard_view_body.dart';

import '../../../../core/Network/shared.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/widgets/no_internet.dart';
import '../manager/dashboard_cubit.dart';
import '../manager/dashboard_state.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 7)),
      ),
      helpText: 'Select a date range',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Customize the color scheme
            colorScheme: ColorScheme.light(
              primary: Colorz.primaryColor, // Primary color for headers and selected dates
              onPrimary: Colors.white, // Text color on primary color
              surface: Colors.white, // Background color of the date picker
              onSurface: Colors.black, // Text color on the surface
            ),
            // Customize the text theme
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black), // Text color for dates
              bodyMedium: TextStyle(color: Colors.black), // Text color for headers
            ),
            // Customize the dialog background
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Handle the selected date range
      DashboardCubit.get(context).getDashboard(
        start: picked.start,
        end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(DashboardRepoImpl())..getDashboard(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => CustomScaffold(
          body: DashboardCubit.get(context).connection != false
              ? CustomMaterialIndicator(
                  onRefresh: () async {
                    try {
                      DashboardCubit.get(context).getDashboard();
                    } catch (e) {
                      log(e.toString());
                    }
                  },
                  indicatorBuilder: (BuildContext context, IndicatorController controller) {
                    return const Image(image: AssetImage("assets/icons/logo.png"));
                  },
                  child: DashboardViewBody(
                    isLoading: DashboardCubit.get(context).dashboard == null,
                    dashboardData: DashboardCubit.get(context).dashboard,
                    cubit: DashboardCubit.get(context), // Pass the cubit
                  ),
                )
              : NoInternet(
                  onPressed: () {
                    DashboardCubit.get(context).getDashboard();
                  },
                ),
          actions: [
            if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities"))
              IconButton(
                onPressed: () {
                  _selectDateRange(context);
                },
                icon: Icon(Icons.calendar_month, color: Colorz.primaryColor),
              ),
          ],
          title: "Dashboard",
        ),
      ),
    );
  }
}
