import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:password_generator/password_generator.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../../generated/l10n.dart';
import '../../../../../../../Receptionist/presentation/views/Add Receptionist/presentation/view/widgets/add_receptionist_view_body.dart';
import '../../../../../../../Receptionist/presentation/views/Receptionist Details/presentation/view/widgets/capabilities_section.dart';
import '../../../../../manager/doctor_cubit.dart';
import '../../../../../manager/doctor_state.dart';
import 'branch_detials.dart';

class EditDoctorViewBody extends StatefulWidget {
  const EditDoctorViewBody({super.key, required this.cubit, required this.formKey, required this.id});
  final DoctorCubit cubit;
  final GlobalKey<FormState> formKey;
  final String id;

  @override
  State<EditDoctorViewBody> createState() => _EditDoctorViewBodyState();
}

class _EditDoctorViewBodyState extends State<EditDoctorViewBody> {
  bool _isNameShadow = true;
  bool _isQualificationShadow = true;
  bool _isPhoneShadow = true;

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
    fetchDoctorData();
  }

  fetchDoctorData() async {
    await widget.cubit.getDoctor(id: widget.id);

    if (widget.cubit.doctor != null) {
      widget.cubit.imageUrl = widget.cubit.doctor?.image;
      widget.cubit.nameController.text = widget.cubit.doctor?.name ?? '';
      widget.cubit.phoneNumberController.text = widget.cubit.doctor?.phone ?? "";
      widget.cubit.passwordController.text = widget.cubit.doctor?.password ?? "";
      widget.cubit.date = widget.cubit.doctor?.birthDate;
      widget.cubit.selectedClinic = widget.cubit.doctor?.clinic;
      widget.cubit.qualificationController.text = widget.cubit.doctor?.qualifications ?? "";
    }
    await widget.cubit.getCapabilities();
  }

  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.cubit.doctor == null;

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
                      child: isLoading
                          ? _buildShimmer(Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ))
                          : ProfileImagePicker(
                              readOnly: widget.cubit.readOnly,
                              onDelete: () {
                                widget.cubit.imageUrl = null;
                                setState(() {});
                              },
                              initialImageUrl: widget.cubit.imageUrl,
                              onImageUploaded: (String url) {
                                setState(() {
                                  widget.cubit.imageUrl = url;
                                });
                              },
                            ),
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
                    if (CacheHelper.getStringList(key: "capabilities").contains("manageCapabilities"))
                      isLoading
                          ? _buildShimmer(Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                              ),
                            ))
                          : Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: DropdownItem(
                                radius: 30,
                                color: Colorz.white,
                                isShadow: true,
                                iconData: Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Colorz.primaryColor,
                                ),
                                readOnly: widget.cubit.readOnly,
                                items: widget.cubit.clinics?.clinics,
                                selectedValue: widget.cubit.selectedClinic?.name,
                                hintText: 'Select Clinic',
                                isValid: widget.cubit.chooseClinic,
                                validateText: 'Clinic must not be Empty',
                                itemAsString: (item) => item.name.toString(),
                                onItemSelected: (item) {
                                  setState(() {
                                    if (item != "Not Found") {
                                      widget.cubit.selectedClinic = item;
                                    }
                                  });
                                },
                                isLoading: widget.cubit.clinics == null,
                              ),
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
                        : CapabilitiesSection(
                            capabilities: widget.cubit.capabilities?.capabilities ?? [],
                            readOnly: widget.cubit.readOnly,
                            initialSelectedCapabilities: widget.cubit.doctor?.capabilities ?? [],
                            onSelectionChanged: (newSelection) {
                              widget.cubit.capabilitiesList = newSelection.map((e) => e.id).toList();
                              log(widget.cubit.capabilitiesList.toString());
                              setState(() {});
                            },
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
                        : MultilineTextInput(
                            hint: 'Enter Doctor Qualification',
                            maxHeight: 200,
                            readOnly: widget.cubit.readOnly,
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
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now().subtract(Duration(days: 6600)),
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
                    Divider(
                      thickness: 0.4,
                      color: Colorz.grey,
                    ),
                    const HeightSpacer(size: 20),
                    Text("Branches", style: TextStyle(color: Colorz.black, fontWeight: FontWeight.w600, fontSize: 18)),
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
                        : DoctorBranchesView(
                            branches: widget.cubit.doctor!.branches!,
                            cubit: widget.cubit,
                            doctorId: widget.id,
                          )
                  ],
                ),
              ),
            ));
  }
}
