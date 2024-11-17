import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/presentation/views/widgets/make_appointment_view_body.dart';

import '../../../../../core/utils/app_style.dart';
import '../../../../../core/utils/colors.dart';
import '../../../data/repos/make_appointment_repo_impl.dart';
import '../../manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../../manager/Make Appointment cubit/make_appointment_state.dart';

class UpdateAppointment extends StatelessWidget {
  const UpdateAppointment({super.key, required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MakeAppointmentCubit(MakeAppointmentRepoImpl())..setData(appointment),
      child: BlocBuilder<MakeAppointmentCubit, MakeAppointmentState>(
        builder: (BuildContext context, state) => Scaffold(
          backgroundColor: Colorz.white,
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
          ),
          body: MakeAppointmentViewBody(isUpdate: true),
        ),
      ),
    );
  }
}
