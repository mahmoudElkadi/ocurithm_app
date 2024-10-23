import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/custom_freeze_loading.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';
import 'package:password_generator/password_generator.dart';

import '../../../../../../../core/widgets/DropdownPackage.dart';
import '../../../../../../../generated/l10n.dart';
import '../../manger/Add Receptionist Cubit/add_receptionist_cubit.dart';
import '../../manger/Add Receptionist Cubit/add_recptionist_state.dart';

class CreateReceptionistViewBody extends StatefulWidget {
  const CreateReceptionistViewBody({super.key, this.nationalId, this.readOnly});
  final String? nationalId;
  final bool? readOnly;

  @override
  State<CreateReceptionistViewBody> createState() => _CreateReceptionistViewBodyState();
}

class _CreateReceptionistViewBodyState extends State<CreateReceptionistViewBody> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
  @override
  Widget build(BuildContext context) {
    final cubit = CreateReceptionistCubit.get(context);
    return BlocBuilder<CreateReceptionistCubit, CreateReceptionistState>(
        builder: (context, state) => Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ProfileImagePicker(
                        initialImageUrl: widget.readOnly == true ? profileImageUrl : null,
                        onImageUploaded: (String url) {
                          setState(() {
                            profileImageUrl = url;
                          });
                        },
                      ),
                    ),
                    const HeightSpacer(size: 20),
                    TextField2(
                      controller: nameController,
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
                      // borderMain: CreateReceptionistCubit.get(context).textField == true ? Colorz.blue : null,
                      controller: phoneNumberController,
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
                            // borderMain: CreateReceptionistCubit.get(context).textField == true ? Colorz.blue : null,
                            controller: passwordController,
                            required: true,
                            hintText: S.of(context).password,
                            fillColor: Colorz.white,
                            borderColor: Colorz.activeIcon,
                            radius: 30,
                            isPassword: CreateReceptionistCubit.get(context).obscureText,
                            suffixIcon: CreateReceptionistCubit.get(context).obscureText == false
                                ? IconButton(
                                    onPressed: () {
                                      CreateReceptionistCubit.get(context).obscureText = !CreateReceptionistCubit.get(context).obscureText;
                                    },
                                    icon: Icon(Icons.visibility),
                                    color: Colorz.blue,
                                  )
                                : IconButton(
                                    onPressed: () {
                                      CreateReceptionistCubit.get(context).obscureText = !CreateReceptionistCubit.get(context).obscureText;
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
                                      passwordController.text = generatedPassword;
                                    });
                                  } else if (entropy >= 60) {
                                    log('Very Strong.');
                                    setState(() {
                                      passwordController.text = generatedPassword;
                                    });
                                  } else if (entropy >= 36) {
                                    setState(() {
                                      passwordController.text = generatedPassword;
                                    });
                                    log('Strong.');
                                  } else if (entropy >= 28) {
                                    setState(() {
                                      passwordController.text = generatedPassword;
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
                            CreateReceptionistCubit.get(context).date = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                            );
                            setState(() {
                              log(CreateReceptionistCubit.get(context).date.toString());
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
                            border: Border.all(
                                color: CreateReceptionistCubit.get(context).picDate == false ? Colors.redAccent : Colors.transparent, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    CreateReceptionistCubit.get(context).date != null
                                        ? "${CreateReceptionistCubit.get(context).date!.day}"
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
                                    CreateReceptionistCubit.get(context).date != null
                                        ? "${CreateReceptionistCubit.get(context).date!.month}"
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
                                    CreateReceptionistCubit.get(context).date != null
                                        ? "${CreateReceptionistCubit.get(context).date!.year}"
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
                    if (CreateReceptionistCubit.get(context).picDate == false)
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
                    Text(S.of(context).gender, style: appStyle(context, 18, Colorz.black, FontWeight.w600)),
                    const HeightSpacer(size: 0),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          CreateReceptionistCubit.get(context).selectedGender = 'male';
                        });
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(S.of(context).male),
                        leading: Radio<String>(
                          fillColor: MaterialStateColor.resolveWith(
                              (states) => CreateReceptionistCubit.get(context).gender == false ? Colors.red : Colors.black),
                          value: 'male',
                          groupValue: CreateReceptionistCubit.get(context).selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              CreateReceptionistCubit.get(context).selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          CreateReceptionistCubit.get(context).selectedGender = 'female';
                        });
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(S.of(context).female),
                        leading: Radio<String>(
                          fillColor: MaterialStateColor.resolveWith(
                              (states) => CreateReceptionistCubit.get(context).gender == false ? Colors.red : Colors.black),
                          value: 'female',
                          groupValue: CreateReceptionistCubit.get(context).selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              CreateReceptionistCubit.get(context).selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    if (CreateReceptionistCubit.get(context).gender == false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HeightSpacer(
                              size: 10,
                            ),
                            Text(
                              S.of(context).mustGender,
                              style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    // const HeightSpacer(size: 20),
                    // DropdownItem(
                    //   radius: 30,
                    //   color: Colorz.white,
                    //   isShadow: true,
                    //   iconData: Icon(
                    //     Icons.arrow_drop_down_circle,
                    //     color: Colorz.blue,
                    //   ),
                    //   items: const ['Male', 'Female'],
                    //   isValid: cubit.chooseBranch,
                    //   validateText: S.of(context).mustBranch,
                    //   selectedValue: cubit.selectedBranch,
                    //   hintText: 'Select Branch',
                    //   itemAsString: (item) => item.toString(),
                    //   onItemSelected: (item) {
                    //     setState(() {
                    //       if (item != "Not Found") {
                    //         cubit.chooseBranch = true;
                    //         cubit.selectedBranch = "$item sds";
                    //         log(cubit.selectedBranch.toString());
                    //       }
                    //     });
                    //   },
                    //   isLoading: false,
                    // ),
                    const HeightSpacer(size: 15),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          log("message");
                          CreateReceptionistCubit.get(context).validateFirstPage();
                          log("message1");
                          log(CreateReceptionistCubit.get(context).isValidate.toString());

                          setState(() {});
                          if (formKey.currentState!.validate() && CreateReceptionistCubit.get(context).isValidate) {
                            customLoading(context, "");
                            CreateReceptionistCubit.get(context).createReceptionist(
                              context: context,
                              fullName: nameController.text,
                              password: passwordController.text,
                              phone: phoneNumberController.text,
                              gender: CreateReceptionistCubit.get(context).selectedGender!,
                              dateOfBirth: CreateReceptionistCubit.get(context).date.toString(),
                              branchId: CreateReceptionistCubit.get(context).branchId.toString(),
                            );
                          }
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Ink(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  HexColor("#0E3366"),
                                  HexColor("#174784"),
                                  HexColor("#174784"),
                                  HexColor("#174784"),
                                  HexColor("#3E86DD"),
                                ],
                              ),
                            ),
                            child: Text(
                              S.of(context).addReceptionist,
                              style: appStyle(context, 18, Colors.white, FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}

class ProfileImagePicker extends StatefulWidget {
  final Function(String) onImageUploaded;
  final String? initialImageUrl;

  const ProfileImagePicker({
    Key? key,
    required this.onImageUploaded,
    this.initialImageUrl,
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final url = await CloudinaryService.uploadImage(_imageFile!);

      if (url != null) {
        widget.onImageUploaded(url);
      } else {
        _showError('Failed to upload image');
      }
    } catch (e) {
      _showError('Error uploading image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _uploadImage,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Check file size
        final file = File(pickedFile.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 10) {
          _showError('Image size should be less than 10MB');
          return;
        }

        setState(() {
          _imageFile = file;
        });
        await _uploadImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _isUploading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ClipOval(
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : widget.initialImageUrl != null
                          ? Image.network(
                              widget.initialImageUrl!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 60, color: Colors.grey),
                            )
                          : Icon(Icons.person, size: 60, color: Colors.grey),
                ),
        ),
        if (!_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colorz.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Select Image Source',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black.withOpacity(0.8),
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.photo,
                  color: CupertinoColors.activeBlue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.camera,
                  color: CupertinoColors.activeBlue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Take a Photo',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: CupertinoColors.destructiveRed,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class CloudinaryService {
  // Your Cloudinary credentials
  static const String cloudName = 'dxsrhu3ku';
  static const String uploadPreset = 'ocurithm';
  static const String apiKey = 'your-api-key'; // Optional if using unsigned upload

  // Base URL for Cloudinary API
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName';

  // Upload image to Cloudinary
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Create upload URL
      final url = Uri.parse('$_baseUrl/image/upload');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add fields
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'public';
      request.fields['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

      // Add the file
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        log(jsonResponse['secure_url']);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
