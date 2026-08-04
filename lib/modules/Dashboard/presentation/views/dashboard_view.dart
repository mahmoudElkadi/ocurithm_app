import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Dashboard/presentation/views/widgets/dashboard_view_body.dart';

import '../../../../core/Network/shared.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/services_locator.dart';
import '../../../../core/widgets/no_internet.dart';
import '../manager/dashboard_cubit.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';

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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? ColorScheme.dark(
                  primary: Colorz.primaryColor,
                  onPrimary: Colors.white,
                  surface: const Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                )
              : ColorScheme.light(
                  primary: Colorz.primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
            dialogBackgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (context.mounted) {
        context.read<DashboardCubit>().add(GetDashboardEvent(
          start: picked.start,
          end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardCubit>()..add(GetDashboardEvent()),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Dashboard",
            actions: [
              if (CacheHelper.getStringList(key: "capabilities").contains(CapabilityKeys.manageCapability))
                IconButton(
                  onPressed: () {
                    _selectDateRange(context);
                  },
                  icon: Icon(Icons.calendar_month, color: Colorz.primaryColor),
                ),
            ],
            body: state.isNoConnection
                ? NoInternet(
                    onPressed: () {
                      context.read<DashboardCubit>().add(GetDashboardEvent());
                    },
                  )
                : state.isError && state.dashboardData == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage ?? "Something went wrong",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<DashboardCubit>().add(GetDashboardEvent());
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colorz.primaryColor),
                              child: const Text("Retry", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      )
                    : DashboardViewBody(
                        isLoading: state.isLoading,
                        dashboardData: state.dashboardData,
                        cubit: context.read<DashboardCubit>(),
                      ),
          );
        },
      ),
    );
  }
}
