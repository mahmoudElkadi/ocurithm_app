import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import '../../manager/get_categories_cubit/get_categories_cubit.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';

class CategoryFilterBottomSheet extends StatefulWidget {
  final GetCategoriesCubit getCategoriesCubit;

  const CategoryFilterBottomSheet({
    super.key,
    required this.getCategoriesCubit,
  });

  @override
  State<CategoryFilterBottomSheet> createState() => _CategoryFilterBottomSheetState();
}

class _CategoryFilterBottomSheetState extends State<CategoryFilterBottomSheet> {
  bool _isFilterLoading = false;
  bool _isResetLoading = false;
  late GetClinicsCubit _clinicsCubit;

  @override
  void initState() {
    super.initState();
    _clinicsCubit = sl<GetClinicsCubit>();
    _loadClinics();
  }

  @override
  void dispose() {
    _clinicsCubit.close();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    if (CacheHelper.getStringList(key: "capabilities").contains(CapabilityKeys.manageCapability)) {
      _clinicsCubit.add(GetAllClinicsEvent(noPagination: true));
    }
  }

  Future<void> _handleFilter() async {
    if (_isFilterLoading || _isResetLoading) return;
    setState(() => _isFilterLoading = true);
    try {
      widget.getCategoriesCubit.add(GetAllCategoriesEvent());
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isFilterLoading = false);
    }
  }

  Future<void> _handleReset() async {
    if (_isFilterLoading || _isResetLoading) return;
    setState(() => _isResetLoading = true);
    try {
      widget.getCategoriesCubit.add(ResetCategoryFilters());
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isResetLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _clinicsCubit,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
          bloc: widget.getCategoriesCubit,
          builder: (context, categoryState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filter Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                manageCapability(
                  capability: 'manageCapability',
                  child: BlocBuilder<GetClinicsCubit, GetClinicsState>(
                    builder: (context, clinicsState) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: DropdownItem(
                          radius: 8,
                          border: isDark ? theme.dividerColor : Colorz.grey,
                          color: theme.cardColor,
                          isShadow: false,
                          height: 14,
                          iconData: Icon(Icons.keyboard_arrow_down_rounded,
                              color: isDark ? Colors.white70 : Colorz.grey),
                          items: clinicsState.clinics?.clinics ?? [],
                          validateText: 'Please choose a clinic',
                          selectedValue: categoryState.clinicFilter != null
                              ? clinicsState.clinics?.clinics
                                  .where((c) => c.id == categoryState.clinicFilter)
                                  .firstOrNull
                                  ?.name
                              : null,
                          hintText: 'Select Clinic',
                          itemAsString: (item) => item.name.toString(),
                          onItemSelected: (item) {
                            if (item != "Not Found") {
                              widget.getCategoriesCubit.add(SetClinicFilterEvent(item.id));
                              widget.getCategoriesCubit.add(SetPaginationEvent("false"));
                            }
                          },
                          isLoading: clinicsState.isLoading,
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _isFilterLoading || _isResetLoading ? null : _handleFilter,
                        child: _isFilterLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text("Apply Filter", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? theme.cardColor : Colors.white,
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: Colorz.redColor),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _isFilterLoading || _isResetLoading ? null : _handleReset,
                        child: _isResetLoading
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colorz.redColor)))
                            : Text("Reset", style: TextStyle(fontSize: 16, color: Colorz.redColor, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
