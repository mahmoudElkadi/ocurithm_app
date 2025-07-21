import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/phone_number.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:password_generator/password_generator.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../../../generated/l10n.dart';
import '../../../../../../../../core/Network/shared.dart';
import '../../../../../manager/patient_cubit.dart';
import '../../../../../manager/patient_state.dart';
import 'examinations_view.dart';

class EditPatientViewBody extends StatefulWidget {
  const EditPatientViewBody(
      {super.key,
      required this.cubit,
      required this.formKey,
      required this.id});

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
    await widget.cubit.getData(id: widget.id);
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
    bool isLoading = widget.cubit.patient == null;
    final phoneData =
        PhoneNumberService.parsePhone(widget.cubit.patient?.phone);
    log('${widget.cubit.patient?.phone.toString()}');
    log(phoneData.toString());
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
                        : DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.primaryColor,
                            ),
                            items: widget.cubit.clinics?.clinics,
                            isValid: widget.cubit.chooseClinic,
                            readOnly:
                                CacheHelper.getStringList(key: "capabilities")
                                        .contains("manageCapabilities")
                                    ? widget.cubit.readOnly
                                    : true,
                            validateText: 'Clinic must not be Empty',
                            selectedValue: widget.cubit.selectedClinic?.name,
                            hintText: 'Select Clinic',
                            itemAsString: (item) => item.name.toString(),
                            onItemSelected: (item) {
                              setState(() {
                                if (item != "Not Found") {
                                  widget.cubit.selectedClinic = item;
                                  widget.cubit.selectedBranch = null;
                                  widget.cubit.getBranches();
                                }
                              });
                            },
                            isLoading: widget.cubit.clinics == null,
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
                            selectedValue: widget.cubit.selectedBranch?.name,
                            hintText: 'Select Branch',
                            itemAsString: (item) => item.name.toString(),
                            readOnly: widget.cubit.readOnly,
                            onItemSelected: (item) {
                              setState(() {
                                if (item != "Not Found") {
                                  widget.cubit.chooseBranch = true;
                                  widget.cubit.selectedBranch = item;
                                }
                              });
                            },
                            isLoading: widget.cubit.loading,
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 5.h),
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
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value!)) {
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 5.h),
                              child: SvgPicture.asset(
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
                        : IntlPhoneField(
                            initialValue: phoneData['phoneNumber']!,
                            initialCountryCode: phoneData['countryCode']!,
                            readOnly: widget.cubit.readOnly,
                            enabled: !widget.cubit.readOnly,
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 15.w),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Colorz.grey100, width: 3)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Colorz.grey100, width: 3)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Colorz.primaryColor, width: 1)),
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0)
                                        .copyWith(right: 10),
                                child: SvgPicture.asset(
                                  color: Colorz.primaryColor,
                                  "assets/icons/phone_number.svg",
                                  height: 15,
                                  width: 15,
                                ),
                              ),
                            ),
                            dropdownIconPosition: IconPosition.leading,
                            languageCode: "en",
                            onChanged: (phone) {
                              log(phone.completeNumber);
                              widget.cubit.phoneNumber = phone.completeNumber;
                              setState(() {});
                            },
                            onCountryChanged: (country) {
                              log('Country changed to: ${country.name}');
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
                            controller: widget.cubit.addressController,
                            readOnly: widget.cubit.readOnly,
                            required: false,
                            hintText: S.of(context).address,
                            fillColor: Colorz.white,
                            borderColor: Colorz.primaryColor,
                            radius: 30,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 5.h),
                              child: SvgPicture.asset(
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 5.h),
                              child: SvgPicture.asset(
                                "assets/icons/national_id.svg",
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                setState(() {
                                  _nationalIdShadow = false;
                                });
                                return S.of(context).mustNotEmpty;
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
                        : DropdownItem(
                            radius: 30,
                            color: Colorz.white,
                            isShadow: true,
                            iconData: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colorz.primaryColor,
                            ),
                            readOnly: widget.cubit.readOnly,
                            items: [
                              "🇦🇫 Afghan",
                              "🇦🇱 Albanian",
                              "🇩🇿 Algerian",
                              "🇺🇸 American",
                              "🇦🇩 Andorran",
                              "🇦🇴 Angolan",
                              "🇦🇷 Argentine",
                              "🇦🇲 Armenian",
                              "🇦🇺 Australian",
                              "🇦🇹 Austrian",
                              "🇦🇿 Azerbaijani",
                              "🇧🇭 Bahraini",
                              "🇧🇩 Bangladeshi",
                              "🇧🇾 Belarusian",
                              "🇧🇪 Belgian",
                              "🇧🇯 Beninese",
                              "🇧🇹 Bhutanese",
                              "🇧🇴 Bolivian",
                              "🇧🇦 Bosnian",
                              "🇧🇼 Botswanan",
                              "🇧🇷 Brazilian",
                              "🇬🇧 British",
                              "🇧🇳 Bruneian",
                              "🇧🇬 Bulgarian",
                              "🇧🇫 Burkinabe",
                              "🇲🇲 Burmese",
                              "🇧🇮 Burundian",
                              "🇰🇭 Cambodian",
                              "🇨🇲 Cameroonian",
                              "🇨🇦 Canadian",
                              "🇨🇻 Cape Verdean",
                              "🇨🇫 Central African",
                              "🇹🇩 Chadian",
                              "🇨🇱 Chilean",
                              "🇨🇳 Chinese",
                              "🇨🇴 Colombian",
                              "🇰🇲 Comorian",
                              "🇨🇩 Congolese (DRC)",
                              "🇨🇬 Congolese (Republic)",
                              "🇨🇷 Costa Rican",
                              "🇭🇷 Croatian",
                              "🇨🇺 Cuban",
                              "🇨🇾 Cypriot",
                              "🇨🇿 Czech",
                              "🇩🇰 Danish",
                              "🇩🇯 Djiboutian",
                              "🇩🇴 Dominican",
                              "🇳🇱 Dutch",
                              "🇪🇨 Ecuadorian",
                              "🇪🇬 Egyptian",
                              "🇦🇪 Emirati",
                              "🏴󠁧󠁢󠁥󠁮󠁧󠁿 English",
                              "🇬🇶 Equatorial Guinean",
                              "🇪🇷 Eritrean",
                              "🇪🇪 Estonian",
                              "🇪🇹 Ethiopian",
                              "🇫🇯 Fijian",
                              "🇫🇮 Finnish",
                              "🇫🇷 French",
                              "🇬🇦 Gabonese",
                              "🇬🇲 Gambian",
                              "🇬🇪 Georgian",
                              "🇩🇪 German",
                              "🇬🇭 Ghanaian",
                              "🇬🇷 Greek",
                              "🇬🇩 Grenadian",
                              "🇬🇹 Guatemalan",
                              "🇬🇳 Guinean",
                              "🇬🇼 Guinea-Bissauan",
                              "🇬🇾 Guyanese",
                              "🇭🇹 Haitian",
                              "🇭🇳 Honduran",
                              "🇭🇺 Hungarian",
                              "🇮🇸 Icelandic",
                              "🇮🇳 Indian",
                              "🇮🇩 Indonesian",
                              "🇮🇷 Iranian",
                              "🇮🇶 Iraqi",
                              "🇮🇪 Irish",
                              "🇮🇱 Israeli",
                              "🇮🇹 Italian",
                              "🇨🇮 Ivorian",
                              "🇯🇲 Jamaican",
                              "🇯🇵 Japanese",
                              "🇯🇴 Jordanian",
                              "🇰🇿 Kazakh",
                              "🇰🇪 Kenyan",
                              "🇰🇮 Kiribati",
                              "🇰🇼 Kuwaiti",
                              "🇰🇬 Kyrgyz",
                              "🇱🇦 Lao",
                              "🇱🇻 Latvian",
                              "🇱🇧 Lebanese",
                              "🇱🇸 Lesotho",
                              "🇱🇷 Liberian",
                              "🇱🇾 Libyan",
                              "🇱🇮 Liechtenstein",
                              "🇱🇹 Lithuanian",
                              "🇱🇺 Luxembourgish",
                              "🇲🇰 Macedonian",
                              "🇲🇬 Malagasy",
                              "🇲🇼 Malawian",
                              "🇲🇾 Malaysian",
                              "🇲🇻 Maldivian",
                              "🇲🇱 Malian",
                              "🇲🇹 Maltese",
                              "🇲🇭 Marshallese",
                              "🇲🇷 Mauritanian",
                              "🇲🇺 Mauritian",
                              "🇲🇽 Mexican",
                              "🇫🇲 Micronesian",
                              "🇲🇩 Moldovan",
                              "🇲🇨 Monegasque",
                              "🇲🇳 Mongolian",
                              "🇲🇪 Montenegrin",
                              "🇲🇦 Moroccan",
                              "🇲🇿 Mozambican",
                              "🇳🇦 Namibian",
                              "🇳🇷 Nauruan",
                              "🇳🇵 Nepalese",
                              "🇳🇿 New Zealander",
                              "🇳🇮 Nicaraguan",
                              "🇳🇪 Nigerien",
                              "🇳🇬 Nigerian",
                              "🇰🇵 North Korean",
                              "🇳🇴 Norwegian",
                              "🇴🇲 Omani",
                              "🇵🇰 Pakistani",
                              "🇵🇼 Palauan",
                              "🇵🇸 Palestinian",
                              "🇵🇦 Panamanian",
                              "🇵🇬 Papua New Guinean",
                              "🇵🇾 Paraguayan",
                              "🇵🇪 Peruvian",
                              "🇵🇭 Philippine",
                              "🇵🇱 Polish",
                              "🇵🇹 Portuguese",
                              "🇶🇦 Qatari",
                              "🇷🇴 Romanian",
                              "🇷🇺 Russian",
                              "🇷🇼 Rwandan",
                              "🇰🇳 Kittitian and Nevisian",
                              "🇱🇨 Saint Lucian",
                              "🇻🇨 Saint Vincentian",
                              "🇼🇸 Samoan",
                              "🇸🇲 San Marinese",
                              "🇸🇹 Sao Tomean",
                              "🇸🇦 Saudi",
                              "🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scottish",
                              "🇸🇳 Senegalese",
                              "🇷🇸 Serbian",
                              "🇸🇨 Seychellois",
                              "🇸🇱 Sierra Leonean",
                              "🇸🇬 Singaporean",
                              "🇸🇰 Slovak",
                              "🇸🇮 Slovenian",
                              "🇸🇧 Solomon Islander",
                              "🇸🇴 Somali",
                              "🇿🇦 South African",
                              "🇰🇷 South Korean",
                              "🇸🇸 South Sudanese",
                              "🇪🇸 Spanish",
                              "🇱🇰 Sri Lankan",
                              "🇸🇩 Sudanese",
                              "🇸🇷 Surinamese",
                              "🇸🇿 Swazi",
                              "🇸🇪 Swedish",
                              "🇨🇭 Swiss",
                              "🇸🇾 Syrian",
                              "🇹🇼 Taiwanese",
                              "🇹🇯 Tajik",
                              "🇹🇿 Tanzanian",
                              "🇹🇭 Thai",
                              "🇹🇱 Timorese",
                              "🇹🇬 Togolese",
                              "🇹🇴 Tongan",
                              "🇹🇹 Trinidadian",
                              "🇹🇳 Tunisian",
                              "🇹🇷 Turkish",
                              "🇹🇲 Turkmen",
                              "🇹🇻 Tuvaluan",
                              "🇺🇬 Ugandan",
                              "🇺🇦 Ukrainian",
                              "🇺🇾 Uruguayan",
                              "🇺🇿 Uzbek",
                              "🇻🇺 Vanuatuan",
                              "🇻🇦 Vatican",
                              "🇻🇪 Venezuelan",
                              "🇻🇳 Vietnamese",
                              "🏴󠁧󠁢󠁷󠁬󠁳󠁿 Welsh",
                              "🇾🇪 Yemeni",
                              "🇿🇲 Zambian",
                              "🇿🇼 Zimbabwean",
                              "🌍 Other",
                            ],
                            isValid: widget.cubit.nationality,
                            validateText: 'Nationality must not be Empty',
                            selectedValue: widget.cubit.selectedNationality,
                            hintText: 'Select Nationality',
                            itemAsString: (item) => item.toString(),
                            onItemSelected: (item) {
                              setState(() {
                                if (item != "Not Found") {
                                  widget.cubit.selectedNationality = item;
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
                        : Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colorz.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    widget.cubit.patient?.serialNumber ?? "N/A",
                                    style: TextStyle(
                                        color: Colorz.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16)),
                                SvgPicture.asset("assets/icons/password.svg"),
                              ],
                            )),
                    const HeightSpacer(size: 20),
                    Divider(
                      thickness: 0.4,
                      color: Colorz.grey,
                    ),
                    const HeightSpacer(size: 20),
                    Text(S.of(context).dateOfBirth,
                        style: TextStyle(
                            color: Colorz.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
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
                                            foregroundColor:
                                                Colorz.primaryColor,
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
                                    setState(() {});
                                  }
                                });
                              }
                            },
                            child: Ink(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: HexColor("#E7EDEF"),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: widget.cubit.picDate == false
                                          ? Colors.redAccent
                                          : Colors.transparent,
                                      width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          widget.cubit.date != null
                                              ? "${widget.cubit.date!.day}"
                                              : S.of(context).dd,
                                          style: appStyle(context, 18,
                                              Colorz.black, FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colorz.white,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          widget.cubit.date != null
                                              ? "${widget.cubit.date!.month}"
                                              : S.of(context).mm,
                                          style: appStyle(context, 18,
                                              Colorz.black, FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colorz.white,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          widget.cubit.date != null
                                              ? "${widget.cubit.date!.year}"
                                              : S.of(context).yy,
                                          style: appStyle(context, 18,
                                              Colorz.black, FontWeight.w600),
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
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w400),
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
                              Text(S.of(context).gender,
                                  style: appStyle(context, 18, Colorz.black,
                                      FontWeight.w600)),
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
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => widget.cubit.gender == false
                                            ? Colors.red
                                            : Colors.black),
                                    value: 'Male',
                                    groupValue: widget.cubit.selectedGender,
                                    onChanged: widget.cubit.readOnly == false
                                        ? (String? value) {
                                            setState(() {
                                              widget.cubit.selectedGender =
                                                  value!;
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
                                          widget.cubit.selectedGender =
                                              'Female';
                                        });
                                      }
                                    : null,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(S.of(context).female),
                                  leading: Radio<String>(
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => widget.cubit.gender == false
                                            ? Colors.red
                                            : Colors.black),
                                    value: 'Female',
                                    groupValue: widget.cubit.selectedGender,
                                    onChanged: widget.cubit.readOnly == false
                                        ? (String? value) {
                                            setState(() {
                                              widget.cubit.selectedGender =
                                                  value!;
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                              if (widget.cubit.gender == false)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const HeightSpacer(
                                        size: 10,
                                      ),
                                      Text(
                                        S.of(context).mustNotEmpty,
                                        style: appStyle(
                                            context,
                                            14,
                                            Colors.red.shade900,
                                            FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              Divider(
                                thickness: 0.4,
                                color: Colorz.grey,
                              ),
                              widget.cubit.patientExamination == null
                                  ? _buildShimmer(Container(
                                      width: MediaQuery.sizeOf(context).width,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                    ))
                                  : ExaminationListView(
                                      examinations: widget
                                              .cubit
                                              .patientExamination
                                              ?.examinations
                                              ?.examinations ??
                                          [],
                                      cubit: widget.cubit,
                                    )
                            ],
                          )
                  ],
                ),
              ),
            ));
  }
}
