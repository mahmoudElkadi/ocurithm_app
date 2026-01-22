import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import '../../../../../core/utils/services_locator.dart';
import '../../../../../core/utils/app_style.dart';
import '../../data/model/medicine_model.dart';
import '../../data/model/active_ingredient_model.dart';
import '../manager/get_active_ingredients_cubit/get_active_ingredients_cubit.dart';
import '../manager/get_medicines_cubit/get_medicines_cubit.dart';
import '../manager/medicine_actions_cubit/medicine_actions_cubit.dart';
import 'widgets/medicine_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

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
                        BlocProvider(
                          create: (context) =>
                              sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
                        ),
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

  bool _isMedicines = true;

  void _onToggle(bool isMedicines) {
    setState(() {
      _isMedicines = isMedicines;
    });
    // Trigger initial fetch if switching
    if (isMedicines) {
      context.read<GetMedicinesCubit>().getMedicines(isRefresh: true);
    } else {
      context.read<GetActiveIngredientsCubit>().getActiveIngredients();
    }
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: _isMedicines
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _onToggle(true),
                        borderRadius: BorderRadius.circular(25),
                        child: Center(
                          child: Text(
                            "Medicines",
                            style: TextStyle(
                              color: _isMedicines ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _onToggle(false),
                        borderRadius: BorderRadius.circular(25),
                        child: Center(
                          child: Text(
                            "Active Ingredients",
                            style: TextStyle(
                              color: !_isMedicines ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildSearchField(context),
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_isMedicines) {
                await context
                    .read<GetMedicinesCubit>()
                    .getMedicines(isRefresh: true);
              } else {
                await context
                    .read<GetActiveIngredientsCubit>()
                    .getActiveIngredients();
              }
            },
            child: _isMedicines
                ? const _MedicinesList()
                : const _ActiveIngredientsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final cubit = context.read<GetMedicinesCubit>();
    return SearchField(
      onTextFieldChanged: () async {
        if (_isMedicines) {
          cubit.getMedicines(search: searchController.text, isRefresh: true);
        } else {
          context
              .read<GetActiveIngredientsCubit>()
              .getActiveIngredients(search: searchController.text);
        }
      },
      searchController: searchController,
      onClose: () {
        searchController.clear();
        if (_isMedicines) {
          cubit.getMedicines(isRefresh: true);
        } else {
          context.read<GetActiveIngredientsCubit>().getActiveIngredients();
        }
      },
    );
  }
}

class _ActiveIngredientsList extends StatelessWidget {
  const _ActiveIngredientsList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicineActionsCubit, MedicineActionsState>(
      listener: (context, actionState) {
        if (actionState is MedicineActionsSuccess) {
          context.read<GetActiveIngredientsCubit>().getActiveIngredients();
        }
      },
      builder: (context, actionState) {
        return BlocBuilder<GetActiveIngredientsCubit,
            GetActiveIngredientsState>(
          builder: (context, state) {
            if (state is GetActiveIngredientsLoading) {
              return const _MedicineShimmerLoading();
            } else if (state is GetActiveIngredientsError) {
              return Center(child: Text(state.error));
            } else if (state is GetActiveIngredientsLoaded) {
              if (state.activeIngredients.isEmpty) {
                return const Center(child: Text("No Active Ingredients Found"));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.activeIngredients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final activeIngredient = state.activeIngredients[index];
                  return _ActiveIngredientCard(
                      activeIngredient: activeIngredient);
                },
              );
            }
            return const SizedBox();
          },
        );
      },
    );
  }
}

class _ActiveIngredientCard extends StatelessWidget {
  final ActiveIngredient activeIngredient;
  const _ActiveIngredientCard({required this.activeIngredient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        title: Text(activeIngredient.name ?? "",
            style: appStyle(context, 16, isDark ? Colors.white : Colors.black,
                FontWeight.bold)),
        subtitle: activeIngredient.clinic?.name != null
            ? Text("Clinic: ${activeIngredient.clinic!.name}",
                style: appStyle(context, 14, Colors.grey, FontWeight.normal))
            : null,
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
                      BlocProvider(
                        create: (context) =>
                            sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
                      ),
                    ],
                    child: MedicineBottomSheet(
                      activeIngredient: activeIngredient,
                      isEdit: true,
                      initialType: MedicineFormType.activeIngredient,
                    ),
                  ),
                ).then((_) {
                  context
                      .read<GetActiveIngredientsCubit>()
                      .getActiveIngredients();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmation(
                    context, "Delete ${activeIngredient.name}?", () {
                  context
                      .read<MedicineActionsCubit>()
                      .deleteActiveIngredient(activeIngredient.id!);
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
                BlocProvider(
                  create: (context) =>
                      sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
                ),
              ],
              child: MedicineBottomSheet(
                activeIngredient: activeIngredient,
                isDetails: true,
                initialType: MedicineFormType.activeIngredient,
              ),
            ),
          );
        },
      ),
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
  final CommercialName medicine;
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
          "${medicine.concentration != null ? '${medicine.concentration} - ' : ''}${medicine.parentId?.name ?? 'No Ingredient'}",
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
                      BlocProvider(
                        create: (context) =>
                            sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
                      ),
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
                _showDeleteConfirmation(context, "Delete ${medicine.name}?",
                    () {
                  context
                      .read<MedicineActionsCubit>()
                      .deleteMedicine(medicine.id!);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    context
                        .read<GetMedicinesCubit>()
                        .getMedicines(isRefresh: true);
                  });
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
                BlocProvider(
                  create: (context) =>
                      sl<GetClinicsCubit>()..add(GetAllClinicsEvent()),
                ),
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

void _showDeleteConfirmation(
    BuildContext context, String title, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xff1f1f1f) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: appStyle(context, 18,
                      isDark ? Colors.white : Colors.black, FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this item? This action cannot be undone.",
          style: appStyle(context, 14, isDark ? Colors.grey : Colors.black87,
              FontWeight.normal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
