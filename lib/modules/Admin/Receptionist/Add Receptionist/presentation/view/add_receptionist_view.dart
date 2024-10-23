import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Admin/Receptionist/Add%20Receptionist/presentation/view/widgets/add_receptionist_view_body.dart';

import '../../../../../../generated/l10n.dart';
import '../../data/repos/add_receptionist_repo_impl.dart';
import '../manger/Add Receptionist Cubit/add_receptionist_cubit.dart';

class CreateReceptionistView extends StatelessWidget {
  const CreateReceptionistView({super.key, this.nationalId, this.readOnly});
  final String? nationalId;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateReceptionistCubit(CreateReceptionistRepoImpl()),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colorz.white,
          appBar: AppBar(
            backgroundColor: Colorz.white,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colorz.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              S.of(context).createReceptionist,
              style: appStyle(context, 20, Colorz.black, FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
              child: CreateReceptionistViewBody(
            readOnly: readOnly,
            nationalId: nationalId,
          )),
        ),
      ),
    );
  }
}
