import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';

import '../manager/get_save_reasons_cubit/get_save_reasons_cubit.dart';
import '../manager/save_reason_actions_cubit/save_reason_actions_cubit.dart';
import 'widgets/save_reason_form_dialog.dart';
import 'widgets/save_reason_view_body.dart';

/// Configuration screen for the save-reason catalog: the list a doctor picks from
/// when parking a visit.
class SaveReasonView extends StatelessWidget {
  const SaveReasonView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<GetSaveReasonsCubit>()..add(const GetAllSaveReasonsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<SaveReasonActionsCubit>(),
        ),
      ],
      child: BlocListener<SaveReasonActionsCubit, SaveReasonActionsState>(
        listener: (context, state) {
          if (state.isError) {
            SnackbarService.showError(
              context,
              message: state.errorMessage ?? 'An error occurred',
            );
          }

          if (state.noConnection) {
            SnackbarService.showWarning(
              context,
              message: state.errorMessage ?? 'No internet connection',
            );
          }

          if (state.isSuccess) {
            SnackbarService.showSuccess(
              context,
              message: state.successMessage ?? 'Operation successful',
            );

            context
                .read<GetSaveReasonsCubit>()
                .add(const GetAllSaveReasonsEvent());
          }
        },
        child: Builder(
          builder: (context) {
            return CustomScaffold(
              title: "Save Reasons",
              actions: [
                IconButton(
                  onPressed: () {
                    showSaveReasonFormDialog(
                      context,
                      mode: SaveReasonFormMode.add,
                      actionsCubit: context.read<SaveReasonActionsCubit>(),
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/add_branch.svg",
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
              body: CustomMaterialIndicator(
                onRefresh: () async {
                  context
                      .read<GetSaveReasonsCubit>()
                      .add(const GetAllSaveReasonsEvent());
                },
                indicatorBuilder:
                    (BuildContext context, IndicatorController controller) {
                  return const Image(image: AssetImage("assets/icons/logo.png"));
                },
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SaveReasonViewBody(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
