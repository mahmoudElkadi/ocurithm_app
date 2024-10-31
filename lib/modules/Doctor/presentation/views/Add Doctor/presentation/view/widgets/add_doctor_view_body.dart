import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:password_generator/password_generator.dart';

import '../../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../../generated/l10n.dart';
import '../../../../../../../Receptionist/presentation/views/Add Receptionist/presentation/view/widgets/add_receptionist_view_body.dart';
import '../../../../../../../Receptionist/presentation/views/Receptionist Details/presentation/view/widgets/capabilities_section.dart';
import '../../../../../manager/doctor_cubit.dart';
import '../../../../../manager/doctor_state.dart';

class CreateDoctorViewBody extends StatefulWidget {
  const CreateDoctorViewBody({super.key, required this.cubit, required this.formKey});

  final DoctorCubit cubit;
  final GlobalKey<FormState> formKey;

  @override
  State<CreateDoctorViewBody> createState() => _CreateDoctorViewBodyState();
}

class _CreateDoctorViewBodyState extends State<CreateDoctorViewBody> {
  bool _isNameShadow = true;
  bool _isPassShadow = true;
  bool _isPhoneShadow = true;
  bool _isQualificationShadow = true;

  final passwordControllerGenerator = PasswordGenerator(
    length: 8,
    hasCapitalLetters: true,
    hasNumbers: true,
    hasSmallLetters: true,
    hasSymbols: true,
  );

  @override
  void initState() {
    super.initState();
    widget.cubit.getBranches();
  }

  final List<Capability> capabilities = [
    Capability(name: 'Programming'),
    Capability(name: 'Design'),
    Capability(name: 'Project Management'),
    Capability(name: 'Communication'),
    Capability(name: 'Problem Solving'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorCubit, DoctorState>(
        bloc: widget.cubit,
        builder: (context, state) => Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ProfileImagePicker(
                        initialImageUrl: widget.cubit.imageUrl,
                        onImageUploaded: (String url) {
                          setState(() {
                            widget.cubit.imageUrl = url;
                          });
                        },
                      ),
                    ),
                    const HeightSpacer(size: 20),
                    TextField2(
                      controller: widget.cubit.nameController,
                      required: true,
                      hintText: S.of(context).fullName,
                      fillColor: Colorz.white,
                      borderColor: Colorz.activeIcon,
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
                      // borderMain: widget.cubit.textField == true ? Colorz.blue : null,
                      controller: widget.cubit.phoneNumberController,
                      type: TextInputType.phone,
                      required: true,
                      hintText: S.of(context).phone,
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
                            // borderMain: widget.cubit.textField == true ? Colorz.blue : null,
                            controller: widget.cubit.passwordController,
                            required: true,
                            hintText: S.of(context).password,
                            fillColor: Colorz.white,
                            borderColor: Colorz.activeIcon,
                            radius: 30,
                            isPassword: widget.cubit.obscureText,
                            suffixIcon: widget.cubit.obscureText == false
                                ? IconButton(
                                    onPressed: () {
                                      widget.cubit.obscureText = !widget.cubit.obscureText;
                                    },
                                    icon: Icon(Icons.visibility),
                                    color: Colorz.blue,
                                  )
                                : IconButton(
                                    onPressed: () {
                                      widget.cubit.obscureText = !widget.cubit.obscureText;
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
                                onPressed: () {
                                  final String generatedPassword = passwordControllerGenerator.generatePassword();
                                  final double entropy = generatedPassword.checkStrength();
                                  if (entropy >= 128) {
                                    log('Extremely Strong.');
                                    setState(() {
                                      widget.cubit.passwordController.text = generatedPassword;
                                    });
                                  } else if (entropy >= 60) {
                                    log('Very Strong.');
                                    setState(() {
                                      widget.cubit.passwordController.text = generatedPassword;
                                    });
                                  } else if (entropy >= 36) {
                                    setState(() {
                                      widget.cubit.passwordController.text = generatedPassword;
                                    });
                                    log('Strong.');
                                  } else if (entropy >= 28) {
                                    setState(() {
                                      widget.cubit.passwordController.text = generatedPassword;
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
                    DropdownItem(
                      radius: 30,
                      color: Colorz.white,
                      isShadow: true,
                      iconData: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colorz.blue,
                      ),
                      items: widget.cubit.branches?.branches,
                      isValid: widget.cubit.chooseBranch,
                      validateText: S.of(context).mustBranch,
                      selectedValue: widget.cubit.selectedBranch,
                      hintText: 'Select Branch',
                      itemAsString: (item) => item.name.toString(),
                      onItemSelected: (item) {
                        setState(() {
                          if (item != "Not Found") {
                            widget.cubit.chooseBranch = true;
                            widget.cubit.selectedBranch = item.name;
                            widget.cubit.branchId = item.id;
                            log(widget.cubit.selectedBranch.toString());
                          }
                        });
                      },
                      isLoading: widget.cubit.loading,
                    ),
                    const HeightSpacer(size: 20),
                    CapabilitiesSection(
                      capabilities: capabilities,
                      onSelectionChanged: (newSelection) {
                        widget.cubit.capabilitiesList = newSelection;
                        log(widget.cubit.capabilitiesList.toString());
                        setState(() {});
                      },
                      initialSelectedCapabilities: const [],
                    ),
                    const HeightSpacer(size: 20),
                    MultilineTextInput(
                      hint: 'Enter Doctor Qualification',
                      maxHeight: 200,
                      onSubmitted: (text) {},
                      isShadow: _isQualificationShadow,
                      validator: (value) {
                        if (value!.isEmpty) {
                          setState(() {
                            _isQualificationShadow = false;
                          });
                          return S.of(context).mustQualification;
                        }
                        setState(() {
                          _isQualificationShadow = true;
                        });
                      },
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      color: Colorz.white,
                      controller: widget.cubit.qualificationController,
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
                            widget.cubit.date = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                            );
                            setState(() {
                              log(widget.cubit.date.toString());
                            });
                          }
                        });
                      },
                      child: Ink(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: HexColor("#E7EDEF"),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: widget.cubit.picDate == false ? Colors.redAccent : Colors.transparent, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.cubit.date != null ? "${widget.cubit.date!.day}" : S.of(context).dd,
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
                                    widget.cubit.date != null ? "${widget.cubit.date!.month}" : S.of(context).mm,
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
                                    widget.cubit.date != null ? "${widget.cubit.date!.year}" : S.of(context).yy,
                                    style: appStyle(context, 18, Colorz.black, FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (widget.cubit.picDate == false)
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
                  ],
                ),
              ),
            ));
  }
}
