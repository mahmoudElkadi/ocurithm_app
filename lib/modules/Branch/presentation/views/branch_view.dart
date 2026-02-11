import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/branch_actions_cubit/branch_actions_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import 'package:ocurithm/modules/Branch/presentation/views/widgets/branch_form_dialog.dart';
import 'package:ocurithm/modules/Branch/presentation/views/widgets/branch_view_body.dart';
import 'package:ocurithm/core/utils/auth_service.dart';

class AdminBranchView extends StatelessWidget {
  const AdminBranchView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GetBranchesCubit>()
            ..add(SetClinicFilterEvent(AuthService.getEffectiveClinic()?.id)),
        ),
        BlocProvider(
          create: (_) => sl<BranchActionsCubit>(),
        ),
      ],
      child: BlocBuilder<GetBranchesCubit, GetBranchesState>(
        builder: (context, state) => CustomScaffold(
          title: "Branches",
          actions: [
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("manageBranches"))
              IconButton(
                onPressed: () {
                  final actionsCubit = context.read<BranchActionsCubit>();

                  showBranchFormDialog(
                    context,
                    mode: BranchFormMode.add,
                    actionsCubit: actionsCubit,
                    clinics: null, // Clinics will be loaded in the form dialog
                  );
                },
                icon: SvgPicture.asset(
                  "assets/icons/add_branch.svg",
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ],
          body: MultiBlocListener(
            listeners: [
              // Listen to action results and refresh list
              BlocListener<BranchActionsCubit, BranchActionsState>(
                listener: (context, actionState) {
                  if (actionState.isAddSuccess ||
                      actionState.isUpdateSuccess ||
                      actionState.isDeleteSuccess) {
                    if (actionState.isDeleteSuccess) {
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // Close loading dialog
                      SnackbarService.showSuccess(
                        context,
                        message: actionState.successMessage ??
                            'Branch deleted successfully',
                      );
                    }

                    // Refresh the branches list
                    context
                        .read<GetBranchesCubit>()
                        .add(SetClinicFilterEvent(AuthService.getEffectiveClinic()?.id));
                  } else if (actionState.isDeleteError) {
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Close loading dialog
                    SnackbarService.showError(
                      context,
                      message:
                          actionState.errorMessage ?? 'Failed to delete branch',
                    );
                  }
                },
              ),
            ],
            child: CustomMaterialIndicator(
              onRefresh: () async {
                try {
                  if (AuthService.isAdmin) {
                    context.read<GetBranchesCubit>().add(ResetBranchFilters());
                  } else {
                    context.read<GetBranchesCubit>().add(SetClinicFilterEvent(
                        AuthService.getEffectiveClinic()?.id));
                  }
                } catch (e) {
                  log(e.toString());
                }
              },
              indicatorBuilder:
                  (BuildContext context, IndicatorController controller) {
                return const Image(image: AssetImage("assets/icons/logo.png"));
              },
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: state.noConnection
                      ? NoInternet(
                          onPressed: () {
                            context
                                .read<GetBranchesCubit>()
                                .add(SetClinicFilterEvent(AuthService.getEffectiveClinic()?.id));
                          },
                        )
                      : const BranchViewBody(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
