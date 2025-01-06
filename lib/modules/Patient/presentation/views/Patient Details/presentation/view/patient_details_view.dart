import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Patient/presentation/views/Patient%20Details/presentation/view/widgets/patient_details_view_body.dart';

import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../core/widgets/no_internet.dart';
import '../../../../../../../core/Network/shared.dart';
import '../../../../manager/patient_cubit.dart';
import '../../../../manager/patient_state.dart';

class PatientDetailsView extends StatefulWidget {
  const PatientDetailsView({super.key, required this.id, required this.cubit});
  final String id;

  final PatientCubit cubit;

  @override
  State<PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<PatientDetailsView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _handleSave(BuildContext context) async {
    if (!_mounted) return;

    if (formKey.currentState!.validate() && widget.cubit.validateFirstPage() == true) {
      customLoading(context, "");

      try {
        bool connection = await InternetConnection().hasInternetAccess;

        if (!_mounted) return;

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

        await widget.cubit.updatePatient(id: widget.id, context: context);
      } catch (e) {
        if (!_mounted) return;
        log("Error saving: $e");
        Navigator.of(context).pop();
      }
    }
  }

  void _handleEdit() {
    if (!_mounted) return;
    setState(() {
      widget.cubit.readOnly = !widget.cubit.readOnly;
    });
  }

  Future<bool> _handleWillPop() async {
    if (!_mounted) return true;
    widget.cubit.readOnly = true;
    widget.cubit.clearData();
    setState(() {});
    return true;
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
          onWillPop: _handleWillPop,
          child: Scaffold(
            backgroundColor: Colorz.white,
            appBar: AppBar(
              backgroundColor: Colorz.white,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colorz.black),
                onPressed: () {
                  Get.back();
                  widget.cubit.readOnly = true;
                  widget.cubit.clearData();
                  setState(() {});
                },
              ),
              title: Text(
                "Patient Details",
                style: appStyle(context, 20, Colorz.black, FontWeight.w600),
              ),
              centerTitle: true,
              actions: [
                widget.cubit.readOnly == true
                    ? IconButton(
                        onPressed: () async {
                          setState(() {
                            widget.cubit.readOnly = !widget.cubit.readOnly;
                          });
                          if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities")) {
                            if (widget.cubit.clinics == null) {
                              await widget.cubit.getClinics();
                            }
                            await widget.cubit.getBranches();
                          } else {
                            widget.cubit.getBranches();
                          }
                        },
                        icon: Icon(Icons.edit, color: Colorz.black),
                      )
                    : TextButton(
                        onPressed: () {
                          _handleSave(context);
                        },
                        child: Text(
                          "Done",
                          style: appStyle(context, 16, Colorz.primaryColor, FontWeight.w600),
                        )),
              ],
            ),
            body: SingleChildScrollView(
                child: widget.cubit.connection != false
                    ? EditPatientViewBody(
                        id: widget.id,
                        cubit: widget.cubit,
                        formKey: formKey,
                      )
                    : NoInternet(
                        onPressed: () {
                          widget.cubit.getPatient(id: widget.id);
                          widget.cubit.getBranches();
                        },
                      )),
          ),
        ),
      ),
    );
  }
}
