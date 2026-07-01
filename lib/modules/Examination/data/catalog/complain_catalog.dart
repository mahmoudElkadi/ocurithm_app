/// Dart port of the shared `@ocurithm/examination-catalog` Complain stage.
///
/// Source of truth: backend `packages/examination-catalog/src/complain/`
/// (fields.ts, groups.ts, version.ts). Hand-maintained mirror — keep in sync and
/// bump [complainCatalogVersion] together.
///
/// Two differences from the History catalog:
///  1. Keys are **option-scoped** (`<optionKey>_<field>`), never shared/canonical —
///     "decreased vision OD" and "floaters OS" are independent values.
///  2. Structure is **Group → Option → Fields** (History is flat Category → Fields),
///     and there are no computed fields.
///
/// Reuses the shared primitives ([FieldDef], [FieldKind], [isFieldVisible],
/// [formatHistoryValue]) from history_catalog.dart.
library;

import 'history_catalog.dart';

/// A checkable complaint option and the ordered field keys it reveals. An option
/// with an empty [fieldKeys] renders as a checkbox only.
class ComplainOptionDef {
  const ComplainOptionDef({
    required this.key,
    required this.label,
    required this.fieldKeys,
  });

  final String key;
  final String label;
  final List<String> fieldKeys;
}

/// A titled group of complaint options.
class ComplainGroupDef {
  const ComplainGroupDef({
    required this.key,
    required this.title,
    required this.options,
  });

  final String key;
  final String title;
  final List<ComplainOptionDef> options;
}

/// Bump when the catalog's field keys / options change. Must stay in sync with
/// the backend's `COMPLAIN_CATALOG_VERSION`.
const int complainCatalogVersion = 1;

const List<String> _eye = ['OD', 'OS', 'OU'];
const List<String> _yesNo = ['Yes', 'No'];

/// Flat, option-scoped complain field definitions. Keyed by `<optionKey>_<field>`.
const Map<String, FieldDef> complainFields = {
  // ── Visual Complaints → Decreased Vision ──
  'decreasedVision_eye': FieldDef(key: 'decreasedVision_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'decreasedVision_onset': FieldDef(key: 'decreasedVision_onset', kind: FieldKind.enumField, label: 'Onset', options: ['Sudden (<24h)', 'Acute (1-7 days)', 'Subacute (1-4 weeks)', 'Chronic (>1 month)']),
  'decreasedVision_course': FieldDef(key: 'decreasedVision_course', kind: FieldKind.enumField, label: 'Course', options: ['Stable', 'Progressive', 'Fluctuating', 'Improving']),
  'decreasedVision_severity': FieldDef(key: 'decreasedVision_severity', kind: FieldKind.enumField, label: 'Severity', options: ['Mild', 'Moderate', 'Severe']),
  'decreasedVision_affectedVision': FieldDef(key: 'decreasedVision_affectedVision', kind: FieldKind.enumField, label: 'Affected vision', options: ['Distance', 'Near', 'Both']),
  'decreasedVision_worseIn': FieldDef(key: 'decreasedVision_worseIn', kind: FieldKind.enumField, label: 'Worse in', options: ['Morning', 'Evening', 'Constant']),

  // ── Visual Complaints → Distorted Vision (Metamorphopsia) ──
  'distortedVision_eye': FieldDef(key: 'distortedVision_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'distortedVision_duration': FieldDef(key: 'distortedVision_duration', kind: FieldKind.number, label: 'Duration', min: 0, max: 3650),
  'distortedVision_durationUnit': FieldDef(key: 'distortedVision_durationUnit', kind: FieldKind.enumField, label: 'Duration unit', options: ['hours', 'days', 'weeks', 'months']),
  'distortedVision_progressive': FieldDef(key: 'distortedVision_progressive', kind: FieldKind.enumField, label: 'Progressive', options: _yesNo),
  'distortedVision_centralBlur': FieldDef(key: 'distortedVision_centralBlur', kind: FieldKind.enumField, label: 'Associated central blur', options: _yesNo),
  'distortedVision_amsler': FieldDef(key: 'distortedVision_amsler', kind: FieldKind.enumField, label: 'Amsler positive', options: ['Yes', 'No', 'Not sure']),

  // ── Visual Complaints → Central Scotoma ──
  'centralScotoma_eye': FieldDef(key: 'centralScotoma_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'centralScotoma_onsetType': FieldDef(key: 'centralScotoma_onsetType', kind: FieldKind.enumField, label: 'Onset', options: ['Sudden', 'Gradual']),
  'centralScotoma_course': FieldDef(key: 'centralScotoma_course', kind: FieldKind.enumField, label: 'Course', options: ['Stable', 'Progressive']),

  // ── Visual Complaints → Peripheral Visual Field Loss ──
  'peripheralFieldLoss_eye': FieldDef(key: 'peripheralFieldLoss_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'peripheralFieldLoss_region': FieldDef(key: 'peripheralFieldLoss_region', kind: FieldKind.enumField, label: 'Region', options: ['Superior', 'Inferior', 'Temporal', 'Nasal', 'Concentric']),

  // ── Visual Complaints → Transient Visual Loss ──
  'transientVisualLoss_eye': FieldDef(key: 'transientVisualLoss_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'transientVisualLoss_duration': FieldDef(key: 'transientVisualLoss_duration', kind: FieldKind.enumField, label: 'Duration', options: ['Seconds', 'Minutes', 'Hours']),
  'transientVisualLoss_recovery': FieldDef(key: 'transientVisualLoss_recovery', kind: FieldKind.enumField, label: 'Recovery', options: ['Complete', 'Partial']),
  'transientVisualLoss_episodes': FieldDef(key: 'transientVisualLoss_episodes', kind: FieldKind.enumField, label: 'Episodes', options: ['Single', 'Recurrent']),

  // ── Floaters & Vitreoretinal → Floaters ──
  'floaters_eye': FieldDef(key: 'floaters_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'floaters_newOnset': FieldDef(key: 'floaters_newOnset', kind: FieldKind.enumField, label: 'New onset', options: _yesNo),
  'floaters_number': FieldDef(key: 'floaters_number', kind: FieldKind.enumField, label: 'Number', options: ['Single', 'Multiple']),
  'floaters_type': FieldDef(key: 'floaters_type', kind: FieldKind.enumField, label: 'Type', options: ['Spots', 'Cobweb', 'Ring']),
  'floaters_progressive': FieldDef(key: 'floaters_progressive', kind: FieldKind.enumField, label: 'Progressive', options: _yesNo),
  'floaters_associatedFlashes': FieldDef(key: 'floaters_associatedFlashes', kind: FieldKind.enumField, label: 'Associated flashes', options: _yesNo),

  // ── Floaters & Vitreoretinal → Flashes (Photopsia) ──
  'flashes_eye': FieldDef(key: 'flashes_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'flashes_duration': FieldDef(key: 'flashes_duration', kind: FieldKind.text, label: 'Duration'),
  'flashes_frequency': FieldDef(key: 'flashes_frequency', kind: FieldKind.text, label: 'Frequency'),
  'flashes_peripheral': FieldDef(key: 'flashes_peripheral', kind: FieldKind.enumField, label: 'Peripheral', options: _yesNo),
  'flashes_associatedFloaters': FieldDef(key: 'flashes_associatedFloaters', kind: FieldKind.enumField, label: 'Associated floaters', options: _yesNo),

  // ── Floaters & Vitreoretinal → Curtain / Shadow ──
  'curtainShadow_eye': FieldDef(key: 'curtainShadow_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'curtainShadow_location': FieldDef(key: 'curtainShadow_location', kind: FieldKind.enumField, label: 'Location', options: ['Superior', 'Inferior', 'Nasal', 'Temporal']),
  'curtainShadow_progressive': FieldDef(key: 'curtainShadow_progressive', kind: FieldKind.enumField, label: 'Progressive', options: _yesNo),
  'curtainShadow_sudden': FieldDef(key: 'curtainShadow_sudden', kind: FieldKind.enumField, label: 'Sudden', options: _yesNo),

  // ── DME / Macular → Blurred Central Vision ──
  'blurredCentralVision_eye': FieldDef(key: 'blurredCentralVision_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'blurredCentralVision_duration': FieldDef(key: 'blurredCentralVision_duration', kind: FieldKind.text, label: 'Duration'),
  'blurredCentralVision_progressive': FieldDef(key: 'blurredCentralVision_progressive', kind: FieldKind.enumField, label: 'Progressive', options: _yesNo),

  // ── DME / Macular → Difficulty Reading ──
  'difficultyReading_eye': FieldDef(key: 'difficultyReading_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'difficultyReading_new': FieldDef(key: 'difficultyReading_new', kind: FieldKind.enumField, label: 'New', options: _yesNo),
  'difficultyReading_progressive': FieldDef(key: 'difficultyReading_progressive', kind: FieldKind.enumField, label: 'Progressive', options: _yesNo),

  // ── DME / Macular → Micropsia / Macropsia ──
  'micropsia_eye': FieldDef(key: 'micropsia_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'macropsia_eye': FieldDef(key: 'macropsia_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),

  // ── DME / Macular → Image Distortion ──
  'imageDistortion_eye': FieldDef(key: 'imageDistortion_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'imageDistortion_type': FieldDef(key: 'imageDistortion_type', kind: FieldKind.enumField, label: 'Type', options: ['Horizontal', 'Vertical', 'General']),

  // ── Diplopia → Double Vision ──
  'doubleVision_type': FieldDef(key: 'doubleVision_type', kind: FieldKind.enumField, label: 'Type', options: ['Monocular', 'Binocular']),
  'doubleVision_direction': FieldDef(key: 'doubleVision_direction', kind: FieldKind.enumField, label: 'Direction', options: ['Horizontal', 'Vertical', 'Oblique']),
  'doubleVision_frequency': FieldDef(key: 'doubleVision_frequency', kind: FieldKind.enumField, label: 'Frequency', options: ['Constant', 'Intermittent']),
  'doubleVision_worseAt': FieldDef(key: 'doubleVision_worseAt', kind: FieldKind.enumField, label: 'Worse at', options: ['Distance', 'Near']),

  // ── Pain → Eye Pain ──
  'eyePain_eye': FieldDef(key: 'eyePain_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'eyePain_severity': FieldDef(key: 'eyePain_severity', kind: FieldKind.number, label: 'Severity (0-10)', min: 0, max: 10, step: 1),
  'eyePain_nature': FieldDef(key: 'eyePain_nature', kind: FieldKind.enumField, label: 'Nature', options: ['Dull', 'Sharp', 'Throbbing', 'Burning']),
  'eyePain_aggravatedByMovement': FieldDef(key: 'eyePain_aggravatedByMovement', kind: FieldKind.enumField, label: 'Aggravated by movement', options: _yesNo),

  // ── Red Eye → Redness ──
  'redness_eye': FieldDef(key: 'redness_eye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'redness_duration': FieldDef(key: 'redness_duration', kind: FieldKind.text, label: 'Duration'),
  'redness_pain': FieldDef(key: 'redness_pain', kind: FieldKind.enumField, label: 'Pain', options: _yesNo),
  'redness_discharge': FieldDef(key: 'redness_discharge', kind: FieldKind.enumField, label: 'Discharge', options: _yesNo),
  'redness_photophobia': FieldDef(key: 'redness_photophobia', kind: FieldKind.enumField, label: 'Photophobia', options: _yesNo),

  // ── Ocular Surface → Dry Eye Symptoms ──
  'dryEye_foreignBody': FieldDef(key: 'dryEye_foreignBody', kind: FieldKind.enumField, label: 'Foreign body sensation', options: _yesNo),
  'dryEye_burning': FieldDef(key: 'dryEye_burning', kind: FieldKind.enumField, label: 'Burning', options: _yesNo),
  'dryEye_fluctuatingVision': FieldDef(key: 'dryEye_fluctuatingVision', kind: FieldKind.enumField, label: 'Fluctuating vision', options: _yesNo),
  'dryEye_worseWithScreens': FieldDef(key: 'dryEye_worseWithScreens', kind: FieldKind.enumField, label: 'Worse with screens', options: _yesNo),
  'dryEye_severity': FieldDef(key: 'dryEye_severity', kind: FieldKind.enumField, label: 'Severity', options: ['Mild', 'Moderate', 'Severe']),

  // ── Ocular Surface → Itching ──
  'itching_seasonal': FieldDef(key: 'itching_seasonal', kind: FieldKind.enumField, label: 'Seasonal', options: _yesNo),
  'itching_perennial': FieldDef(key: 'itching_perennial', kind: FieldKind.enumField, label: 'Perennial', options: _yesNo),

  // ── Ocular Surface → Excessive Tearing ──
  'excessiveTearing_constant': FieldDef(key: 'excessiveTearing_constant', kind: FieldKind.enumField, label: 'Constant', options: _yesNo),
  'excessiveTearing_windRelated': FieldDef(key: 'excessiveTearing_windRelated', kind: FieldKind.enumField, label: 'Wind related', options: _yesNo),
  'excessiveTearing_outdoorOnly': FieldDef(key: 'excessiveTearing_outdoorOnly', kind: FieldKind.enumField, label: 'Outdoor only', options: _yesNo),

  // ── Photophobia → Light Sensitivity ──
  'lightSensitivity_severity': FieldDef(key: 'lightSensitivity_severity', kind: FieldKind.enumField, label: 'Severity', options: ['Mild', 'Moderate', 'Severe']),

  // ── Night Vision → Night Blindness ──
  'nightBlindness_sinceChildhood': FieldDef(key: 'nightBlindness_sinceChildhood', kind: FieldKind.enumField, label: 'Since childhood', options: _yesNo),
  'nightBlindness_acquired': FieldDef(key: 'nightBlindness_acquired', kind: FieldKind.enumField, label: 'Acquired', options: _yesNo),
  'nightBlindness_progressive': FieldDef(key: 'nightBlindness_progressive', kind: FieldKind.enumField, label: 'Progressive', options: _yesNo),

  // ── Night Vision → Glare ──
  'glare_when': FieldDef(key: 'glare_when', kind: FieldKind.enumField, label: 'When', options: ['Day', 'Night', 'Both']),

  // ── Night Vision → Halos ──
  'halos_aroundLights': FieldDef(key: 'halos_aroundLights', kind: FieldKind.enumField, label: 'Around lights', options: _yesNo),
  'halos_day': FieldDef(key: 'halos_day', kind: FieldKind.enumField, label: 'Day', options: _yesNo),
  'halos_night': FieldDef(key: 'halos_night', kind: FieldKind.enumField, label: 'Night', options: _yesNo),

  // ── Color Vision → Color Vision Disturbance ──
  'colorDisturbance_redDesaturation': FieldDef(key: 'colorDisturbance_redDesaturation', kind: FieldKind.enumField, label: 'Red desaturation', options: _yesNo),
  'colorDisturbance_generalColorLoss': FieldDef(key: 'colorDisturbance_generalColorLoss', kind: FieldKind.enumField, label: 'General color loss', options: _yesNo),

  // ── Neuro-ophthalmic → Visual Field Defect ──
  'visualFieldDefect_onset': FieldDef(key: 'visualFieldDefect_onset', kind: FieldKind.enumField, label: 'Onset', options: ['Sudden', 'Progressive']),

  // ── Neuro-ophthalmic → Visual Hallucinations ──
  'visualHallucinations_positive': FieldDef(key: 'visualHallucinations_positive', kind: FieldKind.enumField, label: 'Positive phenomena', options: _yesNo),
  'visualHallucinations_negative': FieldDef(key: 'visualHallucinations_negative', kind: FieldKind.enumField, label: 'Negative phenomena', options: _yesNo),

  // ── Pediatric → Eye Deviation ──
  'eyeDeviation_type': FieldDef(key: 'eyeDeviation_type', kind: FieldKind.enumField, label: 'Type', options: ['Constant', 'Intermittent']),

  // ── Trauma → Ocular Trauma ──
  'ocularTrauma_type': FieldDef(key: 'ocularTrauma_type', kind: FieldKind.enumField, label: 'Type', options: ['Blunt', 'Penetrating', 'Chemical', 'Thermal']),
};

/// Complain groups → options → option-scoped field keys. Options with an empty
/// [ComplainOptionDef.fieldKeys] render as a checkbox only.
const List<ComplainGroupDef> complainGroups = [
  ComplainGroupDef(key: 'visualComplaints', title: 'Visual Complaints', options: [
    ComplainOptionDef(key: 'decreasedVision', label: 'Decreased Vision', fieldKeys: [
      'decreasedVision_eye', 'decreasedVision_onset', 'decreasedVision_course', 'decreasedVision_severity', 'decreasedVision_affectedVision', 'decreasedVision_worseIn',
    ]),
    ComplainOptionDef(key: 'distortedVision', label: 'Distorted Vision (Metamorphopsia)', fieldKeys: [
      'distortedVision_eye', 'distortedVision_duration', 'distortedVision_durationUnit', 'distortedVision_progressive', 'distortedVision_centralBlur', 'distortedVision_amsler',
    ]),
    ComplainOptionDef(key: 'centralScotoma', label: 'Central Scotoma', fieldKeys: ['centralScotoma_eye', 'centralScotoma_onsetType', 'centralScotoma_course']),
    ComplainOptionDef(key: 'peripheralFieldLoss', label: 'Peripheral Visual Field Loss', fieldKeys: ['peripheralFieldLoss_eye', 'peripheralFieldLoss_region']),
    ComplainOptionDef(key: 'transientVisualLoss', label: 'Transient Visual Loss', fieldKeys: ['transientVisualLoss_eye', 'transientVisualLoss_duration', 'transientVisualLoss_recovery', 'transientVisualLoss_episodes']),
  ]),
  ComplainGroupDef(key: 'floatersVitreoretinal', title: 'Floaters & Vitreoretinal Symptoms', options: [
    ComplainOptionDef(key: 'floaters', label: 'Floaters', fieldKeys: ['floaters_eye', 'floaters_newOnset', 'floaters_number', 'floaters_type', 'floaters_progressive', 'floaters_associatedFlashes']),
    ComplainOptionDef(key: 'flashes', label: 'Flashes (Photopsia)', fieldKeys: ['flashes_eye', 'flashes_duration', 'flashes_frequency', 'flashes_peripheral', 'flashes_associatedFloaters']),
    ComplainOptionDef(key: 'curtainShadow', label: 'Curtain / Shadow', fieldKeys: ['curtainShadow_eye', 'curtainShadow_location', 'curtainShadow_progressive', 'curtainShadow_sudden']),
  ]),
  ComplainGroupDef(key: 'dmeMacular', title: 'DME / Macular Symptoms', options: [
    ComplainOptionDef(key: 'blurredCentralVision', label: 'Blurred Central Vision', fieldKeys: ['blurredCentralVision_eye', 'blurredCentralVision_duration', 'blurredCentralVision_progressive']),
    ComplainOptionDef(key: 'difficultyReading', label: 'Difficulty Reading', fieldKeys: ['difficultyReading_eye', 'difficultyReading_new', 'difficultyReading_progressive']),
    ComplainOptionDef(key: 'micropsia', label: 'Micropsia', fieldKeys: ['micropsia_eye']),
    ComplainOptionDef(key: 'macropsia', label: 'Macropsia', fieldKeys: ['macropsia_eye']),
    ComplainOptionDef(key: 'imageDistortion', label: 'Image Distortion', fieldKeys: ['imageDistortion_eye', 'imageDistortion_type']),
  ]),
  ComplainGroupDef(key: 'diplopia', title: 'Diplopia', options: [
    ComplainOptionDef(key: 'doubleVision', label: 'Double Vision', fieldKeys: ['doubleVision_type', 'doubleVision_direction', 'doubleVision_frequency', 'doubleVision_worseAt']),
  ]),
  ComplainGroupDef(key: 'pain', title: 'Pain', options: [
    ComplainOptionDef(key: 'eyePain', label: 'Eye Pain', fieldKeys: ['eyePain_eye', 'eyePain_severity', 'eyePain_nature', 'eyePain_aggravatedByMovement']),
  ]),
  ComplainGroupDef(key: 'redEye', title: 'Red Eye', options: [
    ComplainOptionDef(key: 'redness', label: 'Redness', fieldKeys: ['redness_eye', 'redness_duration', 'redness_pain', 'redness_discharge', 'redness_photophobia']),
  ]),
  ComplainGroupDef(key: 'ocularSurface', title: 'Ocular Surface', options: [
    ComplainOptionDef(key: 'dryEye', label: 'Dry Eye Symptoms', fieldKeys: ['dryEye_foreignBody', 'dryEye_burning', 'dryEye_fluctuatingVision', 'dryEye_worseWithScreens', 'dryEye_severity']),
    ComplainOptionDef(key: 'itching', label: 'Itching', fieldKeys: ['itching_seasonal', 'itching_perennial']),
    ComplainOptionDef(key: 'excessiveTearing', label: 'Excessive Tearing', fieldKeys: ['excessiveTearing_constant', 'excessiveTearing_windRelated', 'excessiveTearing_outdoorOnly']),
  ]),
  ComplainGroupDef(key: 'photophobia', title: 'Photophobia', options: [
    ComplainOptionDef(key: 'lightSensitivity', label: 'Light Sensitivity', fieldKeys: ['lightSensitivity_severity']),
  ]),
  ComplainGroupDef(key: 'nightVision', title: 'Night Vision', options: [
    ComplainOptionDef(key: 'nightBlindness', label: 'Night Blindness', fieldKeys: ['nightBlindness_sinceChildhood', 'nightBlindness_acquired', 'nightBlindness_progressive']),
    ComplainOptionDef(key: 'glare', label: 'Glare', fieldKeys: ['glare_when']),
    ComplainOptionDef(key: 'halos', label: 'Halos', fieldKeys: ['halos_aroundLights', 'halos_day', 'halos_night']),
  ]),
  ComplainGroupDef(key: 'colorVision', title: 'Color Vision', options: [
    ComplainOptionDef(key: 'colorDisturbance', label: 'Color Vision Disturbance', fieldKeys: ['colorDisturbance_redDesaturation', 'colorDisturbance_generalColorLoss']),
  ]),
  ComplainGroupDef(key: 'neuroOphthalmic', title: 'Neuro-ophthalmic', options: [
    ComplainOptionDef(key: 'visualFieldDefect', label: 'Visual Field Defect', fieldKeys: ['visualFieldDefect_onset']),
    ComplainOptionDef(key: 'visualHallucinations', label: 'Visual Hallucinations', fieldKeys: ['visualHallucinations_positive', 'visualHallucinations_negative']),
    ComplainOptionDef(key: 'oscillopsia', label: 'Oscillopsia', fieldKeys: []),
  ]),
  ComplainGroupDef(key: 'pediatric', title: 'Pediatric', options: [
    ComplainOptionDef(key: 'eyeDeviation', label: 'Eye Deviation', fieldKeys: ['eyeDeviation_type']),
    ComplainOptionDef(key: 'abnormalHeadPosture', label: 'Abnormal Head Posture', fieldKeys: []),
    ComplainOptionDef(key: 'poorVisualBehavior', label: 'Poor Visual Behavior', fieldKeys: []),
  ]),
  ComplainGroupDef(key: 'trauma', title: 'Trauma', options: [
    ComplainOptionDef(key: 'ocularTrauma', label: 'Ocular Trauma', fieldKeys: ['ocularTrauma_type']),
  ]),
];

/// All options flattened, for key/label lookups.
final Map<String, ComplainOptionDef> complainOptionsByKey = {
  for (final g in complainGroups)
    for (final o in g.options) o.key: o,
};

/// Group title for an option key (empty string if unknown).
String complainGroupTitleForOption(String optionKey) {
  for (final g in complainGroups) {
    for (final o in g.options) {
      if (o.key == optionKey) return g.title;
    }
  }
  return '';
}

/// Label for an option key (falls back to the key itself if unknown).
String complainOptionLabel(String optionKey) =>
    complainOptionsByKey[optionKey]?.label ?? optionKey;

/// Ordered (label, formatted-value) pairs for an option's visible, non-empty
/// fields. Reuses [formatHistoryValue] / [isFieldVisible] from the shared primitives.
List<MapEntry<String, String>> visibleComplainEntries(
  String optionKey,
  Map<String, dynamic> values,
) {
  final option = complainOptionsByKey[optionKey];
  if (option == null) return const [];
  final out = <MapEntry<String, String>>[];
  for (final key in option.fieldKeys) {
    final def = complainFields[key];
    if (def == null) continue;
    if (!isFieldVisible(def, values)) continue;
    final formatted = formatHistoryValue(def, values[key]);
    if (formatted == null) continue;
    out.add(MapEntry(def.label, formatted));
  }
  return out;
}
