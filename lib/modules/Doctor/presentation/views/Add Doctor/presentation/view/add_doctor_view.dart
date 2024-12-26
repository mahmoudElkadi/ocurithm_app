import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Doctor/presentation/views/Add%20Doctor/presentation/view/widgets/add_doctor_view_body.dart';

import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../core/widgets/no_internet.dart';
import '../../../../manager/doctor_cubit.dart';
import '../../../../manager/doctor_state.dart';

class CreateDoctorView extends StatefulWidget {
  const CreateDoctorView({super.key, this.nationalId, this.readOnly, required this.cubit});
  final String? nationalId;
  final bool? readOnly;
  final DoctorCubit cubit;

  @override
  State<CreateDoctorView> createState() => _CreateDoctorViewState();
}

class _CreateDoctorViewState extends State<CreateDoctorView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _handleSave(BuildContext context) async {
    widget.cubit.validateFirstPage();

    if (formKey.currentState!.validate() && widget.cubit.isValidate) {
      customLoading(context, "");

      try {
        bool connection = await InternetConnection().hasInternetAccess;

        if (!connection) {
          Navigator.of(context).pop();
          Get.snackbar(
            "Error",
            "No Internet Connection",
            backgroundColor: Colorz.errorColor,
            colorText: Colorz.white,
            icon: Icon(Icons.error, color: Colorz.white),
          );
          return;
        }

        await widget.cubit.addDoctor(context: context);
      } catch (e) {
        log("Error saving: $e");
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorCubit, DoctorState>(
      bloc: widget.cubit,
      builder: (context, state) => GestureDetector(
        onTap: () {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: WillPopScope(
          onWillPop: () async {
            widget.cubit.clearData();
            return true;
          },
          child: Scaffold(
            backgroundColor: Colorz.white,
            appBar: AppBar(
              backgroundColor: Colorz.white,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colorz.black),
                onPressed: () {
                  widget.cubit.clearData();
                  Get.back();
                },
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
                    onPressed: () {
                      _handleSave(context);
                    },
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: widget.cubit.connection != false
                  ? CreateDoctorViewBody(
                      cubit: widget.cubit,
                      formKey: formKey,
                    )
                  : NoInternet(
                      onPressed: () {
                        widget.cubit.getBranches();
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
