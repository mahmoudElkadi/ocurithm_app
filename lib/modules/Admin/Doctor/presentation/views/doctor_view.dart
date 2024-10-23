import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Admin/Doctor/presentation/views/widgets/doctor_view_body.dart';

import '../../../../../core/utils/colors.dart';
import '../manager/doctor_cubit.dart';

class AdminDoctorView extends StatelessWidget {
  const AdminDoctorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDoctorCubit(),
      child: CustomScaffold(
        title: "Doctor",
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/add_user.svg",
              color: Colorz.primaryColor,
            ),
          ),
        ],
        body: const DoctorViewBody(),
      ),
    );
  }
}
