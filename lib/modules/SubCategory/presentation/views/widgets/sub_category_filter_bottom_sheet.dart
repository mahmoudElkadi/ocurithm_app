import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Category/presentation/manager/get_categories_cubit/get_categories_cubit.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';

class SubCategoryFilterBottomSheet extends StatefulWidget {
  const SubCategoryFilterBottomSheet({super.key});

  @override
  State<SubCategoryFilterBottomSheet> createState() =>
      _SubCategoryFilterBottomSheetState();
}

class _SubCategoryFilterBottomSheetState
    extends State<SubCategoryFilterBottomSheet> {
  String? _selectedClinicId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<GetSubCategoriesCubit>();
    _selectedClinicId = cubit.state.clinicFilter;
    _selectedCategoryId = cubit.state.categoryFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<GetSubCategoriesCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => sl<GetClinicsCubit>()
              ..add(GetAllClinicsEvent(noPagination: true))),
        BlocProvider(
            create: (_) =>
                sl<GetCategoriesCubit>()..add(GetAllCategoriesEvent())),
      ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter Sub-Categories",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    cubit.add(ResetSubCategoryFilters());
                    Navigator.pop(context);
                  },
                  child:
                      const Text("Reset", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const HeightSpacer(size: 20),
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("manageCapability"))
              BlocBuilder<GetClinicsCubit, GetClinicsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Clinic",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const HeightSpacer(size: 10),
                      DropdownItem(
                        radius: 30,
                        isShadow: true,
                        color: theme.cardColor,
                        items: state.clinics?.clinics ?? [],
                        selectedValue: state.clinics?.clinics
                            .where((c) => c.id == _selectedClinicId)
                            .firstOrNull
                            ?.name,
                        hintText: "Select Clinic",
                        itemAsString: (item) => item.name ?? "",
                        onItemSelected: (item) =>
                            setState(() => _selectedClinicId = item.id),
                        isLoading: state.isLoading,
                      ),
                      const HeightSpacer(size: 15),
                    ],
                  );
                },
              ),
            const Text("Category",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const HeightSpacer(size: 10),
            BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
              builder: (context, state) {
                // Filter categories based on selected clinic if needed
                final categories = _selectedClinicId == null
                    ? state.categories?.categories ?? []
                    : state.categories?.categories
                            .where((c) => c.clinicId == _selectedClinicId)
                            .toList() ??
                        [];

                return DropdownItem(
                  radius: 30,
                  isShadow: true,
                  color: theme.cardColor,
                  items: categories,
                  selectedValue: categories
                      .where((c) => c.id == _selectedCategoryId)
                      .firstOrNull
                      ?.name,
                  hintText: "Select Category",
                  itemAsString: (item) => item.name ?? "",
                  onItemSelected: (item) =>
                      setState(() => _selectedCategoryId = item.id),
                  isLoading: state.isLoading,
                );
              },
            ),
            const HeightSpacer(size: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                cubit.add(SetSubCategoryClinicFilterEvent(_selectedClinicId));
                cubit.add(
                    SetSubCategoryCategoryFilterEvent(_selectedCategoryId));
                Navigator.pop(context);
              },
              child: const Text("Apply Filters",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const HeightSpacer(size: 10),
          ],
        ),
      ),
    );
  }
}
