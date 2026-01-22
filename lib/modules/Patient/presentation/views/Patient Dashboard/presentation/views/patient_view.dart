import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Patient/presentation/views/Patient%20Dashboard/presentation/views/widgets/patient_view_body.dart';

import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/widgets/no_internet.dart';
import '../../../../../../../core/Network/shared.dart';
import '../../../../../../../core/utils/services_locator.dart';
import '../../../../manager/get_patients_cubit/get_patients_cubit.dart';
import '../../../../manager/patient_actions_cubit/patient_actions_cubit.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import '../../../patient_form/patient_form_page.dart';

class AdminPatientView extends StatelessWidget {
  const AdminPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  sl<GetPatientsCubit>()..add(GetAllPatientsEvent())),
          BlocProvider(create: (context) => sl<PatientActionsCubit>()),
        ],
        child: BlocListener<PatientActionsCubit, PatientActionsState>(
          listener: (context, state) {
            if (state.isLoading) {
              customLoading(context, "");
            } else if (state.isSuccess) {
              // Pop loading if open
              Navigator.pop(context);

              if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: Colors.green));
              }
              // Refresh list
              context.read<GetPatientsCubit>().add(GetAllPatientsEvent());
            } else if (state.isError || state.noConnection) {
              // Pop loading if open
              if (state.state != PatientActionsStatus.initial) {
                Navigator.pop(context);
              }

              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red));
              }
            }
          },
          child: BlocBuilder<GetPatientsCubit, GetPatientsState>(
            builder: (context, state) => CustomScaffold(
              title: "Patients",
              actions: [
                if (CacheHelper.getStringList(key: "capabilities")
                    .contains("managePatients"))
                  IconButton(
                    onPressed: () async {
                      final result = await Get.to(() =>
                          const PatientFormPage(mode: PatientFormMode.add));
                      if (result == true) {
                        context
                            .read<GetPatientsCubit>()
                            .add(GetAllPatientsEvent());
                      }
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/add_user.svg",
                      color: Colorz.primaryColor,
                    ),
                  ),
              ],
              body: CustomMaterialIndicator(
                  onRefresh: () async {
                    context.read<GetPatientsCubit>().add(ResetPatientFilters());
                    // Reset filters triggers get all
                  },
                  indicatorBuilder:
                      (BuildContext context, IndicatorController controller) {
                    return const Image(
                        image: AssetImage("assets/icons/logo.png"));
                  },
                  child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: !state.noConnection
                          ? const PatientViewBody()
                          : NoInternet(
                              onPressed: () {
                                context
                                    .read<GetPatientsCubit>()
                                    .add(GetAllPatientsEvent());
                              },
                            ))),
            ),
          ),
        ),
      ),
    );
  }
}
