/// Measurements Standardization V1 — the 8 upgraded findings option lists.
///
/// Verbatim from `Examination Form Standardization V1.docx` ("Section A"), matching
/// the web app's `measurements-constants.ts`. These replace the older, smaller
/// lists that were loaded from `assets/files/autoref.json`. All 8 are multi-select
/// and allow a free-text "Other" (custom input); no literal "Other" entry is
/// included — the custom-input box IS "Other". `fundusVessels` is intentionally
/// left on its original list (out of V1 scope).
library;

/// Lens Status → schema `lens`.
const List<String> lensV1 = [
  'Clear',
  'NS Grade 1',
  'NS Grade 2',
  'NS Grade 3',
  'NS Grade 4',
  'Cortical Grade 1',
  'Cortical Grade 2',
  'Cortical Grade 3',
  'Cortical Grade 4',
  'PSC Grade 1',
  'PSC Grade 2',
  'PSC Grade 3',
  'PSC Grade 4',
  'Mixed Cataract',
  'Pseudophakia',
  'Aphakia',
  'Posterior Capsular Opacity',
];

/// Vitreous Status → schema `anteriorVitreous`. Selecting "Vitreous Hemorrhage"
/// reveals the VH Grade field.
const List<String> anteriorVitreousV1 = [
  'Clear',
  'PVD',
  'Vitreous Syneresis',
  'Asteroid Hyalosis',
  'Vitritis',
  'Vitreous Hemorrhage',
  'Silicone Oil',
  'Gas',
];

/// Disc Appearance → schema `fundusOpticDisc`. Has an adjacent Cup Disc Ratio field.
const List<String> fundusOpticDiscV1 = [
  'Normal',
  'Tilted Disc',
  'Myopic Disc',
  'Crowded Disc',
  'Disc Drusen',
  'Optic Atrophy',
  'Temporal Pallor',
  'Sectoral Pallor',
  'Disc Edema',
  'Papilledema',
  'Glaucomatous Cupping',
  'Coloboma',
  'Hypoplastic Disc',
];

/// Macular Findings → schema `fundusMacula`.
const List<String> fundusMaculaV1 = [
  'Normal',
  'Hard Exudates',
  'DME',
  'ERM',
  'VMT',
  'Lamellar Hole',
  'Full Thickness Macular Hole',
  'Pseudohole',
  'Geographic Atrophy',
  'Macular Scar',
  'CNV',
  'CSR',
  'Macular Ischemia',
  'Subretinal Fibrosis',
];

/// Retina → schema `fundusPeriphery` (relabeled "Retina").
const List<String> fundusPeripheryV1 = [
  'Normal',
  'Microaneurysms',
  'Dot Blot Hemorrhages',
  'Flame Hemorrhages',
  'Hard Exudates',
  'Cotton Wool Spots',
  'Venous Beading',
  'IRMA',
  'NVD',
  'NVE',
  'Fibrovascular Proliferation',
  'Laser Scars',
  'PRP Scars',
  'Chorioretinal Scar',
  'Lattice Degeneration',
  'Retinal Tear',
  'Retinal Hole',
  'Retinal Detachment',
  'TRD',
  'RRD',
  'Exudative RD',
];

/// Corneal Findings → schema `cornea`.
const List<String> corneaV1 = [
  'Normal',
  'Dry Eye',
  'SPK',
  'Corneal Scar',
  'Corneal Ulcer',
  'Keratitis',
  'Corneal Edema',
  'Keratoconus',
  'Guttata',
  'Pterygium',
  'Pinguecula',
];

/// Anterior Chamber → schema `anteriorChamber`.
const List<String> anteriorChamberV1 = [
  'Normal',
  'Shallow',
  'Deep',
  'Cells',
  'Flare',
  'Hypopyon',
  'Hyphema',
];

/// Iris Findings → schema `iris`.
const List<String> irisV1 = [
  'Normal',
  'NVI',
  'Atrophy',
  'Synechiae',
  'Coloboma',
  'Heterochromia',
];

/// VH Grade options — shown only when `anteriorVitreous` includes "Vitreous Hemorrhage".
const List<String> vhGradeOptions = ['Mild', 'Moderate', 'Severe', 'Dense'];

/// The value in `anteriorVitreous` that reveals the VH Grade field.
const String vitreousHemorrhageOption = 'Vitreous Hemorrhage';

/// Cup Disc Ratio numeric bounds.
const double cupDiscRatioMin = 0.0;
const double cupDiscRatioMax = 1.0;
