import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../../../core/utils/app_style.dart';
import '../../../../../../../../../core/utils/colors.dart';
import '../../../../../../../../../core/widgets/confirmation_popuo.dart';
import '../../../../../../../../../core/widgets/custom_freeze_loading.dart';
import '../../../../../../../../../core/widgets/height_spacer.dart';
import '../../../../../../../../../core/widgets/pagination.dart';
import '../../../../../../../../../core/widgets/width_spacer.dart';
import '../../../../../../../../core/Network/shared.dart';
import '../../../../../../data/model/patients_model.dart';
import '../../../../../manager/get_patients_cubit/get_patients_cubit.dart';
import '../../../../../manager/patient_actions_cubit/patient_actions_cubit.dart';
import '../../../../patient_form/patient_form_page.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.isLoading,
    this.patient,
  });

  final bool isLoading;
  final Patient? patient;

  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (patient?.id != null) {
          bool? result = await Get.to(() => PatientFormPage(
              mode: PatientFormMode.view, patientId: patient!.id!));
          if (result == true) {
            context.read<GetPatientsCubit>().add(GetAllPatientsEvent());
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),
          decoration: BoxDecoration(
              color: Colorz.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ]),
          child: Row(children: [
            isLoading
                ? _buildShimmer(Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ))
                : Expanded(
                    flex: 1,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade200,
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 0))
                        ],
                      ),
                      child: patient?.name != null
                          ? Center(
                              child: Text(
                                  patient?.name?.split("")[0].toUpperCase()
                                      as String,
                                  style: appStyle(context, 30,
                                      Colors.grey.shade700, FontWeight.bold)))
                          : null,
                    ),
                  ),
            const WidthSpacer(size: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeightSpacer(size: 5),
                  isLoading
                      ? _buildShimmer(Container(
                          width: 170,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ))
                      : Text(
                          patient?.name ?? "N/A",
                          maxLines: 2,
                          style: GoogleFonts.inter(
                              textStyle: appStyle(context, 16,
                                      HexColor("#2A282F"), FontWeight.w600)
                                  .copyWith(overflow: TextOverflow.ellipsis)),
                        ),
                  const HeightSpacer(size: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onLongPress: () async {
                          await Clipboard.setData(
                              ClipboardData(text: patient?.phone ?? "N/A"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Copied"),
                            ),
                          );
                        },
                        child: isLoading
                            ? _buildShimmer(Container(
                                width: 100,
                                height: 20,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Colors.white,
                                ),
                              ))
                            : Text(
                                patient?.phone ?? "N/A",
                                style: appStyle(
                                    context, 18, Colorz.grey, FontWeight.w400),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (CacheHelper.getStringList(key: "capabilities")
                .contains("managePatients"))
              isLoading
                  ? _buildShimmer(Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ))
                  : IconButton(
                      onPressed: () async {
                        showConfirmationDialog(
                          context: context,
                          title: "Delete Patient",
                          message:
                              "Do you want to Delete ${patient?.name ?? "this Patient"}?",
                          onConfirm: () async {
                            customLoading(context, "");
                            bool connection =
                                await InternetConnection().hasInternetAccess;
                            if (!connection) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  "No Internet Connection",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              // Use PatientActionsCubit
                              context
                                  .read<PatientActionsCubit>()
                                  .add(DeletePatientEvent(patient!.id!));
                              Navigator.pop(context); // close dialog
                              // Loading dialog is handled by UI?
                              // Current code shows loading then closes dialog.
                              // Since ActionsCubit is listened to in PatientView, it will show Snackbars.
                              // So I should just dispatch event.
                              // But I turned on customLoading. I should pop customLoading if I rely on listener.
                              // Or I rely on listener to pop loading?
                              // Doctor module: Listener pops loading?
                              Navigator.pop(context); // close loading
                            }
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colorz.redColor,
                      )),
          ]),
        ),
      ),
    );
  }
}

class PatientListView extends StatelessWidget {
  const PatientListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPatientsCubit, GetPatientsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildLoadingList();
        } else if (state.patients == null ||
            (state.patients?.patients.isEmpty ?? true)) {
          return _buildEmptyState();
        } else {
          return _buildPatientList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const PatientCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 4,
    );
  }

  Widget _buildPatientList(BuildContext context, GetPatientsState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          PatientCard(
            patient: state.patients!.patients[index],
            isLoading: false,
          ),
          state.patients!.patients.length != index + 1
              ? const SizedBox.shrink()
              : state.patients?.totalPages != null &&
                      state.patients!.totalPages! > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20)
                          .copyWith(bottom: 20),
                      child: CustomPagination(
                          currentPage: state.page,
                          totalPages:
                              int.parse('${state.patients?.totalPages ?? 0}'),
                          onPageChanged: (int newPage) {
                            context
                                .read<GetPatientsCubit>()
                                .add(SetPageEvent(newPage));
                            context
                                .read<GetPatientsCubit>()
                                .add(GetAllPatientsEvent());
                          }),
                    )
                  : const HeightSpacer(size: 10),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.patients!.patients.length,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightSpacer(size: 30),
          Icon(Icons.inbox_outlined, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Patient found',
            style: TextStyle(
                fontSize: 22,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Patient will appear here',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
