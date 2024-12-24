import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/widgets/height_spacer.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../core/widgets/search_fileld.dart';
import '../../../../Clinics/data/model/clinics_model.dart';
import '../../manager/branch_cubit.dart';
import '../../manager/branch_state.dart';
import 'branch_card.dart';

class BranchViewBody extends StatefulWidget {
  const BranchViewBody({super.key});

  @override
  State<BranchViewBody> createState() => _BranchViewBodyState();
}

class _BranchViewBodyState extends State<BranchViewBody> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final cubit = AdminBranchCubit.get(context);
    return BlocBuilder<AdminBranchCubit, AdminBranchState>(
      builder: (context, state) => Column(
        children: [_buildSearchField(cubit), const HeightSpacer(size: 10), const BranchListView()],
      ),
    );
  }

  Widget _buildSearchField(AdminBranchCubit cubit) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SearchField(
                onTextFieldChanged: () => cubit.getBranches(),
                searchController: cubit.searchController,
                onClose: () {
                  cubit.searchController.clear();
                  cubit.getBranches();
                }),
          ),
          InkWell(
            onTap: () {
              showFilterBottomSheet(context, cubit);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.filter_alt_outlined,
                color: Colorz.primaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> showFilterBottomSheet(BuildContext context, AdminBranchCubit cubit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(cubit: cubit),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.cubit});
  final AdminBranchCubit cubit;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool _isFilterLoading = false;
  bool _isResetLoading = false;
  Clinic? _selectedClinic;

  @override
  void initState() {
    super.initState();
    _selectedClinic = widget.cubit.filterByClinic;
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    if (widget.cubit.clinics == null) {
      await widget.cubit.getClinics();
    }
  }

  Future<void> _handleFilter() async {
    if (_isFilterLoading || _isResetLoading) return;

    setState(() => _isFilterLoading = true);
    try {
      widget.cubit.filterByClinic = _selectedClinic;
      await widget.cubit.getBranches();
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
      _selectedClinic = null;
      widget.cubit.filterByClinic = null;
      await widget.cubit.getBranches();
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _isResetLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AdminBranchCubit, AdminBranchState>(
            bloc: widget.cubit,
            builder: (context, state) => DropdownItem(
              radius: 8,
              border: Colorz.grey,
              color: Colorz.white,
              isShadow: false,
              height: 14,
              iconData: Icon(Icons.keyboard_arrow_down_rounded, color: Colorz.grey),
              items: widget.cubit.clinics?.clinics ?? [],
              validateText: 'Please choose a clinic',
              selectedValue: _selectedClinic?.name,
              hintText: 'Select Clinic',
              itemAsString: (item) => item.name.toString(),
              onItemSelected: (item) {
                if (item != "Not Found") {
                  setState(() => _selectedClinic = item);
                }
              },
              isLoading: widget.cubit.clinics == null,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorz.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isFilterLoading || _isResetLoading ? null : _handleFilter,
                  child: _isFilterLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
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
                    backgroundColor: Colors.white,
                    foregroundColor: Colorz.primaryColor,
                    side: BorderSide(color: Colorz.redColor),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isFilterLoading || _isResetLoading ? null : _handleReset,
                  child: _isResetLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colorz.redColor),
                          ),
                        )
                      : Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colorz.redColor,
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
