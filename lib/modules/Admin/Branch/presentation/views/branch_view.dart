import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Admin/Branch/presentation/views/widgets/branch_view_body.dart';

import '../../../../../core/utils/colors.dart';
import '../manager/branch_cubit.dart';

class AdminBranchView extends StatelessWidget {
  const AdminBranchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBranchCubit(),
      child: CustomScaffold(
        title: "Branch",
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/add_branch.svg",
              color: Colorz.primaryColor,
            ),
          ),
        ],
        body: const BranchViewBody(),
      ),
    );
  }
}
