import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Clinics/presentation/views/widgets/clinic_form_dialog.dart';
import 'package:ocurithm/modules/Clinics/presentation/views/widgets/clinic_view_body.dart';

import '../../../../core/utils/services_locator.dart';
import '../../data/repos/clinic_repo_impl.dart';
import '../manager/clinic_actions_cubit/clinic_actions_cubit.dart';
import '../manager/get_clinics_cubit/get_clinics_cubit.dart';

class ClinicView extends StatelessWidget {
  const ClinicView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                sl<GetClinicsCubit>()..add(GetAllClinicsEvent())),
        BlocProvider(create: (context) => sl<ClinicActionsCubit>()),
      ],
      child: BlocListener<ClinicActionsCubit, ClinicActionsState>(
        listener: (context, state) {
          if (state.isAddSuccess && state.clinic != null) {
            context
                .read<GetClinicsCubit>()
                .add(AddClinicToListEvent(state.clinic!));
          } else if (state.isUpdateSuccess && state.clinic != null) {
            context
                .read<GetClinicsCubit>()
                .add(UpdateClinicInListEvent(state.clinic!));
          }
        },
        child: BlocBuilder<GetClinicsCubit, GetClinicsState>(
          builder: (context, state) => CustomScaffold(
              title: "Clinics",
              actions: [
                IconButton(
                  onPressed: () {
                    context
                        .read<ClinicActionsCubit>()
                        .add(ResetClinicActionsEvent());
                    // Show add clinic dialog
                    showClinicFormDialog(
                      context,
                      mode: ClinicFormMode.add,
                      actionsCubit: context.read<ClinicActionsCubit>(),
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
                    try {
                      context.read<GetClinicsCubit>().add(SetPageEvent(1));
                      context.read<GetClinicsCubit>().add(SetSearchEvent(''));
                      context.read<GetClinicsCubit>().add(GetAllClinicsEvent());
                    } catch (e) {
                      log(e.toString());
                    }
                  },
                  indicatorBuilder:
                      (BuildContext context, IndicatorController controller) {
                    return const Image(
                        image: AssetImage("assets/icons/logo.png"));
                  },
                  child: const ClinicViewBody())),
        ),
      ),
    );
  }
}
