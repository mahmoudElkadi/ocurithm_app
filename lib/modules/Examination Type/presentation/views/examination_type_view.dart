import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';

import '../manager/examination_type_actions_cubit/examination_type_actions_cubit.dart';
import '../manager/get_examination_types_cubit/get_examination_types_cubit.dart';
import 'widgets/examination_type_form_dialog.dart';
import 'widgets/examination_type_view_body.dart';

/// Examination Types View - Displays list of examination types
/// Uses new cubits: GetExaminationTypesCubit and ExaminationTypeActionsCubit
class ExaminationTypeView extends StatelessWidget {
  const ExaminationTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GetExaminationTypesCubit>()
            ..add(const GetAllExaminationTypesEvent()),
        ),
        BlocProvider(
          create: (_) => sl<ExaminationTypeActionsCubit>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return CustomScaffold(
            title: "Examination Types",
            actions: [
              IconButton(
                onPressed: () {
                  showExaminationTypeFormDialog(
                    context,
                    mode: ExaminationTypeFormMode.add,
                    actionsCubit: context.read<ExaminationTypeActionsCubit>(),
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
                    .read<GetExaminationTypesCubit>()
                    .add(const GetAllExaminationTypesEvent());
              },
              indicatorBuilder:
                  (BuildContext context, IndicatorController controller) {
                return const Image(image: AssetImage("assets/icons/logo.png"));
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: ExaminationTypeViewBody(),
              ),
            ),
          );
        },
      ),
    );
  }
}
