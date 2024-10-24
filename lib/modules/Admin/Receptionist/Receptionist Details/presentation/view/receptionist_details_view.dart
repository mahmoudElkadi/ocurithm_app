import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Admin/Receptionist/Receptionist%20Details/presentation/view/widgets/edit_receptionist.dart';

import '../../data/repos/receptionist_details_repo_impl.dart';
import '../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../manger/Receptionist Details Cubit/receptionist_details_state.dart';

class ReceptionistDetailsView extends StatefulWidget {
  const ReceptionistDetailsView({super.key, this.nationalId, this.readOnly});
  final String? nationalId;
  final bool? readOnly;

  @override
  State<ReceptionistDetailsView> createState() => _ReceptionistDetailsViewState();
}

class _ReceptionistDetailsViewState extends State<ReceptionistDetailsView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReceptionistDetailsCubit(ReceptionistDetailsRepoImpl()),
      child: BlocBuilder<ReceptionistDetailsCubit, ReceptionistDetailsState>(
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
                "Receptionist Details",
                style: appStyle(context, 20, Colorz.black, FontWeight.w600),
              ),
              centerTitle: true,
              actions: [
                ReceptionistDetailsCubit.get(context).readOnly == true
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            ReceptionistDetailsCubit.get(context).readOnly = !ReceptionistDetailsCubit.get(context).readOnly;
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
            body: const SingleChildScrollView(child: EditReceptionistViewBody()),
          ),
        ),
      ),
    );
  }
}
