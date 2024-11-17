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
import 'package:shimmer/shimmer.dart';

import '../../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../../generated/l10n.dart';
import '../../../../../../../Receptionist/presentation/views/Receptionist Details/presentation/view/widgets/capabilities_section.dart';
import '../../../../../manager/patient_cubit.dart';
import '../../../../../manager/patient_state.dart';

class EditPatientViewBody extends StatefulWidget {
  const EditPatientViewBody({super.key, required this.cubit, required this.formKey, required this.id});
  final PatientCubit cubit;
  final GlobalKey<FormState> formKey;
  final String id;

  @override
  State<EditPatientViewBody> createState() => _EditPatientViewBodyState();
}

class _EditPatientViewBodyState extends State<EditPatientViewBody> {
  bool _isNameShadow = true;
  bool _emailShadow = true;
  bool _isPhoneShadow = true;
  bool _nationalIdShadow = true;

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
    fetchPatientData();
  }

  fetchPatientData() async {
    await widget.cubit.getPatient(id: widget.id);

    if (widget.cubit.patient != null) {
      widget.cubit.nameController.text = widget.cubit.patient?.name ?? '';
      widget.cubit.phoneNumberController.text = widget.cubit.patient?.phone ?? "";
      widget.cubit.date = widget.cubit.patient?.birthDate;
      widget.cubit.selectedBranch = widget.cubit.patient?.branch?.name;
      widget.cubit.branchId = widget.cubit.patient?.branch?.id;
      widget.cubit.selectedGender = widget.cubit.patient?.gender;
      widget.cubit.emailController.text = widget.cubit.patient?.email ?? "";
      widget.cubit.addressController.text = widget.cubit.patient?.address ?? "";
      widget.cubit.nationalityController.text = widget.cubit.patient?.nationality ?? "";
      widget.cubit.nationalIdController.text = widget.cubit.patient?.nationalId ?? "";
    }
    await widget.cubit.getBranches();
  }

  final List<Capability> capabilities = [
    Capability(name: 'Programming'),
    Capability(name: 'Design'),
    Capability(name: 'Project Management'),
    Capability(name: 'Communication'),
    Capability(name: 'Problem Solving'),
  ];

  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.cubit.patient == null;

    return BlocBuilder<PatientCubit, PatientState>(
        bloc: widget.cubit,
        builder: (context, state) => Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : widget.cubit.readOnly
                            ? Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                width: Get.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colorz.white,
                                  boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 2, blurRadius: 3, offset: const Offset(0, 0))],
                                ),
                                child: Text(
                                  widget.cubit.patient?.branch?.name ?? "",
                                  style: const TextStyle(
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
                                  color: Colorz.primaryColor,
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
                                isLoading: false,
                              ),
                    const HeightSpacer(size: 20),
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : TextField2(
                            controller: widget.cubit.nameController,
                            required: true,
                            type: TextInputType.name,
                            hintText: S.of(context).fullName,
                            fillColor: Colorz.white,
                            borderColor: Colorz.primaryColor,
                            readOnly: widget.cubit.readOnly,
                            radius: 30,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                              child: SvgPicture.asset(
                                color: Colorz.primaryColor,
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
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : TextField2(
                            controller: widget.cubit.emailController,
                            required: true,
                            readOnly: widget.cubit.readOnly,
                            validator: (value) {
                              if (value!.isNotEmpty) {
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                                  setState(() {
                                    _emailShadow = false;
                                  });
                                  return S.of(context).invalidEmail;
                                }
                              }
                              setState(() {
                                _emailShadow = true;
                              });
                              return null;
                            },
                            type: TextInputType.emailAddress,
                            hintText: S.of(context).emailAddress,
                            fillColor: Colorz.white,
                            borderColor: Colorz.primaryColor,
                            radius: 30,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                              child: SvgPicture.asset(
                                color: Colorz.primaryColor,
                                "assets/icons/email.svg",
                              ),
                            ),
                            isShadow: true,
                          ),
                    const HeightSpacer(size: 20),
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : TextField2(
                            // borderMain: widget.cubit.textField == true ? Colorz.primaryColor : null,
                            controller: widget.cubit.phoneNumberController,
                            type: TextInputType.phone,
                            required: true,
                            hintText: S.of(context).phone,
                            readOnly: widget.cubit.readOnly,

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
                            borderColor: Colorz.primaryColor,
                            radius: 30,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                              child: SvgPicture.asset(
                                color: Colorz.primaryColor,
                                "assets/icons/phone_number.svg",
                              ),
                            ),
                            isShadow: _isPhoneShadow,
                          ),
                    const HeightSpacer(size: 20),
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : TextField2(
                            controller: widget.cubit.addressController,
                            readOnly: widget.cubit.readOnly,
                            required: false,
                            hintText: S.of(context).address,
                            fillColor: Colorz.white,
                            borderColor: Colorz.primaryColor,
                            radius: 30,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                              child: SvgPicture.asset(
                                color: Colorz.primaryColor,
                                "assets/icons/home.svg",
                              ),
                            ),
                            isShadow: true),
                    const HeightSpacer(size: 20),
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : TextField2(
                            controller: widget.cubit.nationalIdController,
                            type: TextInputType.number,
                            readOnly: widget.cubit.readOnly,
                            required: true,
                            hintText: S.of(context).nationalId,
                            fillColor: Colorz.white,
                            borderColor: Colorz.primaryColor,
                            radius: 30,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                              child: SvgPicture.asset(
                                color: Colorz.primaryColor,
                                "assets/icons/national_id.svg",
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                setState(() {
                                  _nationalIdShadow = false;
                                });
                                return S.of(context).mustNotEmpty;
                              } else if (value.length != 14) {
                                setState(() {
                                  _nationalIdShadow = false;
                                });
                                return S.of(context).invalidNationalId;
                              }
                              setState(() {
                                _nationalIdShadow = true;
                              });
                              return null;
                            },
                            isShadow: _nationalIdShadow,
                          ),
                    const HeightSpacer(size: 20),
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : TextField2(
                            controller: widget.cubit.nationalityController,
                            required: false,
                            readOnly: widget.cubit.readOnly,
                            hintText: S.of(context).nationality,
                            fillColor: Colorz.white,
                            borderColor: Colorz.primaryColor,
                            radius: 30,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                              child: SvgPicture.asset(
                                color: Colorz.primaryColor,
                                "assets/icons/flag_icon.svg",
                              ),
                            ),
                            isShadow: true,
                          ),
                    const HeightSpacer(size: 20),
                    Divider(
                      thickness: 0.4,
                      color: Colorz.grey,
                    ),
                    const HeightSpacer(size: 20),
                    Text(S.of(context).dateOfBirth, style: TextStyle(color: Colorz.black, fontWeight: FontWeight.w600, fontSize: 18)),
                    const HeightSpacer(size: 10),
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : InkWell(
                            onTap: () async {
                              if (widget.cubit.readOnly == false) {
                                showDatePicker(
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colorz.primaryColor,
                                          onPrimary: Colorz.background,
                                          onSurface: Colors.black,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colorz.primaryColor,
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
                              }
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
                    isLoading
                        ? _buildShimmer(Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.of(context).gender, style: appStyle(context, 18, Colorz.black, FontWeight.w600)),
                              const HeightSpacer(size: 0),
                              GestureDetector(
                                onTap: widget.cubit.readOnly == false
                                    ? () {
                                        setState(() {
                                          widget.cubit.selectedGender = 'Male';
                                        });
                                      }
                                    : null,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(S.of(context).male),
                                  leading: Radio<String>(
                                    fillColor: MaterialStateColor.resolveWith((states) => widget.cubit.gender == false ? Colors.red : Colors.black),
                                    value: 'Male',
                                    groupValue: widget.cubit.selectedGender,
                                    onChanged: widget.cubit.readOnly == false
                                        ? (String? value) {
                                            setState(() {
                                              widget.cubit.selectedGender = value!;
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.cubit.readOnly == false
                                    ? () {
                                        setState(() {
                                          widget.cubit.selectedGender = 'Female';
                                        });
                                      }
                                    : null,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(S.of(context).female),
                                  leading: Radio<String>(
                                    fillColor: MaterialStateColor.resolveWith((states) => widget.cubit.gender == false ? Colors.red : Colors.black),
                                    value: 'Female',
                                    groupValue: widget.cubit.selectedGender,
                                    onChanged: widget.cubit.readOnly == false
                                        ? (String? value) {
                                            setState(() {
                                              widget.cubit.selectedGender = value!;
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                              if (widget.cubit.gender == false)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const HeightSpacer(
                                        size: 10,
                                      ),
                                      Text(
                                        S.of(context).mustNotEmpty,
                                        style: appStyle(context, 14, Colors.red.shade900, FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                  ],
                ),
              ),
            ));
  }
}
