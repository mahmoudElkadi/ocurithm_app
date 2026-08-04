import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import '../../manager/get_products_cubit/get_products_cubit.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final GetProductsCubit getProductsCubit;

  const ProductFilterBottomSheet({
    super.key,
    required this.getProductsCubit,
  });

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  bool _isFilterLoading = false;
  bool _isResetLoading = false;
  late GetClinicsCubit _clinicsCubit;
  late GetSubCategoriesCubit _subCategoriesCubit;

  @override
  void initState() {
    super.initState();
    _clinicsCubit = sl<GetClinicsCubit>();
    _subCategoriesCubit = sl<GetSubCategoriesCubit>();
    _loadInitialData();
  }

  @override
  void dispose() {
    _clinicsCubit.close();
    _subCategoriesCubit.close();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (CacheHelper.getStringList(key: "capabilities")
        .contains(CapabilityKeys.manageCapability)) {
      _clinicsCubit.add(GetAllClinicsEvent(noPagination: true));
    }
    _subCategoriesCubit.add(GetAllSubCategoriesEvent(noPagination: true));
  }

  Future<void> _handleFilter() async {
    if (_isFilterLoading || _isResetLoading) return;
    setState(() => _isFilterLoading = true);
    try {
      widget.getProductsCubit.add(GetAllProductsEvent());
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isFilterLoading = false);
    }
  }

  Future<void> _handleReset() async {
    if (_isFilterLoading || _isResetLoading) return;
    setState(() => _isResetLoading = true);
    try {
      widget.getProductsCubit.add(ResetProductFilters());
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isResetLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _clinicsCubit),
        BlocProvider.value(value: _subCategoriesCubit),
      ],
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlocBuilder<GetProductsCubit, GetProductsState>(
          bloc: widget.getProductsCubit,
          builder: (context, productState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filter Products",
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
                          selectedValue: productState.clinicFilter != null
                              ? clinicsState.clinics?.clinics
                                  .where((c) => c.id == productState.clinicFilter)
                                  .firstOrNull
                                  ?.name
                              : null,
                          hintText: 'Select Clinic',
                          itemAsString: (item) => item.name.toString(),
                          onItemSelected: (item) {
                            if (item != "Not Found") {
                              widget.getProductsCubit
                                  .add(SetProductClinicFilterEvent(item.id));
                            }
                          },
                          isLoading: clinicsState.isLoading,
                        ),
                      );
                    },
                  ),
                ),
                BlocBuilder<GetSubCategoriesCubit, GetSubCategoriesState>(
                  builder: (context, subCatState) {
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
                        items: subCatState.subCategories?.subCategories ?? [],
                        validateText: 'Please choose a sub-category',
                        selectedValue: productState.subCategoryFilter != null
                            ? subCatState.subCategories?.subCategories
                                .where((sc) =>
                                    sc.id == productState.subCategoryFilter)
                                .firstOrNull
                                ?.name
                            : null,
                        hintText: 'Select Sub-Category',
                        itemAsString: (item) => item.name.toString(),
                        onItemSelected: (item) {
                          if (item != "Not Found") {
                            widget.getProductsCubit
                                .add(SetProductSubCategoryFilterEvent(item.id));
                          }
                        },
                        isLoading: subCatState.isLoading,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)))
                            : const Text("Apply Filter",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? theme.cardColor : Colors.white,
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: Colorz.redColor),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
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
                                        Colorz.redColor)))
                            : Text("Reset",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colorz.redColor,
                                    fontWeight: FontWeight.w500)),
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
