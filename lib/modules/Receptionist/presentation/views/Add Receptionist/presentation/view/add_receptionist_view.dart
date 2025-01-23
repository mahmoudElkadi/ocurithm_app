import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/modules/Receptionist/presentation/views/Add%20Receptionist/presentation/view/widgets/add_receptionist_view_body.dart';

import '../../../../../../../../generated/l10n.dart';
import '../../../../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../../../../manger/Receptionist Details Cubit/receptionist_details_state.dart';

class CreateReceptionistView extends StatefulWidget {
  const CreateReceptionistView({super.key, required this.cubit});
  final ReceptionistCubit cubit;

  @override
  State<CreateReceptionistView> createState() => _CreateReceptionistViewState();
}

class _CreateReceptionistViewState extends State<CreateReceptionistView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _handleSave(BuildContext context) async {
    widget.cubit.validateFirstPage();
    if (formKey.currentState!.validate() && widget.cubit.validateFirstPage() == true) {
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

        await widget.cubit.addReceptionist(context: context);
      } catch (e) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: BlocBuilder<ReceptionistCubit, ReceptionistState>(
        bloc: widget.cubit,
        builder: (context, state) => WillPopScope(
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
                    Get.back();
                    widget.cubit.clearData();
                  }),
              title: Text(
                S.of(context).createReceptionist,
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
                    ? CreateReceptionistViewBody(cubit: widget.cubit, formKey: formKey)
                    : NoInternet(
                        onPressed: () async {
                          widget.cubit.checkConnection();
                        },
                      )),
          ),
        ),
      ),
    );
  }
}
