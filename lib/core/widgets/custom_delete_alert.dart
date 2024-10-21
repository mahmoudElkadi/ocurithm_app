// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:ocurithm/core/utils/app_style.dart';
// import 'package:ocurithm/modules/Reception/features/Patient%20Details/presentation/manger/Patient%20Details%20cubit/patient_details_cubit.dart';
// import 'package:ocurithm/modules/Reception/features/Patient%20Details/presentation/manger/Patient%20Details%20cubit/patient_details_state.dart';

// import '../../generated/l10n.dart';
// import '../utils/colors.dart';

// class CustomAlertDialog extends StatelessWidget {
//   final VoidCallback onConfirm;
//   final String title;
//   final String content;
//   final String buttonTitle;

//   const CustomAlertDialog({super.key, required this.onConfirm, required this.title, required this.content, required this.buttonTitle});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
//       title: Text(title),
//       content: Text(content),
//       actions: <Widget>[
//         TextButton(
//           child: Text(
//             S.of(context).cancel,
//             style: appStyle(context, 18, Colorz.black, FontWeight.w600),
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: Text(
//             buttonTitle,
//             style: appStyle(context, 18, Colorz.black, FontWeight.w600),
//           ),
//           onPressed: () {
//             onConfirm();
//           },
//         ),
//       ],
//     );
//   }
// }

// Future showCustomAlertDialog(
//     {required BuildContext context,
//     required VoidCallback onConfirm,
//     required String title,
//     required String content,
//     required String buttonTitle,
//     required PatientDetailsCubit patientDetailsCubit}) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
//         bloc: patientDetailsCubit,
//         builder: (context, state) => CustomAlertDialog(
//           onConfirm: onConfirm,
//           title: title,
//           content: content,
//           buttonTitle: buttonTitle,
//         ),
//       );
//     },
//   );
// }
