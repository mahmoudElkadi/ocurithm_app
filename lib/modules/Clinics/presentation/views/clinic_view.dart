import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Clinics/presentation/views/widgets/add_clinic_method.dart';
import 'package:ocurithm/modules/Clinics/presentation/views/widgets/clinic_view_body.dart';

import '../../../../../core/utils/colors.dart';
import '../../data/repos/clinic_repo_impl.dart';
import '../manager/clinic_cubit.dart';
import '../manager/clinic_state.dart';

class ClinicView extends StatelessWidget {
  const ClinicView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClinicCubit(ClinicRepoImpl())..getClinics(),
      child: BlocBuilder<ClinicCubit, ClinicState>(
        builder: (context, state) => CustomScaffold(
          title: "Clinics",
          actions: [
            IconButton(
              onPressed: () {
                showFormPopup(context, ClinicCubit.get(context));
              },
              icon: SvgPicture.asset(
                "assets/icons/add_branch.svg",
                color: Colorz.primaryColor,
              ),
            ),
          ],
          body: CustomMaterialIndicator(
              onRefresh: () async {
                try {
                  ClinicCubit.get(context).page = 1;
                  ClinicCubit.get(context).searchController.clear();
                  await ClinicCubit.get(context).getClinics();
                } catch (e) {
                  log(e.toString());
                }
              },
              indicatorBuilder: (BuildContext context, IndicatorController controller) {
                return Image(image: AssetImage("assets/icons/logo.png"));
              },
              child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ClinicCubit.get(context).connection != false
                      ? ClinicViewBody()
                      : NoInternet(
                          onPressed: () {
                            ClinicCubit.get(context).getClinics();
                          },
                        ))),
        ),
      ),
    );
  }
}
