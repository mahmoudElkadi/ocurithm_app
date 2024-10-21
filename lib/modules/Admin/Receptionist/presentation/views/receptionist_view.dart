import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Admin/Receptionist/presentation/views/widgets/receptionist_view_body.dart';

import '../../../../../core/utils/colors.dart';
import '../manager/receptionist_cubit.dart';

class ReceptionistView extends StatelessWidget {
  const ReceptionistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminReceptionCubit(),
      child: CustomScaffold(
        title: "Receptionist",
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/add_user.svg",
              color: Colorz.primaryColor,
            ),
          ),
        ],
        body: const ReceptionistViewBody(),
      ),
    );
  }
}
