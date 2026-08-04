import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Doctor/presentation/views/Doctor%20Dashboard/presentation/views/widgets/doctor_view_body.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';

import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/utils/services_locator.dart';
import '../../../../manager/get_doctors_cubit/get_doctors_cubit.dart';
import '../../../../manager/doctor_actions_cubit/doctor_actions_cubit.dart';
import '../../../doctor_form/doctor_form_page.dart';

class AdminDoctorView extends StatelessWidget {
  const AdminDoctorView({super.key});

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
                sl<GetDoctorsCubit>()..add(GetAllDoctorsEvent()),
          ),
          BlocProvider(
            create: (context) => sl<DoctorActionsCubit>(),
          ),
        ],
        child: BlocBuilder<GetDoctorsCubit, GetDoctorsState>(
          builder: (context, state) => CustomScaffold(
            title: "Doctors",
            actions: [
              if (CapabilityServices.hasCapability(
                  CapabilityKeys.manageDoctors))
                IconButton(
                  onPressed: () async {
                    final result = await Get.to(() => const DoctorFormPage(
                          mode: DoctorFormMode.add,
                        ));
                    // Refresh list if doctor was added
                    if (result == true && context.mounted) {
                      context.read<GetDoctorsCubit>().add(GetAllDoctorsEvent());
                    }
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/add_user.svg",
                    color: Colorz.primaryColor,
                  ),
                ),
            ],
            body: MultiBlocListener(
              listeners: [
                BlocListener<DoctorActionsCubit, DoctorActionsState>(
                  listener: (context, actionState) {
                    if (actionState.isSuccess || actionState.isError || actionState.noConnection) {
                      // We only pop if we showed a loading dialog. 
                      // For deletion, we show it in the card.
                      if (actionState.actionType == DoctorActionType.delete || 
                          actionState.actionType == DoctorActionType.update ||
                          actionState.actionType == DoctorActionType.add) {
                        
                        // Check if a dialog is actually open might be tricky, 
                        // but usually we pop when success/error/noConnection occurs after a loading state.
                        if (actionState.actionType == DoctorActionType.delete && 
                           (actionState.isSuccess || actionState.isError || actionState.noConnection)) {
                           Navigator.of(context, rootNavigator: true).pop();
                        }
                      }

                      if (actionState.isSuccess) {
                        SnackbarService.showSuccess(
                          context,
                          message: actionState.successMessage ?? 'Operation completed successfully',
                        );
                        context.read<GetDoctorsCubit>().add(GetAllDoctorsEvent());
                      } else if (actionState.isError) {
                        SnackbarService.showError(
                          context,
                          message: actionState.errorMessage ?? 'An error occurred',
                        );
                      } else if (actionState.noConnection) {
                        SnackbarService.showWarning(
                          context,
                          message: actionState.errorMessage ?? 'No internet connection',
                        );
                      }
                    }
                  },
                ),
              ],
              child: CustomMaterialIndicator(
                onRefresh: () async {
                  try {
                    context.read<GetDoctorsCubit>().add(ResetDoctorFilters());
                  } catch (e) {
                    log(e.toString());
                  }
                },
                indicatorBuilder:
                    (BuildContext context, IndicatorController controller) {
                  return const Image(image: AssetImage("assets/icons/logo.png"));
                },
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: const DoctorViewBody(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
