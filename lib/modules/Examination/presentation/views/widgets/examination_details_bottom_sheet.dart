import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/modules/Examination/presentation/views/widgets/examination_pdf_service.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_one_examination_cubit/get_one_examination_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/views/examination_view/one_examination_content.dart';

/// A past examination, opened on top of the one being written.
///
/// Deliberately a sheet rather than a route: the examination form lives in the
/// `ExaminationFormCubit` provided above this screen, so everything the doctor has
/// typed is still there when they close it.
class ExaminationDetailsBottomSheet extends StatelessWidget {
  const ExaminationDetailsBottomSheet({super.key, required this.examinationId});

  final String examinationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<GetOneExaminationCubit>()..getExamination(examinationId),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            BlocBuilder<GetOneExaminationCubit, GetOneExaminationState>(
              builder: (context, state) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Examination Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  Row(
                    children: [
                      if (state.examination != null && !state.isLoading)
                        IconButton(
                          onPressed: () =>
                              ExaminationPdfService.generateAndPrintOneExamination(
                                  state.examination!),
                          icon: Icon(Icons.print_outlined,
                              color: Colorz.primaryColor),
                        ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: BlocBuilder<GetOneExaminationCubit,
                  GetOneExaminationState>(
                builder: (context, state) {
                  if (state.isLoading || state.examination == null) {
                    return Center(
                      child: CircularProgressIndicator(
                          color: Colorz.primaryColor),
                    );
                  }

                  if (state.isError) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load examination',
                      ),
                    );
                  }

                  return OneExaminationContent(
                      examination: state.examination!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
