import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/Reception%20Dashboard/presentation/views/widgets/receptionist_view_body.dart';

import '../../../../../../../../core/utils/colors.dart';
import '../../../../../data/repos/receptionist_details_repo_impl.dart';
import '../../../../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../../../../manger/Receptionist Details Cubit/receptionist_details_state.dart';
import '../../../Add Receptionist/presentation/view/add_receptionist_view.dart';

class ReceptionistView extends StatelessWidget {
  const ReceptionistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReceptionistCubit(ReceptionistRepoImpl())..getReceptionists(),
      child: BlocBuilder<ReceptionistCubit, ReceptionistState>(
        builder: (BuildContext context, ReceptionistState state) => CustomScaffold(
          title: "Receptionists",
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => CreateReceptionistView(
                      cubit: ReceptionistCubit.get(context),
                    ));
              },
              icon: SvgPicture.asset(
                "assets/icons/add_user.svg",
                color: Colorz.primaryColor,
              ),
            ),
          ],
          body: ReceptionistCubit.get(context).connection != false
              ? const ReceptionistViewBody()
              : NoInternet(
                  onPressed: () {
                    log("message");
                    ReceptionistCubit.get(context).getReceptionists();
                  },
                ),
        ),
      ),
    );
  }
}
