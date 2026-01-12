import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import '../../../../../core/utils/services_locator.dart';
import '../../../../../core/utils/app_style.dart';
import '../../data/model/medicine_model.dart';
import '../manager/get_active_ingredients_cubit/get_active_ingredients_cubit.dart';
import '../manager/get_medicines_cubit/get_medicines_cubit.dart';
import '../manager/medicine_actions_cubit/medicine_actions_cubit.dart';
import 'widgets/medicine_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class MedicineView extends StatelessWidget {
  const MedicineView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<GetMedicinesCubit>()..getMedicines()),
        BlocProvider(
            create: (context) =>
                sl<GetActiveIngredientsCubit>()..getActiveIngredients()),
        BlocProvider(create: (context) => sl<MedicineActionsCubit>()),
      ],
      child: BlocBuilder<GetMedicinesCubit, GetMedicinesState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Medicines",
            actions: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                            value: context.read<MedicineActionsCubit>()),
                        BlocProvider.value(
                            value: context.read<GetActiveIngredientsCubit>()),
                        BlocProvider.value(
                            value: context.read<GetMedicinesCubit>()),
                      ],
                      child: const MedicineBottomSheet(),
                    ),
                  ).then((_) {
                    context
                        .read<GetMedicinesCubit>()
                        .getMedicines(isRefresh: true);
                  });
                },
                icon: SvgPicture.asset(
                  "assets/icons/add_branch.svg",
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
            body: const _MedicineViewBody(),
          );
        },
      ),
    );
  }
}

class _MedicineViewBody extends StatefulWidget {
  const _MedicineViewBody();

  @override
  State<_MedicineViewBody> createState() => _MedicineViewBodyState();
}

class _MedicineViewBodyState extends State<_MedicineViewBody> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(context),
        const SizedBox(height: 10),
        const Expanded(child: _MedicinesList()),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final cubit = context.read<GetMedicinesCubit>();
    return SearchField(
      onTextFieldChanged: () async =>
          cubit.getMedicines(search: searchController.text, isRefresh: true),
      searchController: searchController,
      onClose: () {
        searchController.clear();
        cubit.getMedicines(isRefresh: true);
      },
    );
  }
}

class _MedicinesList extends StatelessWidget {
  const _MedicinesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMedicinesCubit, GetMedicinesState>(
      builder: (context, state) {
        if (state is GetMedicinesLoading) {
          return const _MedicineShimmerLoading();
        } else if (state is GetMedicinesError) {
          return Center(child: Text(state.error));
        } else if (state is GetMedicinesLoaded) {
          if (state.medicines.isEmpty) {
            return const Center(child: Text("No Medicines Found"));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.medicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final medicine = state.medicines[index];
              return _MedicineCard(medicine: medicine);
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        title: Text(medicine.name ?? "",
            style: appStyle(context, 16, isDark ? Colors.white : Colors.black,
                FontWeight.bold)),
        subtitle: Text(
          "${medicine.concentration != null ? '${medicine.concentration} - ' : ''}${medicine.activeIngredient?.name ?? 'No Ingredient'}",
          style: appStyle(context, 14, Colors.grey, FontWeight.normal),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                          value: context.read<MedicineActionsCubit>()),
                      BlocProvider.value(
                          value: context.read<GetActiveIngredientsCubit>()),
                    ],
                    child: MedicineBottomSheet(
                      medicine: medicine,
                      isEdit: true,
                      initialType: MedicineFormType.medicine,
                    ),
                  ),
                ).then((_) => context
                    .read<GetMedicinesCubit>()
                    .getMedicines(isRefresh: true));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context
                    .read<MedicineActionsCubit>()
                    .deleteMedicine(medicine.id!);
                Future.delayed(const Duration(milliseconds: 500), () {
                  context
                      .read<GetMedicinesCubit>()
                      .getMedicines(isRefresh: true);
                });
              },
            ),
          ],
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<MedicineActionsCubit>()),
                BlocProvider.value(
                    value: context.read<GetActiveIngredientsCubit>()),
              ],
              child: MedicineBottomSheet(
                medicine: medicine,
                isDetails: true,
                initialType: MedicineFormType.medicine,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MedicineShimmerLoading extends StatelessWidget {
  const _MedicineShimmerLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Card(
            color: isDark ? Colors.grey[900] : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              title: Container(
                height: 16,
                width: 100,
                decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.white,
                    borderRadius: BorderRadius.circular(4)),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.white,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
