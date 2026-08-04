import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart';
import 'package:ocurithm/modules/Order/presentation/manager/get_orders_cubit/get_orders_bloc.dart';

const _statusOptions = ["all", "completed", "cancelled"];

class OrderFilterSheet extends StatefulWidget {
  const OrderFilterSheet({super.key});

  @override
  State<OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<OrderFilterSheet> {
  String? _selectedStatus;
  String? _selectedBranchId;
  String? _selectedDoctorId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final state = context.read<GetOrdersBloc>().state;
    _selectedStatus = state.statusFilter;
    _selectedBranchId = state.branchFilter;
    _selectedDoctorId = state.doctorFilter;
    _startDate = state.startDate != null ? DateTime.tryParse(state.startDate!) : null;
    _endDate = state.endDate != null ? DateTime.tryParse(state.endDate!) : null;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return "Select";
    final fmt = DateFormat('dd/MM/yy');
    return "${fmt.format(_startDate!)} - ${fmt.format(_endDate!)}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GetBranchesCubit>()
            ..add(GetAllBranchesEvent(noPagination: true)),
        ),
        BlocProvider(
          create: (_) => sl<GetDoctorsCubit>()
            ..add(GetAllDoctorsEvent(noPagination: true)),
        ),
      ],
      child: BlocBuilder<GetBranchesCubit, GetBranchesState>(
        builder: (context, branchesState) {
          return BlocBuilder<GetDoctorsCubit, GetDoctorsState>(
            builder: (context, doctorsState) {
              final branches = branchesState.branches?.branches ?? [];
              final doctors = doctorsState.doctors?.doctors ?? [];

              return Container(
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const HeightSpacer(size: 24),
                      Text("Filter Orders",
                          style: appStyle(
                              context,
                              20,
                              theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              FontWeight.w800)),
                      const HeightSpacer(size: 24),
                      DropdownItem(
                        label: "Status",
                        border: Colors.grey.shade300,
                        radius: 15,
                        items: _statusOptions,
                        selectedValue: _selectedStatus ?? "all",
                        hintText: "Select status",
                        itemAsString: (item) =>
                            (item as String).toUpperCase(),
                        onItemSelected: (item) =>
                            setState(() => _selectedStatus = item as String),
                        isShadow: false,
                        isLoading: false,
                      ),
                      const HeightSpacer(size: 16),
                      DropdownItem(
                        label: "Branch",
                        border: Colors.grey.shade300,
                        radius: 15,
                        items: branches,
                        selectedValue: branches
                            .where((b) => b.id == _selectedBranchId)
                            .firstOrNull
                            ?.name,
                        hintText: "All branches",
                        itemAsString: (item) => (item as dynamic).name ?? "",
                        onItemSelected: (item) => setState(
                            () => _selectedBranchId = (item as dynamic).id),
                        isShadow: false,
                        isLoading: branchesState.isLoading,
                      ),
                      const HeightSpacer(size: 16),
                      DropdownItem(
                        label: "Doctor",
                        border: Colors.grey.shade300,
                        radius: 15,
                        items: doctors,
                        selectedValue: doctors
                            .where((d) => d.id == _selectedDoctorId)
                            .firstOrNull
                            ?.name,
                        hintText: "All doctors",
                        itemAsString: (item) => (item as dynamic).name ?? "",
                        onItemSelected: (item) => setState(
                            () => _selectedDoctorId = (item as dynamic).id),
                        isShadow: false,
                        isLoading: doctorsState.isLoading,
                      ),
                      const HeightSpacer(size: 16),
                      InkWell(
                        onTap: () => _pickDateRange(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Date Range",
                                  style: appStyle(context, 12, Colors.grey,
                                      FontWeight.w500)),
                              Text(_formatDateRange(),
                                  style: appStyle(
                                      context,
                                      14,
                                      theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const HeightSpacer(size: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context
                                    .read<GetOrdersBloc>()
                                    .add(ResetOrderFilters());
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 55),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text("Reset",
                                  style: appStyle(context, 16,
                                      theme.primaryColor, FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final bloc = context.read<GetOrdersBloc>();
                                // GetAllOrdersEvent merges non-null fields
                                // onto the current state (so pagination-only
                                // calls don't drop existing filters) — reset
                                // first so a filter the user just cleared
                                // doesn't stick around from the old state.
                                bloc.add(ResetOrderFilters());
                                bloc.add(
                                  GetAllOrdersEvent(
                                    page: 1,
                                    status: _selectedStatus == "all"
                                        ? null
                                        : _selectedStatus,
                                    branch: _selectedBranchId,
                                    doctor: _selectedDoctorId,
                                    startDate: _startDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(_startDate!)
                                        : null,
                                    endDate: _endDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(_endDate!)
                                        : null,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                minimumSize: const Size(0, 55),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: Text("Apply",
                                  style: appStyle(context, 16, Colors.white,
                                      FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
