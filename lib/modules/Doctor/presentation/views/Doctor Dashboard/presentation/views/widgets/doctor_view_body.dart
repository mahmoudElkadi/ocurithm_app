import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../../core/utils/services_locator.dart';
import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../core/Network/shared.dart';
import '../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../core/widgets/search_fileld.dart';
import '../../../../../../../../../modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import '../../../../../../../../../modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart'
    as branch_cubit;
import '../../../../../manager/get_doctors_cubit/get_doctors_cubit.dart'
    as doctor_cubit;
import 'doctor_card.dart';

class DoctorViewBody extends StatefulWidget {
  const DoctorViewBody({super.key});

  @override
  State<DoctorViewBody> createState() => _DoctorViewBodyState();
}

class _DoctorViewBodyState extends State<DoctorViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<doctor_cubit.GetDoctorsCubit,
        doctor_cubit.GetDoctorsState>(
      builder: (context, state) => Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          const DoctorListView()
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final cubit = context.read<doctor_cubit.GetDoctorsCubit>();

    return Row(
      children: [
        Expanded(
          child: SearchField(
            onTextFieldChanged: ()async {
              cubit.onSearchChanged(_searchController.text);
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              cubit.onSearchChanged('');
            },
          ),
        ),
        InkWell(
          onTap: () {
            showFilterBottomSheet(context);
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
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        getDoctorsCubit: context.read<doctor_cubit.GetDoctorsCubit>(),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.getDoctorsCubit,
  });

  final doctor_cubit.GetDoctorsCubit getDoctorsCubit;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool _isFilterLoading = false;
  bool _isResetLoading = false;

  late GetClinicsCubit _clinicsCubit;
  late branch_cubit.GetBranchesCubit _branchesCubit;

  @override
  void initState() {
    super.initState();
    _clinicsCubit = sl<GetClinicsCubit>();
    _branchesCubit = sl<branch_cubit.GetBranchesCubit>();
    _loadClinics();
  }

  @override
  void dispose() {
    _clinicsCubit.close();
    _branchesCubit.close();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    if (CacheHelper.getStringList(key: "capabilities")
        .contains("manageCapability")) {
      _clinicsCubit.add(GetAllClinicsEvent());
    } else {
      final userClinicId = CacheHelper.getUser("user")?.clinic?.id;
      if (userClinicId != null) {
        _branchesCubit.add(branch_cubit.SetClinicFilterEvent(userClinicId));
      }
    }
  }

  Future<void> _handleFilter() async {
    if (_isFilterLoading || _isResetLoading) return;

    setState(() => _isFilterLoading = true);
    try {
      widget.getDoctorsCubit.add(doctor_cubit.GetAllDoctorsEvent());
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
      widget.getDoctorsCubit.add(doctor_cubit.ResetDoctorFilters());
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _isResetLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _clinicsCubit),
        BlocProvider.value(value: _branchesCubit),
      ],
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("manageCapability"))
              BlocBuilder<GetClinicsCubit, GetClinicsState>(
                builder: (context, clinicsState) {
                  return DropdownItem(
                    radius: 8,
                    border: Colorz.grey,
                    color: Colorz.white,
                    isShadow: false,
                    height: 14,
                    iconData: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colorz.grey),
                    items: clinicsState.clinics?.clinics ?? [],
                    validateText: 'Please choose a clinic',
                    selectedValue: widget.getDoctorsCubit.state.clinicFilter !=
                            null
                        ? clinicsState.clinics?.clinics
                            .firstWhere((c) =>
                                c.id ==
                                widget.getDoctorsCubit.state.clinicFilter)
                            .name
                        : null,
                    hintText: 'Select Clinic',
                    itemAsString: (item) => item.name.toString(),
                    onItemSelected: (item) {
                      if (item != "Not Found") {
                        widget.getDoctorsCubit
                            .add(doctor_cubit.SetClinicFilterEvent(item.id));
                        _branchesCubit
                            .add(branch_cubit.SetClinicFilterEvent(item.id));
                      }
                    },
                    isLoading: clinicsState.isLoading,
                  );
                },
              ),
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("manageCapability"))
              const SizedBox(height: 20),
            BlocBuilder<branch_cubit.GetBranchesCubit,
                branch_cubit.GetBranchesState>(
              builder: (context, branchesState) {
                return DropdownItem(
                  radius: 8,
                  border: Colorz.grey,
                  color: Colorz.white,
                  isShadow: false,
                  height: 14,
                  iconData: Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colorz.grey),
                  items: branchesState.branches?.branches ?? [],
                  validateText: 'Please choose a branch',
                  selectedValue: widget.getDoctorsCubit.state.branchFilter !=
                          null
                      ? branchesState.branches?.branches
                          .firstWhere((b) =>
                              b.id == widget.getDoctorsCubit.state.branchFilter)
                          .name
                      : null,
                  hintText: 'Select Branch',
                  itemAsString: (item) => item.name.toString(),
                  onItemSelected: (item) {
                    if (item != "Not Found") {
                      widget.getDoctorsCubit
                          .add(doctor_cubit.SetBranchFilterEvent(item.id));
                    }
                  },
                  isLoading: branchesState.isLoading,
                );
              },
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colorz.primaryColor,
                      side: BorderSide(color: Colorz.redColor),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isFilterLoading || _isResetLoading
                        ? null
                        : _handleReset,
                    child: _isResetLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colorz.redColor),
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
