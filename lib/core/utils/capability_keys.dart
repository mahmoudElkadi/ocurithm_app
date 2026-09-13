import 'package:flutter/foundation.dart';

/// Mirror of `ocurithm/apps/api/src/common/constants/capabilities.ts`.
///
/// Capability strings used to be typed inline wherever they were needed, which
/// is how the drawer ended up gating on `manageReciptionists`,
/// `manageSubCategories`, `manageSuppliers` and `managePurchaseOrders` — none of
/// which the backend has ever issued. A typo silently hides a whole screen,
/// because an unknown capability simply never matches.
///
/// Use these constants instead of raw strings, and keep [all] in sync when the
/// backend list changes. [debugAssertKnown] turns the next typo into a loud
/// failure in debug builds rather than a missing menu entry in production.
class CapabilityKeys {
  const CapabilityKeys._();

  // Examination Types
  static const String manageExaminationTypes = 'manageExaminationTypes';

  // Payment Methods
  static const String managePaymentMethods = 'managePaymentMethods';

  // Save Reasons
  static const String manageSaveReasons = 'manageSaveReasons';

  // Medicines
  static const String manageMedicines = 'manageMedicines';

  // Clinics
  static const String manageClinics = 'manageClinics';

  // Patients
  static const String showPatients = 'showPatients';
  static const String managePatients = 'managePatients';

  // Branches
  static const String showBranches = 'showBranches';
  static const String manageBranches = 'manageBranches';

  // Doctors
  static const String showDoctors = 'showDoctors';
  static const String showDoctorsExaminations = 'showDoctorsExaminations';
  static const String manageDoctors = 'manageDoctors';

  // Receptionists
  static const String manageReceptionists = 'manageReceptionists';

  // Agents (call center)
  static const String showAgents = 'showAgents';
  static const String manageAgents = 'manageAgents';

  // Appointments
  static const String showAppointments = 'showAppointments';
  static const String addAppointments = 'addAppointments';
  static const String editAppointmentsReceptionist =
      'editAppointmentsReceptionist';
  static const String editAppointmentsDoctor = 'editAppointmentsDoctor';

  // Examinations
  static const String showExaminations = 'showExaminations';
  static const String manageExaminations = 'manageExaminations';
  static const String deleteExaminations = 'deleteExaminations';

  // Chat
  static const String chat = 'chat';

  // Categories
  static const String showCategories = 'showCategories';
  static const String manageCategories = 'manageCategories';

  // Products
  static const String showProducts = 'showProducts';
  static const String showSubcategories = 'showSubcategories';
  static const String manageProducts = 'manageProducts';

  // Orders
  static const String showOrders = 'showOrders';
  static const String addOrders = 'addOrders';
  static const String editOrders = 'editOrders';
  static const String cancelOrders = 'cancelOrders';

  // Accounts
  static const String showAccounts = 'showAccounts';
  static const String manageAccounts = 'manageAccounts';

  // Transactions
  static const String showTransactions = 'showTransactions';
  static const String manageTransactions = 'manageTransactions';

  // Marketing — Platforms
  static const String showPlatforms = 'showPlatforms';
  static const String managePlatforms = 'managePlatforms';

  // Marketing — Campaigns
  static const String showCampaigns = 'showCampaigns';
  static const String manageCampaigns = 'manageCampaigns';

  // Marketing — Leads
  static const String showLeads = 'showLeads';
  static const String manageLeads = 'manageLeads';

  // Call center — Calls
  static const String showCalls = 'showCalls';
  static const String manageCalls = 'manageCalls';

  // Surgical — Rooms
  static const String showRooms = 'showRooms';
  static const String manageRooms = 'manageRooms';

  // Surgical — Surgeries
  static const String showSurgeries = 'showSurgeries';
  static const String manageSurgeries = 'manageSurgeries';

  // Billings
  static const String showBillings = 'showBillings';
  static const String manageBillings = 'manageBillings';

  // Data-analysis dashboard
  static const String viewDataAnalysisDashboard = 'viewDataAnalysisDashboard';

  // Marketing — Ad-platform integrations & analytics (Meta / Google Ads)
  static const String viewMarketingIntegrations = 'viewMarketingIntegrations';
  static const String manageMarketingIntegrations =
      'manageMarketingIntegrations';
  static const String viewMetaAds = 'viewMetaAds';
  static const String viewGoogleAds = 'viewGoogleAds';

  // System — grants everything.
  static const String manageCapability = 'manageCapability';

  /// Every capability the backend can issue. Must stay identical to
  /// `CAPABILITIES` in the API.
  static const Set<String> all = {
    manageExaminationTypes,
    managePaymentMethods,
    manageSaveReasons,
    manageMedicines,
    manageClinics,
    showPatients,
    managePatients,
    showBranches,
    manageBranches,
    showDoctors,
    showDoctorsExaminations,
    manageDoctors,
    manageReceptionists,
    showAgents,
    manageAgents,
    showAppointments,
    addAppointments,
    editAppointmentsReceptionist,
    editAppointmentsDoctor,
    showExaminations,
    manageExaminations,
    deleteExaminations,
    chat,
    showCategories,
    manageCategories,
    showProducts,
    showSubcategories,
    manageProducts,
    showOrders,
    addOrders,
    editOrders,
    cancelOrders,
    showAccounts,
    manageAccounts,
    showTransactions,
    manageTransactions,
    showPlatforms,
    managePlatforms,
    showCampaigns,
    manageCampaigns,
    showLeads,
    manageLeads,
    showCalls,
    manageCalls,
    showRooms,
    manageRooms,
    showSurgeries,
    manageSurgeries,
    showBillings,
    manageBillings,
    viewDataAnalysisDashboard,
    viewMarketingIntegrations,
    manageMarketingIntegrations,
    viewMetaAds,
    viewGoogleAds,
    manageCapability,
  };

  static bool isKnown(String capability) => all.contains(capability);

  /// Fails fast in debug builds when a capability string the app gates on does
  /// not exist server-side. No-op in release — a bad string must not take a
  /// clinic device down.
  static void debugAssertKnown(Iterable<String> capabilities,
      {String context = 'capability'}) {
    assert(() {
      final unknown = capabilities.where((c) => !isKnown(c)).toList();
      if (unknown.isNotEmpty) {
        throw FlutterError(
          'Unknown capability string(s) in $context: ${unknown.join(', ')}.\n'
          'These do not exist in the backend CAPABILITIES list, so anything '
          'gated on them can never be shown. Add them to CapabilityKeys if the '
          'backend really issues them, otherwise fix the typo.',
        );
      }
      return true;
    }());
  }
}
