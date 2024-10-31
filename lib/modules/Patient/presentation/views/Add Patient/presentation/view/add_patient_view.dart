import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../core/widgets/no_internet.dart';
import '../../../../manager/patient_cubit.dart';
import '../../../../manager/patient_state.dart';
import 'widgets/add_patient_view_body.dart';

class CreatePatientView extends StatefulWidget {
  const CreatePatientView({super.key, this.nationalId, this.readOnly, required this.cubit});
  final String? nationalId;
  final bool? readOnly;
  final PatientCubit cubit;

  @override
  State<CreatePatientView> createState() => _CreatePatientViewState();
}

class _CreatePatientViewState extends State<CreatePatientView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _handleSave(BuildContext context) async {
    widget.cubit.validateFirstPage();
    log("vv" + widget.cubit.isValidate.toString());
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

        await widget.cubit.addPatient(context: context);
      } catch (e) {
        log("Error saving: $e");
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCubit, PatientState>(
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
                "Add Patient",
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
                  ? CreatePatientViewBody(
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
