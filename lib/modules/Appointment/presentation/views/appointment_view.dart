import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Appointment/presentation/views/widgets/appointment_view_body.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/views/make_appointment_view.dart';

import '../../../../core/utils/colors.dart';
import '../../data/repos/appointment_repo_impl.dart';
import '../manager/Appointment cubit/appointment_cubit.dart';
import '../manager/Appointment cubit/appointment_state.dart';

class AppointmentView extends StatelessWidget {
  const AppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppointmentCubit(AppointmentRepoImpl())
          ..getAppointments()
          ..getDoctors()
          ..getBranches(),
        child: BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) => CustomScaffold(
                body: AppointmentCubit.get(context).connection != false
                    ? const AppointmentViewBody()
                    : NoInternet(
                        onPressed: () {
                          if (AppointmentCubit.get(context).doctors == null) {
                            AppointmentCubit.get(context).getDoctors();
                            AppointmentCubit.get(context).getBranches();
                          }
                        },
                      ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.to(() => MakeAppointmentView());
                    },
                    icon: Icon(Icons.add, color: Colorz.primaryColor),
                  )
                ],
                title: "Appointments")));
  }
}
