import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Appointment/presentation/views/widgets/appointment_view_body.dart';
import 'package:ocurithm/modules/Make_Appointment/presentation/views/make_appointment_view.dart';

import '../../../../core/utils/colors.dart';
import '../manager/Appointment cubit/appointment_cubit.dart';

class AppointmentView extends StatelessWidget {
  const AppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        final cubit = context.read<AppointmentCubit>();

        return CustomScaffold(
          body: !state.noConnection
              ? const AppointmentViewBody()
              : NoInternet(
                  onPressed: () {
                    if (state.doctors == null) {
                      cubit.add(GetAppointmentsEvent());
                    }
                  },
                ),
          actions: [
            manageCapability(
              capability: 'addAppointments',
              child: IconButton(
                onPressed: () async {
                  DateTime? isChanged =
                      await Get.to(() => const MakeAppointmentView());
                  if (isChanged != null) {
                    cubit.add(SelectDateEvent(isChanged));
                  }
                },
                icon: Icon(Icons.add, color: Colorz.primaryColor),
              ),
            )
          ],
          title: "Appointments",
        );
      },
    );
  }
}
