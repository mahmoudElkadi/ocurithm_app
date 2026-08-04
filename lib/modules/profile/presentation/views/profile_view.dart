import 'dart:convert';
import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import '../../../../Main/presentation/manger/main_cubit.dart';
import '../../../../core/utils/app_style.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/services_locator.dart';
import '../../data/models/profile_models.dart';
import '../manager/get_profile_cubit/get_profile_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ocurithm/core/Network/shared.dart';
import '../../../../modules/Login/data/model/login_response.dart';
import '../../../../core/utils/snackbar_service.dart';
import '../manager/profile_actions_cubit/profile_actions_cubit.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                sl<GetProfileCubit>()..add(FetchProfileEvent())),
        BlocProvider(create: (context) => sl<ProfileActionsCubit>()),
      ],
      child: const ProfileViewBody(),
    );
  }
}

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor =
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: appStyle(context, 20, textColor, FontWeight.w600),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<ProfileActionsCubit, ProfileActionsState>(
        listener: (context, state) {
          if (state.isSuccess) {
            SnackbarService.showSuccess(
              context,
              message: state.successMessage ?? "Operation successful",
            );
            // Refresh profile data if update was successful
            if (state.actionType == ProfileActionType.updateProfile &&
                state.profile != null) {
              // Update local cache for drawer
              final currentUser = CacheHelper.getUser("user");
              if (currentUser != null) {
                final displayImage = (state.profile!.image != null &&
                        state.profile!.image!.isNotEmpty)
                    ? state.profile!.image
                    : (state.profile!.metadata?.image != null &&
                            state.profile!.metadata!.image is String &&
                            state.profile!.metadata!.image.isNotEmpty)
                        ? state.profile!.metadata!.image as String
                        : null;

                final updatedUser = User(
                  id: state.profile!.id,
                  name: state.profile!.name,
                  userType: state.profile!.userType,
                  clinic: state.profile!.clinic,
                  capabilities: state.profile!.capabilities,
                  image: displayImage,
                );
                CacheHelper.saveUser("user", updatedUser);
              }

              context
                  .read<GetProfileCubit>()
                  .add(UpdateProfileSuccessEvent(state.profile!));
            }
            context.read<ProfileActionsCubit>().add(ResetProfileActionsEvent());
          } else if (state.isError) {
            SnackbarService.showError(
              context,
              message: state.errorMessage ?? "Operation failed",
            );
            context.read<ProfileActionsCubit>().add(ResetProfileActionsEvent());
          }
        },
        child: CustomMaterialIndicator(
          onRefresh: () async {
            context.read<GetProfileCubit>().add(FetchProfileEvent());
          },
          indicatorBuilder:
              (BuildContext context, IndicatorController controller) {
            return const Image(image: AssetImage("assets/icons/logo.png"));
          },
          child: BlocBuilder<GetProfileCubit, GetProfileState>(
            builder: (context, state) {
              if (state.isLoading) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _buildProfileLoadingState(context),
                );
              } else if (state.isError) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.errorMessage ?? "Something went wrong",
                              style: appStyle(
                                  context, 16, textColor, FontWeight.w500)),
                          SizedBox(height: 10.h),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colorz.primaryColor),
                            onPressed: () => context
                                .read<GetProfileCubit>()
                                .add(FetchProfileEvent()),
                            child: const Text("Retry"),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state.noConnection) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: NoInternet(
                      onPressed: () => context
                          .read<GetProfileCubit>()
                          .add(FetchProfileEvent()),
                    ),
                  ),
                );
              } else if (state.profile != null) {
                final profile = state.profile!;
                return SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Header
                      _buildProfileHeader(
                          context, profile, cardColor, textColor, subTextColor),
                      SizedBox(height: 25.h),

                      // Info Cards
                      _buildSectionTitle(
                          context, "Personal Information", textColor),
                      SizedBox(height: 10.h),
                      _buildInfoCard(context, profile, cardColor, textColor,
                          subTextColor, isDark),

                      SizedBox(height: 25.h),
                      _buildSectionTitle(
                          context, "Account Settings", textColor),
                      SizedBox(height: 10.h),
                      _buildSettingsCard(
                          context, profile, cardColor, textColor, isDark),

                      SizedBox(height: 25.h),
                      _buildSectionTitle(
                          context, "Organization Info", textColor),
                      SizedBox(height: 10.h),
                      _buildOrganizationCard(context, profile, cardColor,
                          textColor, subTextColor, isDark),

                      SizedBox(height: 40.h),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile,
      Color cardColor, Color textColor, Color subTextColor) {
    final displayImage = (profile.image != null && profile.image!.isNotEmpty)
        ? profile.image
        : (profile.metadata?.image != null &&
                profile.metadata!.image is String &&
                profile.metadata!.image.isNotEmpty)
            ? profile.metadata!.image as String
            : null;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colorz.primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: Colorz.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: Colorz.grey200,
                backgroundImage:
                    (displayImage != null) ? NetworkImage(displayImage) : null,
                child: (displayImage != null)
                    ? null
                    : Text(
                        profile.name?.substring(0, 1).toUpperCase() ?? "U",
                        style: appStyle(
                            context, 40, Colorz.primaryColor, FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.name ?? "User Name",
              style: appStyle(context, 22, textColor, FontWeight.bold),
            ),
            if (profile.metadata?.isConsultant == true) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Text(
                  "Consultant",
                  style: appStyle(
                      context, 10, Colors.amber[800]!, FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 5.h),
        Text(
          profile.userType?.toUpperCase() ?? "USER",
          style: appStyle(context, 14, Colorz.primaryColor, FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style:
            appStyle(context, 16, textColor.withValues(alpha: 0.8), FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ProfileModel profile,
      Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    final dividerColor =
        isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.4);
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
        border: isDark ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.person_outline, "Username",
              profile.username ?? "-", textColor, subTextColor),
          Divider(color: dividerColor, height: 30.h),
          _buildInfoRow(context, Icons.phone_outlined, "Phone",
              profile.phone?.toString() ?? "-", textColor, subTextColor),
          Divider(color: dividerColor, height: 30.h),
          _buildInfoRow(context, Icons.email_outlined, "Email",
              profile.email ?? "-", textColor, subTextColor),
          if (profile.metadata?.reminder != null) ...[
            Divider(color: dividerColor, height: 30.h),
            _buildInfoRow(
                context,
                Icons.notification_important_outlined,
                "Reminder",
                profile.metadata!.reminder!,
                textColor,
                subTextColor),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label,
      String value, Color textColor, Color subTextColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Colorz.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: Colorz.primaryColor, size: 20.sp),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      appStyle(context, 12, subTextColor, FontWeight.normal)),
              SizedBox(height: 2.h),
              Text(value,
                  style: appStyle(context, 15, textColor, FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, ProfileModel profile,
      Color cardColor, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
        border: isDark ? null : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            Icons.edit_note,
            "Edit Profile Details",
            textColor,
            isDark,
            onTap: () => _showEditProfileDialog(context, profile),
          ),
          Divider(
              color: isDark
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.3),
              height: 1),
          _buildSettingTile(
            context,
            Icons.lock_outline,
            "Change Password",
            textColor,
            isDark,
            onTap: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(BuildContext context, ProfileModel profile,
      Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    final dividerColor =
        isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.4);
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
        border: isDark ? null : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          if (profile.clinic != null)
            _buildInfoRow(context, Icons.local_hospital_outlined, "Clinic",
                profile.clinic!.name ?? "-", textColor, subTextColor),
          if (profile.clinic != null && (profile.branch?.name != null))
            Divider(color: dividerColor, height: 30.h),
          if (profile.branch?.name != null)
            _buildInfoRow(
                context,
                Icons.location_on_outlined,
                "Branch",
                 profile.branch!.name.toString(),
                textColor,
                subTextColor), // branch is dynamic in model
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title,
      Color textColor, bool isDark,
      {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isDark ? Colorz.grey200.withValues(alpha: 0.1) : Colorz.grey200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: isDark ? Colors.white70 : Colors.black54, size: 20.sp),
      ),
      title:
          Text(title, style: appStyle(context, 15, textColor, FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileModel profile) {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    final phoneController = TextEditingController(text: profile.phone?.toString() ?? '');
    final displayImage = (profile.image != null && profile.image!.isNotEmpty)
        ? profile.image
        : (profile.metadata?.image != null &&
                profile.metadata!.image is String &&
                profile.metadata!.image.isNotEmpty)
            ? profile.metadata!.image as String
            : null;
    String? currentImageUrl = displayImage;
    bool isImageRemoved = false;
    final formKey = GlobalKey<FormState>();

    final cubit = context.read<ProfileActionsCubit>();
    Get.bottomSheet(
      BlocProvider.value(
        value: cubit,
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: StatefulBuilder(builder: (context, setState) {
                final bool imageChanged =
                    currentImageUrl != profile.image || isImageRemoved;
                bool hasDataToUpdate = nameController.text != profile.name ||
                    emailController.text != profile.email ||
                    (phoneController.text != profile.phone?.toString()) ||
                    imageChanged;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text("Edit Profile",
                        style: appStyle(
                            context,
                            20,
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            FontWeight.bold)),
                    SizedBox(height: 20.h),
                    ProfileImagePicker(
                      initialImageUrl: currentImageUrl,
                      onImageUploaded: (url) {
                        setState(() {
                          currentImageUrl = url;
                          isImageRemoved = false;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          currentImageUrl = null;
                          isImageRemoved = true;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(
                        context, nameController, "Full Name", Icons.person,
                        onChanged: (_) => setState(() {})),
                    SizedBox(height: 15.h),
                    _buildTextField(
                        context, emailController, "Email", Icons.email,
                        isEmail: true, onChanged: (_) => setState(() {})),
                    SizedBox(height: 15.h),
                    _buildPhoneField(context, phoneController),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: double.infinity,
                      child:
                          BlocBuilder<ProfileActionsCubit, ProfileActionsState>(
                        builder: (context, state) {
                          if (state.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ElevatedButton(
                            onPressed: (hasDataToUpdate && !state.isLoading)
                                ? () {
                                    if (formKey.currentState!.validate()) {
                                      cubit.add(
                                        UpdateProfileEvent(
                                          name: nameController.text !=
                                                  profile.name
                                              ? nameController.text
                                              : null,
                                          email: emailController.text !=
                                                  profile.email
                                              ? emailController.text
                                              : null,
                                          phone: phoneController.text !=
                                                  profile.phone?.toString()
                                              ? phoneController.text
                                              : null,
                                          image:
                                              (imageChanged && !isImageRemoved)
                                                  ? currentImageUrl
                                                  : null,
                                          removeImage: isImageRemoved,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colorz.primaryColor,
                              disabledBackgroundColor: Colorz.grey200,
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r)),
                            ),
                            child: Text("Save Changes",
                                style: appStyle(context, 16, Colors.white,
                                    FontWeight.w600)),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final cubit = context.read<ProfileActionsCubit>();
    final mainCubit = context.read<MainCubit>();
    Get.bottomSheet(
      BlocProvider.value(
        value: cubit,
        child: BlocListener<ProfileActionsCubit, ProfileActionsState>(
          listener: (context, state) {
            if (state.isSuccess &&
                state.actionType == ProfileActionType.changePassword) {
              Navigator.pop(context);
              // Matches web (ProfilePage.tsx): a password change invalidates
              // every session, including this one, so force a fresh login.
              // Get.snackbar (not SnackbarService) because it floats on GetX's
              // own overlay and survives the Get.offAll navigation below —
              // a ScaffoldMessenger-based snackbar would die with this screen.
              Get.snackbar(
                "Password changed",
                "Please log in again for security.",
                colorText: Colors.white,
                backgroundColor: Colorz.primaryColor,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 4),
              );
              mainCubit.logOut(everywhere: true);
            }
          },
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text("Change Password",
                        style: appStyle(
                            context,
                            20,
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            FontWeight.bold)),
                    SizedBox(height: 20.h),
                    _buildTextField(context, currentPassController,
                        "Current Password", Icons.lock_outline,
                        isPassword: true, isRequired: true),
                    SizedBox(height: 15.h),
                    _buildTextField(
                        context, newPassController, "New Password", Icons.lock,
                        isPassword: true, isRequired: true),
                    SizedBox(height: 15.h),
                    _buildTextField(context, confirmPassController,
                        "Confirm Password", Icons.lock_reset,
                        isPassword: true, isRequired: true, validator: (val) {
                      if (val != newPassController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    }),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: double.infinity,
                      child:
                          BlocBuilder<ProfileActionsCubit, ProfileActionsState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isLoading
                                ? () {}
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      cubit.add(
                                        ChangePasswordEvent(
                                          currentPassword:
                                              currentPassController.text,
                                          newPassword: newPassController.text,
                                          confirmPassword:
                                              confirmPassController.text,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colorz.primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r)),
                            ),
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text("Change Password",
                                    style: appStyle(context, 16, Colors.white,
                                        FontWeight.w600)),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: appStyle(
          context,
          14,
          Theme.of(context).brightness == Brightness.dark
              ? Colors.grey
              : Colors.grey,
          FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, "Phone Number"),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: appStyle(context, 15, isDark ? Colors.white : Colors.black,
              FontWeight.normal),
          onChanged: (_) {},
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
              return "Invalid phone number";
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Phone Number",
            hintStyle: appStyle(context, 14, isDark ? Colors.grey : Colors.grey,
                FontWeight.normal),
            prefixIcon: Icon(Icons.phone_iphone, color: Colorz.primaryColor),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colorz.grey.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colorz.grey.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colorz.primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller,
      String label, IconData icon,
      {bool isPassword = false,
      bool isEmail = false,
      bool isRequired = false,
      void Function(String)? onChanged,
      String? Function(String?)? validator}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, label),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: appStyle(context, 15, isDark ? Colors.white : Colors.black,
              FontWeight.normal),
          onChanged: onChanged,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return "$label cannot be empty";
            }
            if (isEmail &&
                value != null &&
                value.isNotEmpty &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return "Invalid email address";
            }
            if (validator != null) {
              return validator(value);
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: label,
            hintStyle: appStyle(context, 14, isDark ? Colors.grey : Colors.grey,
                FontWeight.normal),
            prefixIcon: Icon(icon, color: Colorz.primaryColor),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colorz.grey.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colorz.grey.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: Colorz.primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }

  Widget _buildProfileLoadingState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Header Shimmer
          Column(
            children: [
              _buildShimmer(
                context,
                Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              _buildShimmer(
                context,
                Container(
                  width: 150.w,
                  height: 24.h,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5.h),
              _buildShimmer(
                context,
                Container(
                  width: 80.w,
                  height: 16.h,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5.h),
              _buildShimmer(
                context,
                Container(
                  width: 180.w,
                  height: 16.h,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),

          // Info Cards Shimmer
          Align(
            alignment: Alignment.centerLeft,
            child: _buildShimmer(
              context,
              Container(
                width: 150.w,
                height: 20.h,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _buildShimmer(
            context,
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),

          SizedBox(height: 25.h),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildShimmer(
              context,
              Container(
                width: 150.w,
                height: 20.h,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _buildShimmer(
            context,
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),

          SizedBox(height: 25.h),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildShimmer(
              context,
              Container(
                width: 150.w,
                height: 20.h,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _buildShimmer(
            context,
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// Profile Image Picker Widget (reused from Receptionist)
class ProfileImagePicker extends StatefulWidget {
  final Function(String) onImageUploaded;
  final String? initialImageUrl;
  final bool? readOnly;
  final Function() onDelete;

  const ProfileImagePicker({
    super.key,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.readOnly = false,
    required this.onDelete,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isImageDeleted = false;

  void _handleDelete() {
    setState(() {
      _imageFile = null;
      _isImageDeleted = true;
    });
    widget.onDelete();
  }

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
    SnackbarService.showError(
      context,
      message: message,
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
        final file = File(pickedFile.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 10) {
          _showError('Image size should be less than 10MB');
          return;
        }

        setState(() {
          _imageFile = file;
          _isImageDeleted = false;
        });
        await _uploadImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
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
                      CircularProgressIndicator(color: theme.primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
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
                      : (!_isImageDeleted && widget.initialImageUrl != null)
                          ? Image.network(
                              widget.initialImageUrl!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person,
                                      size: 60, color: Colors.grey),
                            )
                          : const Icon(Icons.person,
                              size: 60, color: Colors.grey),
                ),
        ),
        if (!_isUploading && widget.readOnly != true)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImageSourceDialog(_handleDelete),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colorz.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
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

  void _showImageSourceDialog(Function() onDelete) {
    final hasExistingImage = widget.initialImageUrl != null && !_isImageDeleted;
    
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current image preview if exists
              if (hasExistingImage) ...[
                const SizedBox(height: 16),
                Text(
                  'Current Photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipOval(
                    child: Image.network(
                      widget.initialImageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey5.resolveFrom(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.person,
                          size: 50,
                          color: CupertinoColors.systemGrey.resolveFrom(context),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: CupertinoColors.separator.resolveFrom(context),
                  height: 1,
                ),
              ],
              CupertinoActionSheet(
                title: Text(hasExistingImage ? 'Change Photo' : 'Select Image Source'),
                actions: <CupertinoActionSheetAction>[
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.photo, color: CupertinoColors.activeBlue),
                        SizedBox(width: 8),
                        Text('Choose from Gallery'),
                      ],
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.camera, color: CupertinoColors.activeBlue),
                        SizedBox(width: 8),
                        Text('Take a Photo'),
                      ],
                    ),
                  ),
                  if (hasExistingImage)
                    CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed),
                          SizedBox(width: 8),
                          Text('Delete Photo'),
                        ],
                      ),
                    ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CloudinaryService {
  static const String cloudName = 'dxsrhu3ku';
  static const String uploadPreset = 'ocurithm';
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('$_baseUrl/image/upload');
      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'public';
      request.fields['timestamp'] =
          DateTime.now().millisecondsSinceEpoch.toString();

      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }
}
