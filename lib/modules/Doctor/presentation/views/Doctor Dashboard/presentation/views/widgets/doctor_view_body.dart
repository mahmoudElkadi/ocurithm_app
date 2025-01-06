import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../core/Network/shared.dart';
import '../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../core/widgets/search_fileld.dart';
import '../../../../../manager/doctor_cubit.dart';
import '../../../../../manager/doctor_state.dart';
import 'doctor_card.dart';

class DoctorViewBody extends StatefulWidget {
  const DoctorViewBody({super.key});

  @override
  State<DoctorViewBody> createState() => _DoctorViewBodyState();
}

class _DoctorViewBodyState extends State<DoctorViewBody> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) => Column(
        children: [_buildSearchField(DoctorCubit.get(context)), const HeightSpacer(size: 10), const DoctorListView()],
      ),
    );
  }

  Widget _buildSearchField(DoctorCubit cubit) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SearchField(
                onTextFieldChanged: () => cubit.getDoctors(),
                searchController: cubit.searchController,
                onClose: () {
                  cubit.searchController.clear();
                  cubit.getDoctors();
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

  Future<void> showFilterBottomSheet(BuildContext context, DoctorCubit cubit) {
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
  final DoctorCubit cubit;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool _isFilterLoading = false;
  bool _isResetLoading = false;

  @override
  void initState() {
    super.initState();

    _loadClinics();
  }

  Future<void> _loadClinics() async {
    if (widget.cubit.clinics == null && CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities")) {
      await widget.cubit.getClinics();
    } else {
      widget.cubit.getBranches(clinic: CacheHelper.getUser("user")?.clinic?.id);
    }
  }

  Future<void> _handleFilter() async {
    if (_isFilterLoading || _isResetLoading) return;

    setState(() => _isFilterLoading = true);
    try {
      await widget.cubit.getDoctors();
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
      widget.cubit.filterByClinic = null;
      widget.cubit.filterByBranch = null;
      await widget.cubit.getDoctors();
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
      child: BlocBuilder(
        bloc: widget.cubit,
        builder: (context, state) => Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities"))
              DropdownItem(
                radius: 8,
                border: Colorz.grey,
                color: Colorz.white,
                isShadow: false,
                height: 14,
                iconData: Icon(Icons.keyboard_arrow_down_rounded, color: Colorz.grey),
                items: widget.cubit.clinics?.clinics ?? [],
                validateText: 'Please choose a clinic',
                selectedValue: widget.cubit.filterByClinic?.name,
                hintText: 'Select Clinic',
                itemAsString: (item) => item.name.toString(),
                onItemSelected: (item) {
                  if (item != "Not Found") {
                    setState(() => widget.cubit.filterByClinic = item);
                    widget.cubit.getBranches();
                  }
                },
                isLoading: widget.cubit.clinics == null,
              ),
            DropdownItem(
              radius: 8,
              border: Colorz.grey,
              color: Colorz.white,
              isShadow: false,
              height: 14,
              iconData: Icon(Icons.keyboard_arrow_down_rounded, color: Colorz.grey),
              items: widget.cubit.branches?.branches ?? [],
              validateText: 'Please choose a branch',
              selectedValue: widget.cubit.filterByBranch?.name,
              hintText: 'Select Branch',
              itemAsString: (item) => item.name.toString(),
              onItemSelected: (item) {
                if (item != "Not Found") {
                  setState(() => widget.cubit.filterByBranch = item);
                }
              },
              isLoading: widget.cubit.loading,
            ),
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
      ),
    );
  }
}
