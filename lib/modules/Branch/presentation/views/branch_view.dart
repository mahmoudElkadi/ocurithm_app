import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Branch/presentation/views/widgets/add_branch.dart';
import 'package:ocurithm/modules/Branch/presentation/views/widgets/branch_view_body.dart';

import '../../../../../core/utils/colors.dart';
import '../../data/repos/branch_repo_impl.dart';
import '../manager/branch_cubit.dart';
import '../manager/branch_state.dart';

class AdminBranchView extends StatelessWidget {
  const AdminBranchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBranchCubit(BranchRepoImpl())..getBranches(),
      child: BlocBuilder<AdminBranchCubit, AdminBranchState>(
        builder: (context, state) => CustomScaffold(
          title: "Branches",
          actions: [
            if (CacheHelper.getStringList(key: "capabilities").contains("manageBranches"))
              IconButton(
                onPressed: () {
                  showFormPopup(context, AdminBranchCubit.get(context));
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
                  AdminBranchCubit.get(context).page = 1;
                  AdminBranchCubit.get(context).searchController.clear();
                  await AdminBranchCubit.get(context).getBranches();
                } catch (e) {
                  log(e.toString());
                }
              },
              indicatorBuilder: (BuildContext context, IndicatorController controller) {
                return Image(image: AssetImage("assets/icons/logo.png"));
              },
              child: Scrollbar(
                child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: AdminBranchCubit.get(context).connection != false
                        ? BranchViewBody()
                        : NoInternet(
                            onPressed: () {
                              AdminBranchCubit.get(context).getBranches();
                            },
                          )),
              )),
        ),
      ),
    );
  }
}
