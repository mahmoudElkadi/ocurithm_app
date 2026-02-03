import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/views/widgets/branch_card.dart';

class BranchViewBody extends StatefulWidget {
  const BranchViewBody({super.key});

  @override
  State<BranchViewBody> createState() => _BranchViewBodyState();
}

class _BranchViewBodyState extends State<BranchViewBody> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getBranchesCubit = context.read<GetBranchesCubit>();

    return BlocBuilder<GetBranchesCubit, GetBranchesState>(
      builder: (context, state) => Column(
        children: [
          _buildSearchField(getBranchesCubit),
          const HeightSpacer(size: 10),
          const BranchListView()
        ],
      ),
    );
  }

  Widget _buildSearchField(GetBranchesCubit cubit) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            onTextFieldChanged: () async {
              cubit.onSearchChanged(searchController.text);
            },
            searchController: searchController,
            onClose: () {
              searchController.clear();
              cubit.onSearchChanged('');
            },
          ),
        ),
        InkWell(
          onTap: () {
            showFilterBottomSheet(context, cubit);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.filter_alt_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        )
      ],
    );
  }

  Future<void> showFilterBottomSheet(
      BuildContext context, GetBranchesCubit cubit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider(
        create: (_) => sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
        child: FilterBottomSheet(cubit: cubit),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.cubit});
  final GetBranchesCubit cubit;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool _isFilterLoading = false;
  bool _isResetLoading = false;
  String? _selectedClinicId;

  @override
  void initState() {
    super.initState();
    // Initialize selected clinic ID from cubit state
    _selectedClinicId = widget.cubit.state.clinicFilter;
  }

  Future<void> _handleFilter() async {
    if (_isFilterLoading || _isResetLoading) return;

    setState(() => _isFilterLoading = true);
    try {
      widget.cubit.add(SetClinicFilterEvent(_selectedClinicId));
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _isFilterLoading = false);
      }
    }
  }

  Future<void> _handleReset() async {
    if (_isFilterLoading || _isResetLoading) return;

    setState(() => _isResetLoading = true);
    try {
      _selectedClinicId = null;
      widget.cubit.add(ResetBranchFilters());
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _isResetLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        // Add subtle border in dark mode
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha:0.1),
                width: 1,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<GetClinicsCubit, GetClinicsState>(
            builder: (context, state) => DropdownItem(
              radius: 8,
              border: isDark ? Colors.grey.shade700 : Colors.grey,
              color: Theme.of(context).cardColor,
              isShadow: false,
              height: 14,
              iconData: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
              items: state.clinics?.clinics ?? [],
              validateText: 'Please choose a clinic',
              selectedValue: _selectedClinicId != null
                  ? state.clinics?.clinics
                      .where((c) => c.id == _selectedClinicId)
                      .firstOrNull
                      ?.name
                  : null,
              hintText: 'Select Clinic',
              itemAsString: (item) => item.name.toString(),
              onItemSelected: (item) {
                if (item != "Not Found") {
                  setState(() => _selectedClinicId = item.id);
                }
              },
              isLoading: state.clinics == null,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isFilterLoading || _isResetLoading
                      ? null
                      : _handleFilter,
                  child: _isFilterLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Apply Filter",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed:
                      _isFilterLoading || _isResetLoading ? null : _handleReset,
                  child: _isResetLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : const Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
