import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import '../../manager/get_accounts_cubit/get_accounts_cubit.dart';
import '../../manager/get_accounts_cubit/get_accounts_event.dart';

class AccountsFilterBottomSheet extends StatefulWidget {
  final GetAccountsCubit getAccountsCubit;

  const AccountsFilterBottomSheet({super.key, required this.getAccountsCubit});

  @override
  State<AccountsFilterBottomSheet> createState() => _AccountsFilterBottomSheetState();
}

class _AccountsFilterBottomSheetState extends State<AccountsFilterBottomSheet> {
  String? _selectedClinicId;
  String? _selectedAccountType;
  bool? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedClinicId = widget.getAccountsCubit.state.clinic;
    _selectedAccountType = widget.getAccountsCubit.state.accountType;
    _selectedStatus = widget.getAccountsCubit.state.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => sl<GetClinicsCubit>()..add(GetAllClinicsEvent(noPagination: true)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Accounts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const HeightSpacer(size: 20),
            BlocBuilder<GetClinicsCubit, GetClinicsState>(
              builder: (context, state) {
                return DropdownItem(
                  radius: 30,
                  color: theme.cardColor,
                  isShadow: false,
                  items: state.clinics?.clinics ?? [],
                  selectedValue: state.clinics?.clinics
                      .where((c) => c.id == _selectedClinicId)
                      .firstOrNull
                      ?.name,
                  hintText: "Filter by Clinic",
                  itemAsString: (item) => (item as dynamic).name,
                  onItemSelected: (item) => setState(() => _selectedClinicId = (item as dynamic).id),
                  isLoading: state.isLoading,
                );
              },
            ),
            const HeightSpacer(size: 15),
            DropdownItem(
              radius: 30,
              color: theme.cardColor,
              isShadow: false,
              items: const [
                "clinic",
                "doctor",
                "consultant",
                "receptionist",
                "branch",
                "paymentMethod",
                "supplier",
                "other"
              ],
              selectedValue: _selectedAccountType,
              hintText: "Filter by Account Type",
              itemAsString: (item) => item as String,
              onItemSelected: (item) => setState(() => _selectedAccountType = item as String),
              isLoading: false,
            ),
            const HeightSpacer(size: 15),
            DropdownItem(
              radius: 30,
              color: theme.cardColor,
              isShadow: false,
              items: const [true, false],
              selectedValue: _selectedStatus == null ? null : (_selectedStatus! ? "Active" : "Inactive"),
              hintText: "Filter by Status",
              itemAsString: (item) => (item as bool) ? "Active" : "Inactive",
              onItemSelected: (item) => setState(() => _selectedStatus = item as bool),
              isLoading: false,
            ),
            const HeightSpacer(size: 25),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      widget.getAccountsCubit.add(ResetAccountFilters());
                      Navigator.pop(context);
                    },
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      widget.getAccountsCubit.add(GetAllAccountsEvent(
                        clinic: _selectedClinicId,
                        accountType: _selectedAccountType,
                        isActive: _selectedStatus,
                        search: widget.getAccountsCubit.state.search,
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text("Apply", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
