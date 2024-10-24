import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Admin/Doctor/Add%20Doctor/presentation/view/widgets/add_Doctor_view_body.dart';

import '../../data/repos/add_doctor_repo_impl.dart';
import '../manger/Add Doctor Cubit/add_doctor_cubit.dart';

class CreateDoctorView extends StatelessWidget {
  const CreateDoctorView({super.key, this.nationalId, this.readOnly});
  final String? nationalId;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateDoctorCubit(CreateDoctorRepoImpl()),
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
              "Add Doctor",
              style: appStyle(context, 20, Colorz.black, FontWeight.w600),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                  icon: Icon(
                    Icons.check,
                    color: Colorz.primaryColor,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
              child: CreateDoctorViewBody(
            readOnly: readOnly,
            nationalId: nationalId,
          )),
        ),
      ),
    );
  }
}
