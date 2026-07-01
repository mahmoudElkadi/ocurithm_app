/// Dart port of the shared `@ocurithm/examination-catalog` History stage.
///
/// Source of truth lives in the backend monorepo at
/// `packages/examination-catalog/src/history/` (fields.ts, categories.ts,
/// compute.ts, version.ts). This file is a hand-maintained mirror: when the
/// backend catalog's field keys / options change, bump [historyCatalogVersion]
/// and regenerate the affected entries here. The flat [historyFields] map IS the
/// storage shape — `values: { <fieldKey>: <value> }` — and canonical keys
/// (`hba1c`, `bpSystolic`, `bpDiastolic`, `creatinine`, `egfr`) intentionally
/// recur across categories: entered once, surfaced in every referencing category.
library;

/// Field input kinds. `enumField` models Yes/No and Yes/No/Unknown as explicit
/// string options (so "No" is distinguishable from "not asked" = absent).
enum FieldKind { enumField, multiEnum, number, date, text, computed }

/// A single conditional visibility rule. An array of rules on a field is ANDed.
class ShowIfRule {
  const ShowIfRule({this.field, this.equals, this.inList, this.truthy});

  /// Sibling field key whose current value is inspected.
  final String? field;

  /// Visible when the sibling value strictly equals this.
  final Object? equals;

  /// Visible when the sibling value is one of these.
  final List<Object?>? inList;

  /// Visible when `(value is truthy) == truthy`.
  final bool? truthy;
}

class FieldDef {
  const FieldDef({
    required this.key,
    required this.kind,
    required this.label,
    this.options,
    this.unit,
    this.min,
    this.max,
    this.step,
    this.multiline = false,
    this.placeholder,
    this.showIf,
    this.computeFn,
  });

  final String key;
  final FieldKind kind;
  final String label;

  /// enum / multiEnum option values.
  final List<String>? options;

  /// number unit suffix shown next to the input, e.g. "%", "mmHg", "kg".
  final String? unit;
  final num? min;
  final num? max;
  final num? step;

  /// text fields: render a multiline input instead of a single line.
  final bool multiline;
  final String? placeholder;

  /// Field is shown only when every rule matches.
  final List<ShowIfRule>? showIf;

  /// Present iff [kind] == [FieldKind.computed]. Names a fn in [historyCompute].
  final String? computeFn;
}

/// A checkable history category and the ordered field keys it reveals.
class CategoryDef {
  const CategoryDef({
    required this.key,
    required this.label,
    required this.fieldKeys,
  });

  final String key;
  final String label;
  final List<String> fieldKeys;
}

const List<String> _yesNo = ['Yes', 'No'];
const List<String> _yesNoUnknown = ['Yes', 'No', 'Unknown'];
const List<String> _eye = ['OD', 'OS', 'OU'];

/// Bump when the catalog's field keys / options change in a way analytics tracks.
/// Must stay in sync with the backend's `HISTORY_CATALOG_VERSION`.
const int historyCatalogVersion = 1;

/// Flat, globally-unique history field definitions. Keyed by global field key.
const Map<String, FieldDef> historyFields = {
  // ── #1 Diabetes Mellitus ──
  'diabetesType': FieldDef(key: 'diabetesType', kind: FieldKind.enumField, label: 'Diabetes type', options: ['Type 1', 'Type 2', 'Gestational', 'Secondary', 'Unknown']),
  'diabetesDuration': FieldDef(key: 'diabetesDuration', kind: FieldKind.number, label: 'Duration', unit: 'years', min: 0, max: 100),
  'diabetesTreatment': FieldDef(key: 'diabetesTreatment', kind: FieldKind.enumField, label: 'Treatment', options: ['Diet only', 'Oral drugs', 'Insulin', 'GLP-1 agonist', 'SGLT2 inhibitor', 'Mixed', 'Unknown']),
  'diabetesControl': FieldDef(key: 'diabetesControl', kind: FieldKind.enumField, label: 'Control', options: ['Controlled', 'Poorly controlled', 'Unknown']),
  'hba1c': FieldDef(key: 'hba1c', kind: FieldKind.number, label: 'HbA1c', unit: '%', min: 0, max: 20, step: 0.1), // canonical (#1, #20)
  'hba1cDate': FieldDef(key: 'hba1cDate', kind: FieldKind.date, label: 'HbA1c date'),
  'fastingBloodGlucose': FieldDef(key: 'fastingBloodGlucose', kind: FieldKind.number, label: 'Fasting blood glucose', unit: 'mg/dL', min: 0, max: 1000),
  'randomBloodGlucose': FieldDef(key: 'randomBloodGlucose', kind: FieldKind.number, label: 'Random blood glucose', unit: 'mg/dL', min: 0, max: 1000),
  'diabeticNephropathy': FieldDef(key: 'diabeticNephropathy', kind: FieldKind.enumField, label: 'Diabetic nephropathy', options: _yesNoUnknown),
  'diabeticNeuropathy': FieldDef(key: 'diabeticNeuropathy', kind: FieldKind.enumField, label: 'Diabetic neuropathy', options: _yesNoUnknown),
  'diabeticFoot': FieldDef(key: 'diabeticFoot', kind: FieldKind.enumField, label: 'Diabetic foot', options: _yesNoUnknown),
  'previousDiabeticComa': FieldDef(key: 'previousDiabeticComa', kind: FieldKind.enumField, label: 'Previous diabetic coma / DKA', options: _yesNo),

  // ── #2 Hypertension ──
  'hypertensionDuration': FieldDef(key: 'hypertensionDuration', kind: FieldKind.number, label: 'Duration', unit: 'years', min: 0, max: 100),
  'hypertensionControlled': FieldDef(key: 'hypertensionControlled', kind: FieldKind.enumField, label: 'Controlled', options: _yesNoUnknown),
  'bpSystolic': FieldDef(key: 'bpSystolic', kind: FieldKind.number, label: 'BP systolic', unit: 'mmHg', min: 40, max: 300), // canonical (#2, #20)
  'bpDiastolic': FieldDef(key: 'bpDiastolic', kind: FieldKind.number, label: 'BP diastolic', unit: 'mmHg', min: 20, max: 200), // canonical (#2, #20)
  'hypertensionTreatment': FieldDef(key: 'hypertensionTreatment', kind: FieldKind.enumField, label: 'On treatment', options: _yesNo),
  'hypertensiveCrisis': FieldDef(key: 'hypertensiveCrisis', kind: FieldKind.enumField, label: 'Hypertensive crisis history', options: _yesNo),
  'hypertensionEndOrgan': FieldDef(key: 'hypertensionEndOrgan', kind: FieldKind.enumField, label: 'End-organ disease', options: ['Kidney', 'Heart', 'Stroke', 'None', 'Unknown']),

  // ── #3 Hyperlipidemia ──
  'hyperlipidemiaKnown': FieldDef(key: 'hyperlipidemiaKnown', kind: FieldKind.enumField, label: 'Known dyslipidemia', options: _yesNo),
  'hyperlipidemiaOnStatin': FieldDef(key: 'hyperlipidemiaOnStatin', kind: FieldKind.enumField, label: 'On statin', options: _yesNo),
  'hyperlipidemiaLastLDL': FieldDef(key: 'hyperlipidemiaLastLDL', kind: FieldKind.number, label: 'Last LDL', unit: 'mg/dL', min: 0, max: 1000),
  'hyperlipidemiaLastTriglycerides': FieldDef(key: 'hyperlipidemiaLastTriglycerides', kind: FieldKind.number, label: 'Last triglycerides', unit: 'mg/dL', min: 0, max: 2000),

  // ── #4 Kidney Disease ──
  'kidneyCKD': FieldDef(key: 'kidneyCKD', kind: FieldKind.enumField, label: 'CKD', options: _yesNo),
  'kidneyStage': FieldDef(key: 'kidneyStage', kind: FieldKind.enumField, label: 'Stage', options: ['1', '2', '3', '4', '5', 'Unknown']),
  'kidneyDialysis': FieldDef(key: 'kidneyDialysis', kind: FieldKind.enumField, label: 'Dialysis', options: ['No', 'Hemodialysis', 'Peritoneal dialysis']),
  'creatinine': FieldDef(key: 'creatinine', kind: FieldKind.number, label: 'Creatinine', unit: 'mg/dL', min: 0, max: 50, step: 0.1), // canonical (#4, #20)
  'egfr': FieldDef(key: 'egfr', kind: FieldKind.number, label: 'eGFR', unit: 'ml/min/1.73m²', min: 0, max: 200), // canonical (#4, #20)
  'kidneyTransplant': FieldDef(key: 'kidneyTransplant', kind: FieldKind.enumField, label: 'Kidney transplant', options: _yesNo),

  // ── #5 Cardiovascular Disease ──
  'cvdIschemic': FieldDef(key: 'cvdIschemic', kind: FieldKind.enumField, label: 'Ischemic heart disease', options: _yesNo),
  'cvdHeartFailure': FieldDef(key: 'cvdHeartFailure', kind: FieldKind.enumField, label: 'Heart failure', options: _yesNo),
  'cvdArrhythmia': FieldDef(key: 'cvdArrhythmia', kind: FieldKind.enumField, label: 'Arrhythmia', options: _yesNo),
  'cvdPreviousMI': FieldDef(key: 'cvdPreviousMI', kind: FieldKind.enumField, label: 'Previous MI', options: _yesNo),
  'cvdCardiacStent': FieldDef(key: 'cvdCardiacStent', kind: FieldKind.enumField, label: 'Cardiac stent', options: _yesNo),
  'cvdPacemaker': FieldDef(key: 'cvdPacemaker', kind: FieldKind.enumField, label: 'Pacemaker', options: _yesNo),

  // ── #6 Stroke / TIA ──
  'strokePrevious': FieldDef(key: 'strokePrevious', kind: FieldKind.enumField, label: 'Previous stroke', options: _yesNo),
  'strokeTIA': FieldDef(key: 'strokeTIA', kind: FieldKind.enumField, label: 'TIA', options: _yesNo),
  'strokeDate': FieldDef(key: 'strokeDate', kind: FieldKind.date, label: 'Date'),
  'strokeResidualWeakness': FieldDef(key: 'strokeResidualWeakness', kind: FieldKind.enumField, label: 'Residual weakness', options: _yesNo),
  'strokeOnAntithrombotic': FieldDef(key: 'strokeOnAntithrombotic', kind: FieldKind.enumField, label: 'On antiplatelet/anticoagulant', options: _yesNo),

  // ── #7 Smoking ──
  'smokingStatus': FieldDef(key: 'smokingStatus', kind: FieldKind.enumField, label: 'Status', options: ['Never', 'Current', 'Ex-smoker']),
  'cigarettesPerDay': FieldDef(key: 'cigarettesPerDay', kind: FieldKind.number, label: 'Cigarettes per day', min: 0, max: 200, showIf: [ShowIfRule(field: 'smokingStatus', inList: ['Current', 'Ex-smoker'])]),
  'smokingYears': FieldDef(key: 'smokingYears', kind: FieldKind.number, label: 'Duration', unit: 'years', min: 0, max: 100, showIf: [ShowIfRule(field: 'smokingStatus', inList: ['Current', 'Ex-smoker'])]),
  'packYears': FieldDef(key: 'packYears', kind: FieldKind.computed, label: 'Pack-years', computeFn: 'packYears', showIf: [ShowIfRule(field: 'smokingStatus', inList: ['Current', 'Ex-smoker'])]),
  'shisha': FieldDef(key: 'shisha', kind: FieldKind.enumField, label: 'Shisha', options: _yesNo),

  // ── #8 Pregnancy / Women's Health ──
  'pregnancyPregnant': FieldDef(key: 'pregnancyPregnant', kind: FieldKind.enumField, label: 'Pregnant', options: ['Yes', 'No', 'Not applicable']),
  'pregnancyTrimester': FieldDef(key: 'pregnancyTrimester', kind: FieldKind.enumField, label: 'Trimester', options: ['1st', '2nd', '3rd'], showIf: [ShowIfRule(field: 'pregnancyPregnant', equals: 'Yes')]),
  'pregnancyGestationalDiabetes': FieldDef(key: 'pregnancyGestationalDiabetes', kind: FieldKind.enumField, label: 'Gestational diabetes', options: _yesNo),
  'pregnancyPreEclampsia': FieldDef(key: 'pregnancyPreEclampsia', kind: FieldKind.enumField, label: 'Pre-eclampsia', options: _yesNo),
  'pregnancyBreastfeeding': FieldDef(key: 'pregnancyBreastfeeding', kind: FieldKind.enumField, label: 'Breastfeeding', options: _yesNo),

  // ── #9 Autoimmune / Inflammatory Disease ──
  'autoimmuneDiseaseType': FieldDef(key: 'autoimmuneDiseaseType', kind: FieldKind.enumField, label: 'Disease type', options: ['Rheumatoid arthritis', 'SLE', 'Behçet disease', 'Ankylosing spondylitis', 'Psoriasis', 'Sarcoidosis', 'IBD', 'Vasculitis', 'Giant cell arteritis', 'Multiple sclerosis', 'Other']),
  'autoimmuneActivity': FieldDef(key: 'autoimmuneActivity', kind: FieldKind.enumField, label: 'Activity', options: ['Active', 'Inactive', 'Unknown']),
  'autoimmuneOnSteroids': FieldDef(key: 'autoimmuneOnSteroids', kind: FieldKind.enumField, label: 'On steroids', options: _yesNo),
  'autoimmuneOnImmunosuppressants': FieldDef(key: 'autoimmuneOnImmunosuppressants', kind: FieldKind.enumField, label: 'On immunosuppressants', options: _yesNo),
  'autoimmuneOnBiologics': FieldDef(key: 'autoimmuneOnBiologics', kind: FieldKind.enumField, label: 'On biologics', options: _yesNo),

  // ── #10 Uveitis History ──
  'uveitisPrevious': FieldDef(key: 'uveitisPrevious', kind: FieldKind.enumField, label: 'Previous uveitis', options: _yesNo),
  'uveitisLaterality': FieldDef(key: 'uveitisLaterality', kind: FieldKind.enumField, label: 'Laterality', options: _eye),
  'uveitisType': FieldDef(key: 'uveitisType', kind: FieldKind.enumField, label: 'Type', options: ['Anterior', 'Intermediate', 'Posterior', 'Panuveitis']),
  'uveitisRecurrent': FieldDef(key: 'uveitisRecurrent', kind: FieldKind.enumField, label: 'Recurrent', options: _yesNo),
  'uveitisKnownCause': FieldDef(key: 'uveitisKnownCause', kind: FieldKind.enumField, label: 'Known cause', options: ['TB', 'Behçet', 'Sarcoid', 'HLA-B27', 'Idiopathic', 'Other']),
  'uveitisLastAttackDate': FieldDef(key: 'uveitisLastAttackDate', kind: FieldKind.date, label: 'Last attack date'),

  // ── #11 Hematological / Vascular Risk ──
  'hematoAnemia': FieldDef(key: 'hematoAnemia', kind: FieldKind.enumField, label: 'Anemia', options: _yesNo),
  'hematoSickleCell': FieldDef(key: 'hematoSickleCell', kind: FieldKind.enumField, label: 'Sickle cell disease', options: _yesNo),
  'hematoThalassemia': FieldDef(key: 'hematoThalassemia', kind: FieldKind.enumField, label: 'Thalassemia', options: _yesNo),
  'hematoHypercoagulable': FieldDef(key: 'hematoHypercoagulable', kind: FieldKind.enumField, label: 'Hypercoagulable state', options: _yesNo),
  'hematoDvtPe': FieldDef(key: 'hematoDvtPe', kind: FieldKind.enumField, label: 'DVT/PE', options: _yesNo),
  'hematoLeukemiaLymphoma': FieldDef(key: 'hematoLeukemiaLymphoma', kind: FieldKind.enumField, label: 'Leukemia/lymphoma', options: _yesNo),

  // ── #12 Infectious Disease ──
  'infectiousHepatitisB': FieldDef(key: 'infectiousHepatitisB', kind: FieldKind.enumField, label: 'Hepatitis B', options: _yesNo),
  'infectiousHepatitisC': FieldDef(key: 'infectiousHepatitisC', kind: FieldKind.enumField, label: 'Hepatitis C', options: _yesNo),
  'infectiousHIV': FieldDef(key: 'infectiousHIV', kind: FieldKind.enumField, label: 'HIV', options: _yesNo),
  'infectiousTB': FieldDef(key: 'infectiousTB', kind: FieldKind.enumField, label: 'TB', options: _yesNo),
  'infectiousSyphilis': FieldDef(key: 'infectiousSyphilis', kind: FieldKind.enumField, label: 'Syphilis', options: _yesNo),
  'infectiousHerpes': FieldDef(key: 'infectiousHerpes', kind: FieldKind.enumField, label: 'Herpes', options: _yesNo),
  'infectiousCMV': FieldDef(key: 'infectiousCMV', kind: FieldKind.enumField, label: 'CMV', options: _yesNo),

  // ── #13 Drug History ──
  'drugAnticoagulant': FieldDef(key: 'drugAnticoagulant', kind: FieldKind.enumField, label: 'Anticoagulant', options: ['Warfarin', 'Rivaroxaban', 'Apixaban', 'Dabigatran', 'Other']),
  'drugAntiplatelet': FieldDef(key: 'drugAntiplatelet', kind: FieldKind.enumField, label: 'Antiplatelet', options: ['Aspirin', 'Clopidogrel', 'Dual', 'Other']),
  'drugSteroids': FieldDef(key: 'drugSteroids', kind: FieldKind.enumField, label: 'Steroids', options: ['None', 'Topical', 'Oral', 'IV', 'Long-term']),
  'drugHydroxychloroquine': FieldDef(key: 'drugHydroxychloroquine', kind: FieldKind.enumField, label: 'Hydroxychloroquine', options: _yesNo),
  'drugTamoxifen': FieldDef(key: 'drugTamoxifen', kind: FieldKind.enumField, label: 'Tamoxifen', options: _yesNo),
  'drugEthambutol': FieldDef(key: 'drugEthambutol', kind: FieldKind.enumField, label: 'Ethambutol', options: _yesNo),
  'drugAmiodarone': FieldDef(key: 'drugAmiodarone', kind: FieldKind.enumField, label: 'Amiodarone', options: _yesNo),
  'drugPDE5': FieldDef(key: 'drugPDE5', kind: FieldKind.enumField, label: 'Sildenafil/PDE5 inhibitors', options: _yesNo),
  'drugImmunosuppressants': FieldDef(key: 'drugImmunosuppressants', kind: FieldKind.enumField, label: 'Immunosuppressants', options: ['Methotrexate', 'Azathioprine', 'Cyclosporine', 'Mycophenolate', 'Other']),

  // ── #14 Allergy ──
  'allergyDrug': FieldDef(key: 'allergyDrug', kind: FieldKind.enumField, label: 'Drug allergy', options: _yesNo),
  'allergyDrugName': FieldDef(key: 'allergyDrugName', kind: FieldKind.text, label: 'Drug name', showIf: [ShowIfRule(field: 'allergyDrug', equals: 'Yes')]),
  'allergyReaction': FieldDef(key: 'allergyReaction', kind: FieldKind.enumField, label: 'Reaction', options: ['Rash', 'Anaphylaxis', 'Swelling', 'Breathing difficulty', 'Unknown'], showIf: [ShowIfRule(field: 'allergyDrug', equals: 'Yes')]),
  'allergyContrast': FieldDef(key: 'allergyContrast', kind: FieldKind.enumField, label: 'Contrast allergy', options: _yesNo),
  'allergyLatex': FieldDef(key: 'allergyLatex', kind: FieldKind.enumField, label: 'Latex allergy', options: _yesNo),

  // ── #15 Previous Ocular Surgery ──
  'ocularSurgeryCataract': FieldDef(key: 'ocularSurgeryCataract', kind: FieldKind.enumField, label: 'Cataract surgery', options: _eye),
  'ocularSurgeryRefractive': FieldDef(key: 'ocularSurgeryRefractive', kind: FieldKind.enumField, label: 'Refractive surgery', options: ['LASIK', 'PRK', 'SMILE', 'Other']),
  'ocularSurgeryVitrectomy': FieldDef(key: 'ocularSurgeryVitrectomy', kind: FieldKind.enumField, label: 'Vitrectomy', options: _eye),
  'ocularSurgeryRetinalDetachment': FieldDef(key: 'ocularSurgeryRetinalDetachment', kind: FieldKind.enumField, label: 'Retinal detachment surgery', options: _eye),
  'ocularSurgeryGlaucoma': FieldDef(key: 'ocularSurgeryGlaucoma', kind: FieldKind.enumField, label: 'Glaucoma surgery', options: _eye),
  'ocularSurgeryCornealTransplant': FieldDef(key: 'ocularSurgeryCornealTransplant', kind: FieldKind.enumField, label: 'Corneal transplant', options: _eye),
  'ocularSurgerySquint': FieldDef(key: 'ocularSurgerySquint', kind: FieldKind.enumField, label: 'Squint surgery', options: _eye),
  'ocularSurgeryDate': FieldDef(key: 'ocularSurgeryDate', kind: FieldKind.date, label: 'Date'),
  'ocularSurgeryComplications': FieldDef(key: 'ocularSurgeryComplications', kind: FieldKind.enumField, label: 'Complications', options: _yesNoUnknown),

  // ── #16 Previous Retinal Treatment ──
  'retinalInjection': FieldDef(key: 'retinalInjection', kind: FieldKind.enumField, label: 'Previous intravitreal injection', options: _yesNo),
  'retinalInjectionEye': FieldDef(key: 'retinalInjectionEye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'retinalInjectionDrug': FieldDef(key: 'retinalInjectionDrug', kind: FieldKind.enumField, label: 'Drug', options: ['Avastin', 'Eylea', 'Lucentis', 'Vabysmo', 'Ozurdex', 'Other']),
  'retinalInjectionCount': FieldDef(key: 'retinalInjectionCount', kind: FieldKind.number, label: 'Number of injections', min: 0, max: 200),
  'retinalLastInjectionDate': FieldDef(key: 'retinalLastInjectionDate', kind: FieldKind.date, label: 'Last injection date'),
  'retinalPRP': FieldDef(key: 'retinalPRP', kind: FieldKind.enumField, label: 'Previous PRP', options: _eye),
  'retinalPRPCompletion': FieldDef(key: 'retinalPRPCompletion', kind: FieldKind.enumField, label: 'PRP completion', options: ['Complete', 'Incomplete', 'Unknown']),
  'retinalFocalLaser': FieldDef(key: 'retinalFocalLaser', kind: FieldKind.enumField, label: 'Previous focal/grid laser', options: _eye),

  // ── #17 Ocular Trauma ──
  'ocularTraumaType': FieldDef(key: 'ocularTraumaType', kind: FieldKind.enumField, label: 'Trauma', options: ['Blunt', 'Penetrating', 'Chemical', 'Foreign body', 'Other']),
  'ocularTraumaEye': FieldDef(key: 'ocularTraumaEye', kind: FieldKind.enumField, label: 'Eye', options: _eye),
  'ocularTraumaDate': FieldDef(key: 'ocularTraumaDate', kind: FieldKind.date, label: 'Date'),
  'ocularTraumaSurgeryRequired': FieldDef(key: 'ocularTraumaSurgeryRequired', kind: FieldKind.enumField, label: 'Surgery required', options: _yesNo),
  'ocularTraumaResidualDamage': FieldDef(key: 'ocularTraumaResidualDamage', kind: FieldKind.enumField, label: 'Residual damage', options: _yesNoUnknown),

  // ── #18 Family History ──
  'familyGlaucoma': FieldDef(key: 'familyGlaucoma', kind: FieldKind.enumField, label: 'Glaucoma', options: _yesNo),
  'familyDiabetes': FieldDef(key: 'familyDiabetes', kind: FieldKind.enumField, label: 'Diabetes', options: _yesNo),
  'familyAMD': FieldDef(key: 'familyAMD', kind: FieldKind.enumField, label: 'AMD', options: _yesNo),
  'familyRetinalDetachment': FieldDef(key: 'familyRetinalDetachment', kind: FieldKind.enumField, label: 'Retinal detachment', options: _yesNo),
  'familyKeratoconus': FieldDef(key: 'familyKeratoconus', kind: FieldKind.enumField, label: 'Keratoconus', options: _yesNo),
  'familyInheritedRetinal': FieldDef(key: 'familyInheritedRetinal', kind: FieldKind.enumField, label: 'Inherited retinal disease', options: _yesNo),
  'familyBlindness': FieldDef(key: 'familyBlindness', kind: FieldKind.enumField, label: 'Blindness', options: _yesNo),
  'familyConsanguinity': FieldDef(key: 'familyConsanguinity', kind: FieldKind.enumField, label: 'Consanguinity', options: _yesNo),

  // ── #20 Systemic Measurements (reuses canonical bpSystolic / bpDiastolic / hba1c / creatinine / egfr) ──
  'weight': FieldDef(key: 'weight', kind: FieldKind.number, label: 'Weight', unit: 'kg', min: 0, max: 500),
  'height': FieldDef(key: 'height', kind: FieldKind.number, label: 'Height', unit: 'cm', min: 0, max: 300),
  'bmi': FieldDef(key: 'bmi', kind: FieldKind.computed, label: 'BMI', computeFn: 'bmi'),
};

/// History categories (#1–#18, #20). #19 (Current Visit Symptoms) lives in the
/// complain stage, not here. Canonical keys recur across categories by design.
const List<CategoryDef> historyCategories = [
  CategoryDef(key: 'diabetes', label: 'Diabetes Mellitus', fieldKeys: [
    'diabetesType', 'diabetesDuration', 'diabetesTreatment', 'diabetesControl', 'hba1c', 'hba1cDate',
    'fastingBloodGlucose', 'randomBloodGlucose', 'diabeticNephropathy', 'diabeticNeuropathy', 'diabeticFoot', 'previousDiabeticComa',
  ]),
  CategoryDef(key: 'hypertension', label: 'Hypertension', fieldKeys: [
    'hypertensionDuration', 'hypertensionControlled', 'bpSystolic', 'bpDiastolic', 'hypertensionTreatment', 'hypertensiveCrisis', 'hypertensionEndOrgan',
  ]),
  CategoryDef(key: 'hyperlipidemia', label: 'Hyperlipidemia', fieldKeys: [
    'hyperlipidemiaKnown', 'hyperlipidemiaOnStatin', 'hyperlipidemiaLastLDL', 'hyperlipidemiaLastTriglycerides',
  ]),
  CategoryDef(key: 'kidneyDisease', label: 'Kidney Disease', fieldKeys: [
    'kidneyCKD', 'kidneyStage', 'kidneyDialysis', 'creatinine', 'egfr', 'kidneyTransplant',
  ]),
  CategoryDef(key: 'cardiovascular', label: 'Cardiovascular Disease', fieldKeys: [
    'cvdIschemic', 'cvdHeartFailure', 'cvdArrhythmia', 'cvdPreviousMI', 'cvdCardiacStent', 'cvdPacemaker',
  ]),
  CategoryDef(key: 'strokeTia', label: 'Stroke / TIA', fieldKeys: [
    'strokePrevious', 'strokeTIA', 'strokeDate', 'strokeResidualWeakness', 'strokeOnAntithrombotic',
  ]),
  CategoryDef(key: 'smoking', label: 'Smoking', fieldKeys: [
    'smokingStatus', 'cigarettesPerDay', 'smokingYears', 'packYears', 'shisha',
  ]),
  CategoryDef(key: 'pregnancy', label: "Pregnancy / Women's Health", fieldKeys: [
    'pregnancyPregnant', 'pregnancyTrimester', 'pregnancyGestationalDiabetes', 'pregnancyPreEclampsia', 'pregnancyBreastfeeding',
  ]),
  CategoryDef(key: 'autoimmune', label: 'Autoimmune / Inflammatory Disease', fieldKeys: [
    'autoimmuneDiseaseType', 'autoimmuneActivity', 'autoimmuneOnSteroids', 'autoimmuneOnImmunosuppressants', 'autoimmuneOnBiologics',
  ]),
  CategoryDef(key: 'uveitis', label: 'Uveitis History', fieldKeys: [
    'uveitisPrevious', 'uveitisLaterality', 'uveitisType', 'uveitisRecurrent', 'uveitisKnownCause', 'uveitisLastAttackDate',
  ]),
  CategoryDef(key: 'hematological', label: 'Hematological / Vascular Risk', fieldKeys: [
    'hematoAnemia', 'hematoSickleCell', 'hematoThalassemia', 'hematoHypercoagulable', 'hematoDvtPe', 'hematoLeukemiaLymphoma',
  ]),
  CategoryDef(key: 'infectious', label: 'Infectious Disease', fieldKeys: [
    'infectiousHepatitisB', 'infectiousHepatitisC', 'infectiousHIV', 'infectiousTB', 'infectiousSyphilis', 'infectiousHerpes', 'infectiousCMV',
  ]),
  CategoryDef(key: 'drugHistory', label: 'Drug History', fieldKeys: [
    'drugAnticoagulant', 'drugAntiplatelet', 'drugSteroids', 'drugHydroxychloroquine', 'drugTamoxifen', 'drugEthambutol', 'drugAmiodarone', 'drugPDE5', 'drugImmunosuppressants',
  ]),
  CategoryDef(key: 'allergy', label: 'Allergy', fieldKeys: [
    'allergyDrug', 'allergyDrugName', 'allergyReaction', 'allergyContrast', 'allergyLatex',
  ]),
  CategoryDef(key: 'ocularSurgery', label: 'Previous Ocular Surgery', fieldKeys: [
    'ocularSurgeryCataract', 'ocularSurgeryRefractive', 'ocularSurgeryVitrectomy', 'ocularSurgeryRetinalDetachment',
    'ocularSurgeryGlaucoma', 'ocularSurgeryCornealTransplant', 'ocularSurgerySquint', 'ocularSurgeryDate', 'ocularSurgeryComplications',
  ]),
  CategoryDef(key: 'retinalTreatment', label: 'Previous Retinal Treatment', fieldKeys: [
    'retinalInjection', 'retinalInjectionEye', 'retinalInjectionDrug', 'retinalInjectionCount',
    'retinalLastInjectionDate', 'retinalPRP', 'retinalPRPCompletion', 'retinalFocalLaser',
  ]),
  CategoryDef(key: 'ocularTrauma', label: 'Ocular Trauma', fieldKeys: [
    'ocularTraumaType', 'ocularTraumaEye', 'ocularTraumaDate', 'ocularTraumaSurgeryRequired', 'ocularTraumaResidualDamage',
  ]),
  CategoryDef(key: 'familyHistory', label: 'Family History', fieldKeys: [
    'familyGlaucoma', 'familyDiabetes', 'familyAMD', 'familyRetinalDetachment', 'familyKeratoconus', 'familyInheritedRetinal', 'familyBlindness', 'familyConsanguinity',
  ]),
  CategoryDef(key: 'systemicMeasurements', label: 'Systemic Measurements', fieldKeys: [
    'weight', 'height', 'bmi', 'bpSystolic', 'bpDiastolic', 'hba1c', 'creatinine', 'egfr',
  ]),
];

num? _toNum(Object? v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v.trim());
  return null;
}

/// BMI = kg / m², rounded to 1 decimal. Mirrors backend `compute.ts`.
num? _bmi(Map<String, dynamic> v) {
  final kg = _toNum(v['weight']);
  final cm = _toNum(v['height']);
  if (kg == null || cm == null || cm <= 0) return null;
  final m = cm / 100;
  return (kg / (m * m) * 10).round() / 10;
}

/// Pack-years = (cigarettes/day / 20) * years, rounded to 1 decimal.
num? _packYears(Map<String, dynamic> v) {
  final perDay = _toNum(v['cigarettesPerDay']);
  final years = _toNum(v['smokingYears']);
  if (perDay == null || years == null) return null;
  return (perDay / 20 * years * 10).round() / 10;
}

/// Named compute functions, referenced by [FieldDef.computeFn]. History only.
final Map<String, num? Function(Map<String, dynamic>)> historyCompute = {
  'bmi': _bmi,
  'packYears': _packYears,
};

bool _matchRule(ShowIfRule rule, Object? value) {
  if (rule.equals != null) return value == rule.equals;
  if (rule.inList != null) return rule.inList!.contains(value);
  if (rule.truthy != null) {
    final isTruthy = value != null && value != false && value != '' && value != 0;
    return isTruthy == rule.truthy;
  }
  return true;
}

/// A field with no [FieldDef.showIf] is always visible; otherwise every rule
/// (ANDed) must match against the flat [values] map. Mirrors `visibility.ts`.
bool isFieldVisible(FieldDef def, Map<String, dynamic>? values) {
  final rules = def.showIf;
  if (rules == null || rules.isEmpty) return true;
  final v = values ?? const {};
  return rules.every((rule) => _matchRule(rule, rule.field == null ? null : v[rule.field]));
}

/// Recompute every `computed` field from its inputs (UX preview; the backend
/// recomputes authoritatively on save). Removes a key whose result is null.
void recomputeHistory(Map<String, dynamic> values) {
  for (final def in historyFields.values) {
    if (def.kind != FieldKind.computed || def.computeFn == null) continue;
    final fn = historyCompute[def.computeFn];
    final result = fn?.call(values);
    if (result == null) {
      values.remove(def.key);
    } else {
      values[def.key] = result;
    }
  }
}

/// Human-readable value for read views: appends the unit, joins multiEnum lists,
/// and shows dates as their stored (yyyy-MM-dd) string. Returns null for empty.
String? formatHistoryValue(FieldDef def, Object? value) {
  if (value == null) return null;
  if (value is List) {
    if (value.isEmpty) return null;
    return value.join(', ');
  }
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  return def.unit != null ? '$s ${def.unit}' : s;
}

/// Ordered (label, formatted-value) pairs for a category's currently-visible,
/// non-empty fields. Unknown keys (catalog drift) are skipped here; callers that
/// need to surface drift can iterate the raw `values` map directly.
List<MapEntry<String, String>> visibleHistoryEntries(
  String categoryKey,
  Map<String, dynamic> values,
) {
  final category = historyCategories.firstWhere((c) => c.key == categoryKey,
      orElse: () => const CategoryDef(key: '', label: '', fieldKeys: []));
  final out = <MapEntry<String, String>>[];
  for (final key in category.fieldKeys) {
    final def = historyFields[key];
    if (def == null) continue;
    if (!isFieldVisible(def, values)) continue;
    final formatted = formatHistoryValue(def, values[key]);
    if (formatted == null) continue;
    out.add(MapEntry(def.label, formatted));
  }
  return out;
}

/// Label for a category key (falls back to the key itself if unknown).
String historyCategoryLabel(String categoryKey) {
  return historyCategories
      .firstWhere((c) => c.key == categoryKey,
          orElse: () => CategoryDef(key: categoryKey, label: categoryKey, fieldKeys: const []))
      .label;
}
