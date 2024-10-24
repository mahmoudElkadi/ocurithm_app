import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:password_generator/password_generator.dart';

import '../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../Add Receptionist/presentation/view/widgets/add_receptionist_view_body.dart';
import '../../manger/Receptionist Details Cubit/receptionist_details_cubit.dart';
import '../../manger/Receptionist Details Cubit/receptionist_details_state.dart';
import 'capabilities_section.dart';

class EditReceptionistViewBody extends StatefulWidget {
  const EditReceptionistViewBody({super.key});

  @override
  State<EditReceptionistViewBody> createState() => _EditReceptionistViewBodyState();
}

class _EditReceptionistViewBodyState extends State<EditReceptionistViewBody> {
  bool _isNameShadow = true;
  bool _isPassShadow = true;
  bool _isPhoneShadow = true;

  final passwordControllerGenerator = PasswordGenerator(
    length: 8,
    hasCapitalLetters: true,
    hasNumbers: true,
    hasSmallLetters: true,
    hasSymbols: true,
  );
  String? profileImageUrl;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<Capability> capabilities = [
    Capability(name: 'Programming'),
    Capability(name: 'Design'),
    Capability(name: 'Project Management'),
    Capability(name: 'Communication'),
    Capability(name: 'Problem Solving'),
  ];

  // List of selected capability names
  List<String> selectedCapabilities = [
    'Programming',
    'Project Management',
    'Communication',
  ];
  @override
  Widget build(BuildContext context) {
    final cubit = ReceptionistDetailsCubit.get(context);
    return BlocBuilder<ReceptionistDetailsCubit, ReceptionistDetailsState>(
        builder: (context, state) => Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ProfileImagePicker(
                        readOnly: cubit.readOnly,
                        initialImageUrl: profileImageUrl,
                        onImageUploaded: (String url) {
                          setState(() {
                            profileImageUrl = url;
                          });
                        },
                      ),
                    ),
                    const HeightSpacer(size: 20),
                    TextField2(
                      controller: cubit.nameController,
                      required: true,
                      hintText: S.of(context).fullName,
                      fillColor: Colorz.white,
                      borderColor: Colorz.activeIcon,
                      readOnly: cubit.readOnly,
                      radius: 30,
                      suffixIcon: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                        child: SvgPicture.asset(
                          "assets/icons/profile.svg",
                        ),
                      ),
                      isShadow: _isNameShadow,
                      validator: (value) {
                        if (value!.isEmpty) {
                          setState(() {
                            _isNameShadow = false;
                          });
                          return S.of(context).mustUsername;
                        }
                        setState(() {
                          _isNameShadow = true;
                        });
                        return null;
                      },
                    ),
                    const HeightSpacer(size: 20),
                    TextField2(
                      // borderMain: ReceptionistDetailsCubit.get(context).textField == true ? Colorz.blue : null,
                      controller: cubit.phoneNumberController,
                      type: TextInputType.phone,
                      required: true,
                      hintText: S.of(context).phone,
                      readOnly: cubit.readOnly,

                      validator: (value) {
                        if (value!.isEmpty) {
                          setState(() {
                            _isPhoneShadow = false;
                          });
                          return S.of(context).mustPhone;
                        } else if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
                          setState(() {
                            _isPhoneShadow = false;
                          });
                          return S.of(context).invalidPhoneNumber;
                        }
                        setState(() {
                          _isPhoneShadow = true;
                        });
                        return null;
                      },
                      fillColor: Colorz.white,
                      borderColor: Colorz.activeIcon,
                      radius: 30,
                      suffixIcon: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                        child: SvgPicture.asset(
                          "assets/icons/phone_number.svg",
                        ),
                      ),
                      isShadow: _isPhoneShadow,
                    ),
                    const HeightSpacer(size: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField2(
                            // borderMain: ReceptionistDetailsCubit.get(context).textField == true ? Colorz.blue : null,
                            controller: cubit.passwordController,
                            required: true,
                            hintText: S.of(context).password,
                            readOnly: cubit.readOnly,

                            fillColor: Colorz.white,
                            borderColor: Colorz.activeIcon,
                            radius: 30,
                            isPassword: ReceptionistDetailsCubit.get(context).obscureText,
                            suffixIcon: ReceptionistDetailsCubit.get(context).obscureText == false
                                ? IconButton(
                                    onPressed: () {
                                      ReceptionistDetailsCubit.get(context).obscureText = !ReceptionistDetailsCubit.get(context).obscureText;
                                    },
                                    icon: Icon(Icons.visibility),
                                    color: Colorz.blue,
                                  )
                                : IconButton(
                                    onPressed: () {
                                      ReceptionistDetailsCubit.get(context).obscureText = !ReceptionistDetailsCubit.get(context).obscureText;
                                    },
                                    icon: Icon(Icons.visibility_off),
                                    color: Colorz.blue,
                                  ),
                            isShadow: _isPassShadow,
                            validator: (value) {
                              if (value!.isEmpty) {
                                setState(() {
                                  _isPassShadow = false;
                                });
                                return S.of(context).mustPassword;
                              }
                              setState(() {
                                _isPassShadow = true;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colorz.white,
                                boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 2, blurRadius: 3, offset: const Offset(0, 0))],
                              ),
                              child: IconButton(
                                onPressed: cubit.readOnly
                                    ? null
                                    : () {
                                        final String generatedPassword = passwordControllerGenerator.generatePassword();
                                        final double entropy = generatedPassword.checkStrength();
                                        if (entropy >= 128) {
                                          log('Extremely Strong.');
                                          setState(() {
                                            cubit.passwordController.text = generatedPassword;
                                          });
                                        } else if (entropy >= 60) {
                                          log('Very Strong.');
                                          setState(() {
                                            cubit.passwordController.text = generatedPassword;
                                          });
                                        } else if (entropy >= 36) {
                                          setState(() {
                                            cubit.passwordController.text = generatedPassword;
                                          });
                                          log('Strong.');
                                        } else if (entropy >= 28) {
                                          setState(() {
                                            cubit.passwordController.text = generatedPassword;
                                          });
                                          log('Ok.');
                                        }
                                      },
                                icon: SvgPicture.asset("assets/icons/password.svg"),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const HeightSpacer(size: 20),
                    cubit.readOnly
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            width: Get.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colorz.white,
                              boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 2, blurRadius: 3, offset: const Offset(0, 0))],
                            ),
                            child: const Text(
                              "sidasi",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ))
                        : DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.blue,
                            ),
                            items: const ['Male', 'Female'],
                            isValid: cubit.chooseBranch,
                            validateText: S.of(context).mustBranch,
                            selectedValue: cubit.selectedBranch,
                            hintText: 'Select Branch',
                            itemAsString: (item) => item.toString(),
                            onItemSelected: (item) {
                              setState(() {
                                if (item != "Not Found") {
                                  cubit.chooseBranch = true;
                                  cubit.selectedBranch = "$item sds";
                                  log(cubit.selectedBranch.toString());
                                }
                              });
                            },
                            isLoading: false,
                          ),
                    const HeightSpacer(size: 20),
                    CapabilitiesSection(
                      capabilities: capabilities,
                      readOnly: cubit.readOnly,
                      initialSelectedCapabilities: selectedCapabilities,
                      onSelectionChanged: (newSelection) {
                        selectedCapabilities = newSelection;
                        log(selectedCapabilities.toString());
                        setState(() {});
                      },
                    ),
                    const HeightSpacer(size: 20),
                    Divider(
                      thickness: 0.4,
                      color: Colorz.grey,
                    ),
                    const HeightSpacer(size: 20),
                    Text(S.of(context).dateOfBirth, style: TextStyle(color: Colorz.black, fontWeight: FontWeight.w600, fontSize: 18)),
                    const HeightSpacer(size: 10),
                    InkWell(
                      onTap: () async {
                        if (cubit.readOnly == false) {
                          showDatePicker(
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colorz.activeIcon,
                                    onPrimary: Colorz.background,
                                    onSurface: Colors.black,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colorz.activeIcon,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ).then((selectedDate) {
                            // After selecting the date, display the time picker.
                            if (selectedDate != null) {
                              ReceptionistDetailsCubit.get(context).date = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                              );
                              setState(() {
                                log(ReceptionistDetailsCubit.get(context).date.toString());
                              });
                            }
                          });
                        }
                      },
                      child: Ink(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: HexColor("#E7EDEF"),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: ReceptionistDetailsCubit.get(context).picDate == false ? Colors.redAccent : Colors.transparent, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    ReceptionistDetailsCubit.get(context).date != null
                                        ? "${ReceptionistDetailsCubit.get(context).date!.day}"
                                        : S.of(context).dd,
                                    style: appStyle(context, 18, Colorz.black, FontWeight.w600),
                                  ),
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 30,
                                decoration: BoxDecoration(color: Colorz.white, borderRadius: BorderRadius.circular(30)),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    ReceptionistDetailsCubit.get(context).date != null
                                        ? "${ReceptionistDetailsCubit.get(context).date!.month}"
                                        : S.of(context).mm,
                                    style: appStyle(context, 18, Colorz.black, FontWeight.w600),
                                  ),
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 30,
                                decoration: BoxDecoration(color: Colorz.white, borderRadius: BorderRadius.circular(30)),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    ReceptionistDetailsCubit.get(context).date != null
                                        ? "${ReceptionistDetailsCubit.get(context).date!.year}"
                                        : S.of(context).yy,
                                    style: appStyle(context, 18, Colorz.black, FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (ReceptionistDetailsCubit.get(context).picDate == false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HeightSpacer(
                              size: 10,
                            ),
                            Text(
                              S.of(context).mustBirth,
                              style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    const HeightSpacer(size: 20),

                    // Align(
                    //   alignment: Alignment.center,
                    //   child: InkWell(
                    //     onTap: () {
                    //       log("message");
                    //       ReceptionistDetailsCubit.get(context).validateFirstPage();
                    //       log("message1");
                    //       log(ReceptionistDetailsCubit.get(context).isValidate.toString());
                    //
                    //       setState(() {});
                    //       if (formKey.currentState!.validate() && ReceptionistDetailsCubit.get(context).isValidate) {
                    //         customLoading(context, "");
                    //         ReceptionistDetailsCubit.get(context).ReceptionistDetails(
                    //           context: context,
                    //           fullName: nameController.text,
                    //           password: passwordController.text,
                    //           phone: phoneNumberController.text,
                    //           gender: ReceptionistDetailsCubit.get(context).selectedGender!,
                    //           dateOfBirth: ReceptionistDetailsCubit.get(context).date.toString(),
                    //           branchId: ReceptionistDetailsCubit.get(context).branchId.toString(),
                    //         );
                    //       }
                    //     },
                    //     highlightColor: Colors.transparent,
                    //     splashColor: Colors.transparent,
                    //     child: Ink(
                    //       child: Container(
                    //         padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(30),
                    //           gradient: LinearGradient(
                    //             begin: Alignment.bottomCenter,
                    //             end: Alignment.topCenter,
                    //             colors: [
                    //               HexColor("#0E3366"),
                    //               HexColor("#174784"),
                    //               HexColor("#174784"),
                    //               HexColor("#174784"),
                    //               HexColor("#3E86DD"),
                    //             ],
                    //           ),
                    //         ),
                    //         child: Text(
                    //           S.of(context).addReceptionist,
                    //           style: appStyle(context, 18, Colors.white, FontWeight.w600),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            ));
  }
}
