import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/data/repos/Patient_repo_impl.dart';
import 'package:ocurithm/modules/Patient/presentation/views/Patient%20Details/presentation/view/widgets/patient_details_view_body.dart';

import '../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../core/widgets/no_internet.dart';
import '../../../../../../../core/Network/shared.dart';
import '../../../../manager/patient_cubit.dart';
import '../../../../manager/patient_state.dart';

class PatientDetailsView extends StatefulWidget {
  const PatientDetailsView({super.key, required this.id, this.patient});

  final String id;
  final Patient? patient;

  // final PatientCubit cubit;

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

  Future<void> _handleSave(BuildContext context, PatientCubit cubit) async {
    if (!_mounted) return;

    if (formKey.currentState!.validate() && cubit.validateFirstPage() == true) {
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

        await cubit.updatePatient(id: widget.id, context: context);
        if (cubit.state is UpdatePatientSuccess) {
          widget.patient?.name = cubit.updatedPatient?.name;
          widget.patient?.password = cubit.updatedPatient?.password;
          widget.patient?.phone = cubit.updatedPatient?.phone;
          widget.patient?.birthDate = cubit.updatedPatient?.birthDate;
          widget.patient?.nationalId = cubit.updatedPatient?.nationalId;
          widget.patient?.nationality = cubit.updatedPatient?.nationality;
          widget.patient?.email = cubit.updatedPatient?.email;
          widget.patient?.address = cubit.updatedPatient?.address;
          widget.patient?.gender = cubit.updatedPatient?.gender;
          widget.patient?.username = cubit.updatedPatient?.username;
          widget.patient?.branch = cubit.updatedPatient?.branch;
        }
      } catch (e) {
        if (!_mounted) return;
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _handleWillPop(PatientCubit cubit) async {
    if (!_mounted) return true;
    cubit.readOnly = true;
    cubit.clearData();
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientCubit(PatientRepoImpl()),
      child: BlocBuilder<PatientCubit, PatientState>(
        builder: (context, state) => GestureDetector(
          onTap: () {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          },
          child: WillPopScope(
            onWillPop: () => _handleWillPop(context.read<PatientCubit>()),
            child: Scaffold(
              backgroundColor: Colorz.white,
              appBar: AppBar(
                backgroundColor: Colorz.white,
                leading: IconButton(
                  icon: Icon(Icons.close, color: Colorz.black),
                  onPressed: () {
                    Get.back();
                    context.read<PatientCubit>().readOnly = true;
                    context.read<PatientCubit>().clearData();
                    setState(() {});
                  },
                ),
                title: Text(
                  "Patient Details",
                  style: appStyle(context, 20, Colorz.black, FontWeight.w600),
                ),
                centerTitle: true,
                actions: [
                  context.read<PatientCubit>().readOnly == true
                      ? IconButton(
                          onPressed: () async {
                            setState(() {
                              context.read<PatientCubit>().readOnly =
                                  !context.read<PatientCubit>().readOnly;
                            });
                            if (CacheHelper.getStringList(key: "capabilities")
                                .contains("manageCapabilities")) {
                              if (context.read<PatientCubit>().clinics ==
                                  null) {
                                await context.read<PatientCubit>().getClinics();
                              }
                              await context.read<PatientCubit>().getBranches();
                            } else {
                              context.read<PatientCubit>().getBranches();
                            }
                          },
                          icon: Icon(Icons.edit, color: Colorz.black),
                        )
                      : TextButton(
                          onPressed: () {
                            _handleSave(context, context.read<PatientCubit>());
                          },
                          child: Text(
                            "Done",
                            style: appStyle(context, 16, Colorz.primaryColor,
                                FontWeight.w600),
                          )),
                ],
              ),
              body: SingleChildScrollView(
                  child: context.read<PatientCubit>().connection != false
                      ? EditPatientViewBody(
                          id: widget.id,
                          cubit: context.read<PatientCubit>(),
                          formKey: formKey,
                        )
                      : NoInternet(
                          onPressed: () {
                            context.read<PatientCubit>().readOnly = true;
                            context.read<PatientCubit>().chooseClinic = true;
                            context.read<PatientCubit>().checkConnection();
                          },
                        )),
            ),
          ),
        ),
      ),
    );
  }
}
