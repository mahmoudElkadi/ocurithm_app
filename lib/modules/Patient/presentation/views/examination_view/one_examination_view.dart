import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Patient/presentation/manager/get_one_examination_cubit/get_one_examination_cubit.dart';
import 'package:ocurithm/modules/Patient/presentation/views/examination_view/one_examination_content.dart';

class OneExaminationView extends StatefulWidget {
  const OneExaminationView({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<OneExaminationView> createState() => _OneExaminationViewState();
}

class _OneExaminationViewState extends State<OneExaminationView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          sl<GetOneExaminationCubit>()..getExamination(widget.id),
      child: BlocBuilder<GetOneExaminationCubit, GetOneExaminationState>(
        builder: (BuildContext context, state) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colorz.primaryColor,
            title: const Text("Examination Details"),
          ),
          body: state.isLoading || state.examination == null
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colorz.primaryColor,
                ))
              : OneExaminationContent(examination: state.examination!),
        ),
      ),
    );
  }
}
