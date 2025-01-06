import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/Receptionist%20Details/presentation/view/widgets/edit_receptionist.dart';

import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../core/Network/shared.dart';
import '../../../../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../../../../manger/Receptionist Details Cubit/receptionist_details_state.dart';

class ReceptionistDetailsView extends StatefulWidget {
  const ReceptionistDetailsView({super.key, required this.cubit, required this.id});

  final ReceptionistCubit cubit;
  final String id;

  @override
  State<ReceptionistDetailsView> createState() => _ReceptionistDetailsViewState();
}

class _ReceptionistDetailsViewState extends State<ReceptionistDetailsView> {
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

        await widget.cubit.updateReceptionist(id: widget.id, context: context);
      } catch (e) {
        if (!_mounted) return;
        log("Error saving: $e");
        Navigator.of(context).pop();
      }
    }
  }

  void _handleEdit() async {
    if (!_mounted) return;
    setState(() {
      widget.cubit.readOnly = !widget.cubit.readOnly;
    });
    if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities")) {
      if (widget.cubit.clinics == null) {
        Future.wait([widget.cubit.getClinics(), widget.cubit.getBranches()]);
      } else {
        widget.cubit.getBranches();
      }
    } else {
      widget.cubit.getBranches();
    }
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
    return BlocBuilder<ReceptionistCubit, ReceptionistState>(
      bloc: widget.cubit,
      builder: (context, state) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: _handleWillPop,
          child: Scaffold(
            backgroundColor: Colorz.white,
            appBar: AppBar(
              backgroundColor: Colorz.white,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colorz.black),
                onPressed: () async {
                  Navigator.of(context).pop();
                  widget.cubit.clearData();

                  widget.cubit.readOnly = true;
                  setState(() {});
                },
              ),
              title: Text(
                "Receptionist Details",
                style: appStyle(context, 20, Colorz.black, FontWeight.w600),
              ),
              centerTitle: true,
              actions: [
                widget.cubit.readOnly
                    ? IconButton(
                        onPressed: _handleEdit,
                        icon: Icon(Icons.edit, color: Colorz.black),
                      )
                    : TextButton(
                        onPressed: () => _handleSave(context),
                        child: Text(
                          "Done",
                          style: appStyle(context, 16, Colorz.primaryColor, FontWeight.w600),
                        )),
              ],
            ),
            body: SingleChildScrollView(
                child: widget.cubit.connection != false
                    ? EditReceptionistViewBody(
                        formKey: formKey,
                        cubit: widget.cubit,
                        id: widget.id,
                      )
                    : NoInternet(
                        onPressed: () async {
                          widget.cubit.getReceptionist(id: widget.id);
                        },
                      )),
          ),
        ),
      ),
    );
  }
}
