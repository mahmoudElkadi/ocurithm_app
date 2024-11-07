import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/views/widgets/appointment_form.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/views/widgets/make_appointment_view_body.dart';

import '../../../../core/utils/app_style.dart';
import '../../../../core/utils/colors.dart';
import '../../data/repos/make_appointment_repo_impl.dart';
import '../manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../manager/Make Appointment cubit/make_appointment_state.dart';

class MakeAppointmentView extends StatelessWidget {
  const MakeAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MakeAppointmentCubit(MakeAppointmentRepoImpl()),
        child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
            builder: (context, state) => Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colorz.white,
                    elevation: 0,
                    title: Text("Appointments", style: appStyle(context, 20, Colorz.black, FontWeight.w600)),
                    centerTitle: true,
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(Icons.arrow_back, color: Colorz.black),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {
                            showAppointmentBottomSheet(context);
                          },
                          icon: Icon(Icons.calendar_month, color: Colorz.black)),
                    ],
                  ),
                  body: MakeAppointmentCubit.get(context).connection != false
                      ? MakeAppointmentViewBody(
                          branch: '',
                        )
                      : NoInternet(
                          onPressed: () {
                            if (MakeAppointmentCubit.get(context).doctors == null) {
                              MakeAppointmentCubit.get(context).getDoctors();
                              MakeAppointmentCubit.get(context).getBranches();
                            }
                          },
                        ),
                )));
  }
}
