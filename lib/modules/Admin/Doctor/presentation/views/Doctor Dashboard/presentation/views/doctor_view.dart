import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Admin/Doctor/data/repos/doctor_repo_impl.dart';
import 'package:ocurithm/modules/Admin/Doctor/presentation/views/Doctor%20Dashboard/presentation/views/widgets/doctor_view_body.dart';

import '../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../core/widgets/no_internet.dart';
import '../../../../manager/doctor_cubit.dart';
import '../../../../manager/doctor_state.dart';
import '../../../Add Doctor/presentation/view/add_doctor_view.dart';

class AdminDoctorView extends StatelessWidget {
  const AdminDoctorView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: BlocProvider(
        create: (context) => DoctorCubit(DoctorRepoImpl())..getDoctors(),
        child: BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, state) => CustomScaffold(
            title: "Doctors",
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(() => CreateDoctorView(
                        cubit: DoctorCubit.get(context),
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
                    DoctorCubit.get(context).page = 1;
                    DoctorCubit.get(context).searchController.clear();
                    await DoctorCubit.get(context).getDoctors();
                  } catch (e) {
                    log(e.toString());
                  }
                },
                indicatorBuilder: (BuildContext context, IndicatorController controller) {
                  return const Image(image: AssetImage("assets/icons/logo.png"));
                },
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: DoctorCubit.get(context).connection != false
                        ? const DoctorViewBody()
                        : NoInternet(
                            onPressed: () {
                              DoctorCubit.get(context).getDoctors();
                            },
                          ))),
          ),
        ),
      ),
    );
  }
}
