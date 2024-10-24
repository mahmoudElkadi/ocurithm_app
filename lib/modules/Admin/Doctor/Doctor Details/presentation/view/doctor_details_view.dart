import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Admin/Doctor/Doctor%20Details/presentation/view/widgets/doctor_details_view_body.dart';

import '../../data/repos/doctor_details_repo_impl.dart';
import '../manger/Receptionist Details Cubit/doctor_details_cubit.dart';
import '../manger/Receptionist Details Cubit/doctor_details_state.dart';

class DoctorDetailsView extends StatefulWidget {
  const DoctorDetailsView({super.key, this.nationalId, this.readOnly});
  final String? nationalId;
  final bool? readOnly;

  @override
  State<DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<DoctorDetailsView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorDetailsCubit(DoctorDetailsRepoImpl()),
      child: BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
        builder: (context, state) => GestureDetector(
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
                "Doctor Details",
                style: appStyle(context, 20, Colorz.black, FontWeight.w600),
              ),
              centerTitle: true,
              actions: [
                DoctorDetailsCubit.get(context).readOnly == true
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            DoctorDetailsCubit.get(context).readOnly = !DoctorDetailsCubit.get(context).readOnly;
                          });
                        },
                        icon: Icon(Icons.edit, color: Colorz.black),
                      )
                    : TextButton(
                        onPressed: () {},
                        child: Text(
                          "Done",
                          style: appStyle(context, 16, Colorz.primaryColor, FontWeight.w600),
                        )),
              ],
            ),
            body: const SingleChildScrollView(child: EditDoctorViewBody()),
          ),
        ),
      ),
    );
  }
}
