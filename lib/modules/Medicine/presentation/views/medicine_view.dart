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
import '../../../../core/widgets/no_internet.dart';
import '../../../../core/widgets/pagination.dart';

class MedicineView extends StatelessWidget {
  const MedicineView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => sl<GetMedicinesCubit>()..getMedicines()),
        BlocProvider(create: (context) => sl<GetActiveIngredientsCubit>()),
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
                  );
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

    if (isMedicines) {
      final state = context.read<GetMedicinesCubit>().state;
      if (state.status == GetMedicinesStatus.initial ||
          state.status == GetMedicinesStatus.error) {
        context.read<GetMedicinesCubit>().getMedicines();
      }
    } else {
      final state = context.read<GetActiveIngredientsCubit>().state;
      if (state.status == GetActiveIngredientsStatus.initial ||
          state.status == GetActiveIngredientsStatus.error) {
        context.read<GetActiveIngredientsCubit>().getActiveIngredients();
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isNoConnection = false;
    if (_isMedicines) {
      isNoConnection = context.watch<GetMedicinesCubit>().state.status ==
          GetMedicinesStatus.noConnection;
    } else {
      isNoConnection =
          context.watch<GetActiveIngredientsCubit>().state.status ==
              GetActiveIngredientsStatus.noConnection;
    }

    return Column(
      children: [
        if (!isNoConnection) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                color:
                                    _isMedicines ? Colors.white : Colors.grey,
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
                                color:
                                    !_isMedicines ? Colors.white : Colors.grey,
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
        ],
        Expanded(
          child: BlocListener<MedicineActionsCubit, MedicineActionsState>(
            listener: (context, state) {
              if (state.status == MedicineActionsStatus.success) {
                context.read<GetMedicinesCubit>().getMedicines(isRefresh: true);
                context
                    .read<GetActiveIngredientsCubit>()
                    .getActiveIngredients();
              }
            },
            child: RefreshIndicator(
              onRefresh: () async {
                if (_isMedicines) {
                  context
                      .read<GetMedicinesCubit>()
                      .getMedicines(isRefresh: true);
                } else {
                  context
                      .read<GetActiveIngredientsCubit>()
                      .getActiveIngredients();
                }
                return;
              },
              child: _isMedicines
                  ? const _MedicinesList()
                  : const _ActiveIngredientsList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return SearchField(
      onTextFieldChanged: () async {
        if (_isMedicines) {
          context.read<GetMedicinesCubit>().getMedicines(
                search: searchController.text,
                isRefresh: true,
              );
        } else {
          context.read<GetActiveIngredientsCubit>().getActiveIngredients(
                search: searchController.text,
                page: 1,
              );
        }
      },
      searchController: searchController,
      onClose: () {
        searchController.clear();
        if (_isMedicines) {
          context.read<GetMedicinesCubit>().getMedicines(isRefresh: true);
        } else {
          context
              .read<GetActiveIngredientsCubit>()
              .getActiveIngredients(page: 1);
        }
      },
    );
  }
}

class _ActiveIngredientsList extends StatelessWidget {
  const _ActiveIngredientsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetActiveIngredientsCubit, GetActiveIngredientsState>(
      builder: (context, state) {
        if (state.status == GetActiveIngredientsStatus.loading) {
          return const _MedicineShimmerLoading();
        } else if (state.status == GetActiveIngredientsStatus.noConnection) {
          return NoInternet(
            fromTop: 20,
            onPressed: () {
              context.read<GetActiveIngredientsCubit>().getActiveIngredients();
            },
          );
        } else if (state.status == GetActiveIngredientsStatus.error) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? "An error occurred",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<GetActiveIngredientsCubit>()
                                .getActiveIngredients(page: 1);
                          },
                          child: const Text("Retry"),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Or pull down to refresh",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else if (state.status == GetActiveIngredientsStatus.success) {
          if (state.activeIngredients.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child:
                      const Center(child: Text("No Active Ingredients Found")),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                state.activeIngredients.length + (state.totalPages > 1 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.activeIngredients.length) {
                final activeIngredient = state.activeIngredients[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child:
                      _ActiveIngredientCard(activeIngredient: activeIngredient),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CustomPagination(
                    currentPage: state.page,
                    totalPages: state.totalPages,
                    onPageChanged: (page) {
                      context
                          .read<GetActiveIngredientsCubit>()
                          .getActiveIngredients(page: page);
                    },
                  ),
                );
              }
            },
          );
        }
        return const SizedBox();
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
                      BlocProvider.value(
                          value: context.read<GetMedicinesCubit>()),
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
                );
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
                BlocProvider.value(value: context.read<GetMedicinesCubit>()),
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
        if (state.status == GetMedicinesStatus.loading) {
          return const _MedicineShimmerLoading();
        } else if (state.status == GetMedicinesStatus.noConnection) {
          return NoInternet(
            fromTop: 20,
            onPressed: () {
              context.read<GetMedicinesCubit>().getMedicines(isRefresh: true);
            },
          );
        } else if (state.status == GetMedicinesStatus.error) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? "An error occurred",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<GetMedicinesCubit>()
                                .getMedicines(isRefresh: true);
                          },
                          child: const Text("Retry"),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Or pull down to refresh",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else if (state.status == GetMedicinesStatus.success) {
          if (state.medicines.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: Text("No Medicines Found")),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.medicines.length + (state.totalPages > 1 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.medicines.length) {
                final medicine = state.medicines[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MedicineCard(medicine: medicine),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CustomPagination(
                    currentPage: state.page,
                    totalPages: state.totalPages,
                    onPageChanged: (page) {
                      context
                          .read<GetMedicinesCubit>()
                          .getMedicines(page: page);
                    },
                  ),
                );
              }
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
                      BlocProvider.value(
                          value: context.read<GetMedicinesCubit>()),
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
                );
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
                BlocProvider.value(value: context.read<GetMedicinesCubit>()),
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
