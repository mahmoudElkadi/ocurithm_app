// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Receptionist`
  String get receptionist {
    return Intl.message(
      'Receptionist',
      name: 'receptionist',
      desc: '',
      args: [],
    );
  }

  /// `Search Patient`
  String get searchPatient {
    return Intl.message(
      'Search Patient',
      name: 'searchPatient',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Appointments`
  String get appointment {
    return Intl.message(
      'Appointments',
      name: 'appointment',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get summary {
    return Intl.message(
      'Summary',
      name: 'summary',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Yrs Old`
  String get yrsOld {
    return Intl.message(
      'Yrs Old',
      name: 'yrsOld',
      desc: '',
      args: [],
    );
  }

  /// `Branch`
  String get branch {
    return Intl.message(
      'Branch',
      name: 'branch',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Related`
  String get related {
    return Intl.message(
      'Related',
      name: 'related',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Option`
  String get option {
    return Intl.message(
      'Option',
      name: 'option',
      desc: '',
      args: [],
    );
  }

  /// `Make Appointments`
  String get makeAppointments {
    return Intl.message(
      'Make Appointments',
      name: 'makeAppointments',
      desc: '',
      args: [],
    );
  }

  /// `Appointment Note`
  String get chooseNote {
    return Intl.message(
      'Appointment Note',
      name: 'chooseNote',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Conflict with another appointment`
  String get conflict {
    return Intl.message(
      'Conflict with another appointment',
      name: 'conflict',
      desc: '',
      args: [],
    );
  }

  /// `Server Error`
  String get serverError {
    return Intl.message(
      'Server Error',
      name: 'serverError',
      desc: '',
      args: [],
    );
  }

  /// `Update Prolonged Visit`
  String get updateProlongedVisit {
    return Intl.message(
      'Update Prolonged Visit',
      name: 'updateProlongedVisit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to update this item?`
  String get areYouSure {
    return Intl.message(
      'Are you sure you want to update this item?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Booking Calender`
  String get bookCalender {
    return Intl.message(
      'Booking Calender',
      name: 'bookCalender',
      desc: '',
      args: [],
    );
  }

  /// `Delete Appointment`
  String get deleteAppointment {
    return Intl.message(
      'Delete Appointment',
      name: 'deleteAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this Appointment?`
  String get sureDeleteAppointment {
    return Intl.message(
      'Are you sure you want to delete this Appointment?',
      name: 'sureDeleteAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Examination Type`
  String get examinationType {
    return Intl.message(
      'Examination Type',
      name: 'examinationType',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message(
      'Note',
      name: 'note',
      desc: '',
      args: [],
    );
  }

  /// `Prolonged Visit`
  String get prolongedVisit {
    return Intl.message(
      'Prolonged Visit',
      name: 'prolongedVisit',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Have Appointment Today`
  String get appointmentToday {
    return Intl.message(
      'Have Appointment Today',
      name: 'appointmentToday',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signin {
    return Intl.message(
      'Sign In',
      name: 'signin',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Enter Password here`
  String get enterPassword {
    return Intl.message(
      'Enter Password here',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Let's Sign In for explore Continues`
  String get signInLabel {
    return Intl.message(
      'Let\'s Sign In for explore Continues',
      name: 'signInLabel',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Enter Email here`
  String get enterEmail {
    return Intl.message(
      'Enter Email here',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get oldPassword {
    return Intl.message(
      'New Password',
      name: 'oldPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password has been updated successfully`
  String get passwordSuccessfully {
    return Intl.message(
      'Password has been updated successfully',
      name: 'passwordSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `password not match!`
  String get passwordNotMatch {
    return Intl.message(
      'password not match!',
      name: 'passwordNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `password and confirm password not match!`
  String get passwordConfirm {
    return Intl.message(
      'password and confirm password not match!',
      name: 'passwordConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Please try again!`
  String get PleaseAgain {
    return Intl.message(
      'Please try again!',
      name: 'PleaseAgain',
      desc: '',
      args: [],
    );
  }

  /// `Username must not be Empty`
  String get mustUsername {
    return Intl.message(
      'Username must not be Empty',
      name: 'mustUsername',
      desc: '',
      args: [],
    );
  }

  /// `Password must not be Empty`
  String get mustPassword {
    return Intl.message(
      'Password must not be Empty',
      name: 'mustPassword',
      desc: '',
      args: [],
    );
  }

  /// `Phone must not be Empty`
  String get mustPhone {
    return Intl.message(
      'Phone must not be Empty',
      name: 'mustPhone',
      desc: '',
      args: [],
    );
  }

  /// `Branch must not be Empty`
  String get mustBranch {
    return Intl.message(
      'Branch must not be Empty',
      name: 'mustBranch',
      desc: '',
      args: [],
    );
  }

  /// `Gender must not be Empty`
  String get mustGender {
    return Intl.message(
      'Gender must not be Empty',
      name: 'mustGender',
      desc: '',
      args: [],
    );
  }

  /// `Date of Birth must not be Empty`
  String get mustBirth {
    return Intl.message(
      'Date of Birth must not be Empty',
      name: 'mustBirth',
      desc: '',
      args: [],
    );
  }

  /// `Email must not be Empty`
  String get mustEmail {
    return Intl.message(
      'Email must not be Empty',
      name: 'mustEmail',
      desc: '',
      args: [],
    );
  }

  /// `must not be Empty`
  String get mustNotEmpty {
    return Intl.message(
      'must not be Empty',
      name: 'mustNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgetPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Hello!`
  String get hello {
    return Intl.message(
      'Hello!',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Please sign in to your account`
  String get pleaseSignInToYourAccount {
    return Intl.message(
      'Please sign in to your account',
      name: 'pleaseSignInToYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create Patient Account`
  String get createPatientAccount {
    return Intl.message(
      'Create Patient Account',
      name: 'createPatientAccount',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message(
      'Full Name',
      name: 'fullName',
      desc: '',
      args: [],
    );
  }

  /// `DD`
  String get dd {
    return Intl.message(
      'DD',
      name: 'dd',
      desc: '',
      args: [],
    );
  }

  /// `MM`
  String get mm {
    return Intl.message(
      'MM',
      name: 'mm',
      desc: '',
      args: [],
    );
  }

  /// `YY`
  String get yy {
    return Intl.message(
      'YY',
      name: 'yy',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phone {
    return Intl.message(
      'Phone Number',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get emailAddress {
    return Intl.message(
      'Email Address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Manual ID`
  String get manualId {
    return Intl.message(
      'Manual ID',
      name: 'manualId',
      desc: '',
      args: [],
    );
  }

  /// `National ID`
  String get nationalId {
    return Intl.message(
      'National ID',
      name: 'nationalId',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: '',
      args: [],
    );
  }

  /// `Patient's Summary`
  String get patientSummary {
    return Intl.message(
      'Patient\'s Summary',
      name: 'patientSummary',
      desc: '',
      args: [],
    );
  }

  /// `Generate PDF`
  String get generatePdf {
    return Intl.message(
      'Generate PDF',
      name: 'generatePdf',
      desc: '',
      args: [],
    );
  }

  /// `Get Appointments`
  String get getAppointments {
    return Intl.message(
      'Get Appointments',
      name: 'getAppointments',
      desc: '',
      args: [],
    );
  }

  /// `Choose Date`
  String get chooseDate {
    return Intl.message(
      'Choose Date',
      name: 'chooseDate',
      desc: '',
      args: [],
    );
  }

  /// `Choose Branch`
  String get chooseBranch {
    return Intl.message(
      'Choose Branch',
      name: 'chooseBranch',
      desc: '',
      args: [],
    );
  }

  /// `Make Appointment`
  String get makeAppointment {
    return Intl.message(
      'Make Appointment',
      name: 'makeAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get available {
    return Intl.message(
      'Available',
      name: 'available',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `Booked`
  String get booked {
    return Intl.message(
      'Booked',
      name: 'booked',
      desc: '',
      args: [],
    );
  }

  /// `Break`
  String get breakTime {
    return Intl.message(
      'Break',
      name: 'breakTime',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get morning {
    return Intl.message(
      'Morning',
      name: 'morning',
      desc: '',
      args: [],
    );
  }

  /// `Evening`
  String get evening {
    return Intl.message(
      'Evening',
      name: 'evening',
      desc: '',
      args: [],
    );
  }

  /// `Night`
  String get night {
    return Intl.message(
      'Night',
      name: 'night',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Appointment`
  String get confirmAppointment {
    return Intl.message(
      'Confirm Appointment',
      name: 'confirmAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get Home {
    return Intl.message(
      'Home',
      name: 'Home',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continu {
    return Intl.message(
      'Continue',
      name: 'continu',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout {
    return Intl.message(
      'Log Out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Log Out?`
  String get logout2 {
    return Intl.message(
      'Log Out?',
      name: 'logout2',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get sureLogOut {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'sureLogOut',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Date of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date of Birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get afternoon {
    return Intl.message(
      'Afternoon',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Invalid phone number`
  String get invalidPhoneNumber {
    return Intl.message(
      'Invalid phone number',
      name: 'invalidPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalidEmail {
    return Intl.message(
      'Invalid email address',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invalid national ID. Must be exactly 14 digits.`
  String get invalidNationalId {
    return Intl.message(
      'Invalid national ID. Must be exactly 14 digits.',
      name: 'invalidNationalId',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get noInternet {
    return Intl.message(
      'No Internet Connection',
      name: 'noInternet',
      desc: '',
      args: [],
    );
  }

  /// `Create Receptionist`
  String get createReceptionist {
    return Intl.message(
      'Create Receptionist',
      name: 'createReceptionist',
      desc: '',
      args: [],
    );
  }

  /// `Add Receptionist`
  String get addReceptionist {
    return Intl.message(
      'Add Receptionist',
      name: 'addReceptionist',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
