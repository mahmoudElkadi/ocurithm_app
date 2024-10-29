import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Admin/Patient/data/repos/Patient_repo_impl.dart';
import 'package:ocurithm/modules/Admin/Patient/presentation/views/Patient%20Dashboard/presentation/views/widgets/patient_view_body.dart';

import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/widgets/no_internet.dart';
import '../../../../manager/patient_cubit.dart';
import '../../../../manager/patient_state.dart';
import '../../../Add Patient/presentation/view/add_patient_view.dart';

class AdminPatientView extends StatelessWidget {
  const AdminPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: BlocProvider(
        create: (context) => PatientCubit(PatientRepoImpl())..getPatients(),
        child: BlocBuilder<PatientCubit, PatientState>(
          builder: (context, state) => CustomScaffold(
            title: "Patients",
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(() => CreatePatientView(
                        cubit: PatientCubit.get(context),
                      ));
                },
                icon: SvgPicture.asset(
                  "assets/icons/add_user.svg",
                  color: Colorz.primaryColor,
                ),
              ),
            ],
            body: CustomMaterialIndicator(
                onRefresh: () async {
                  try {
                    PatientCubit.get(context).page = 1;
                    PatientCubit.get(context).searchController.clear();
                    await PatientCubit.get(context).getPatients();
                  } catch (e) {
                    log(e.toString());
                  }
                },
                indicatorBuilder: (BuildContext context, IndicatorController controller) {
                  return const Image(image: AssetImage("assets/icons/logo.png"));
                },
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: PatientCubit.get(context).connection != false
                        ? const PatientViewBody()
                        : NoInternet(
                            onPressed: () {
                              PatientCubit.get(context).getPatients();
                            },
                          ))),
          ),
        ),
      ),
    );
  }
}
