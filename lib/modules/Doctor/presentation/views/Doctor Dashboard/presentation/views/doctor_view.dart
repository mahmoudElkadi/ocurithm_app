import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Doctor/presentation/views/Doctor%20Dashboard/presentation/views/widgets/doctor_view_body.dart';

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
              if (CacheHelper.getStringList(key: "capabilities")
                  .contains("manageDoctors"))
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
            body: CustomMaterialIndicator(
              onRefresh: () async {
                try {
                  final cubit = context.read<GetDoctorsCubit>();
                  cubit.add(ResetDoctorFilters());
                  cubit.onSearchChanged('');
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
                child: DoctorViewBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
