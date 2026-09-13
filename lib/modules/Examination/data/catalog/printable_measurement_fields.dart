/// The measurement fields a doctor can choose to print alongside a prescription,
/// grouped and labelled the way the examination form reads.
///
/// Mirrors the web app's `PRINT_MEASUREMENT_GROUPS`
/// (`apps/web/src/components/admin/ExaminationDialog/measurement-groups.ts`) so a
/// printout says the same thing on both platforms.
library;

import '../../../Patient/data/model/one_exam.dart';

class PrintableMeasurementField {
  const PrintableMeasurementField({
    required this.key,
    required this.label,
    required this.read,
  });

  /// Schema field name, used as the stable identity for selection.
  final String key;
  final String label;
  final dynamic Function(Measurement) read;
}

class PrintableMeasurementGroup {
  const PrintableMeasurementGroup({required this.title, required this.fields});

  final String title;
  final List<PrintableMeasurementField> fields;
}

const List<PrintableMeasurementGroup> printableMeasurementGroups = [
  PrintableMeasurementGroup(title: 'Old Glasses', fields: [
    PrintableMeasurementField(
        key: 'oldSpherical', label: 'Spherical', read: _oldSpherical),
    PrintableMeasurementField(
        key: 'oldCylindrical', label: 'Cylindrical', read: _oldCylindrical),
    PrintableMeasurementField(key: 'oldAxis', label: 'Axis', read: _oldAxis),
    PrintableMeasurementField(
        key: 'oldGlassesVa', label: 'VA', read: _oldGlassesVa),
  ]),
  PrintableMeasurementGroup(title: 'Autorefraction', fields: [
    PrintableMeasurementField(
        key: 'autorefSpherical', label: 'Spherical', read: _autorefSpherical),
    PrintableMeasurementField(
        key: 'autorefCylindrical',
        label: 'Cylindrical',
        read: _autorefCylindrical),
    PrintableMeasurementField(
        key: 'autorefAxis', label: 'Axis', read: _autorefAxis),
  ]),
  PrintableMeasurementGroup(title: 'Cycloplegic Refraction', fields: [
    PrintableMeasurementField(
        key: 'cycloplegicSpherical',
        label: 'Spherical',
        read: _cycloplegicSpherical),
    PrintableMeasurementField(
        key: 'cycloplegicCylindrical',
        label: 'Cylindrical',
        read: _cycloplegicCylindrical),
    PrintableMeasurementField(
        key: 'cycloplegicAxis', label: 'Axis', read: _cycloplegicAxis),
  ]),
  PrintableMeasurementGroup(title: 'Refined Refraction', fields: [
    PrintableMeasurementField(
        key: 'refinedRefractionSpherical',
        label: 'Spherical',
        read: _refinedSpherical),
    PrintableMeasurementField(
        key: 'refinedRefractionCylindrical',
        label: 'Cylindrical',
        read: _refinedCylindrical),
    PrintableMeasurementField(
        key: 'refinedRefractionAxis', label: 'Axis', read: _refinedAxis),
    PrintableMeasurementField(
        key: 'nearVisionAddition', label: 'N', read: _nearVisionAddition),
  ]),
  PrintableMeasurementGroup(title: 'Visual Acuity', fields: [
    PrintableMeasurementField(key: 'ucva', label: 'UCVA', read: _ucva),
    PrintableMeasurementField(key: 'bcva', label: 'BCVA', read: _bcva),
  ]),
  PrintableMeasurementGroup(title: 'IOP', fields: [
    PrintableMeasurementField(key: 'iop', label: 'IOP', read: _iop),
    PrintableMeasurementField(
        key: 'meansOfMeasurement',
        label: 'Measurement Method',
        read: _meansOfMeasurement),
    PrintableMeasurementField(
        key: 'acquireAnotherIOPMeasurement',
        label: 'Additional IOP',
        read: _additionalIop),
  ]),
  PrintableMeasurementGroup(title: 'Pupils', fields: [
    PrintableMeasurementField(
        key: 'pupilsShape', label: 'Shape', read: _pupilsShape),
    PrintableMeasurementField(
        key: 'pupilsLightReflexTest',
        label: 'Light Reflex',
        read: _pupilsLightReflex),
    PrintableMeasurementField(
        key: 'pupilsNearReflexTest',
        label: 'Near Reflex',
        read: _pupilsNearReflex),
    PrintableMeasurementField(
        key: 'pupilsSwingingFlashLightTest',
        label: 'Swinging Test',
        read: _pupilsSwinging),
    PrintableMeasurementField(
        key: 'pupilsOtherDisorders',
        label: 'Other Disorders',
        read: _pupilsOtherDisorders),
  ]),
  PrintableMeasurementGroup(title: 'Eyelid & Physical', fields: [
    PrintableMeasurementField(
        key: 'eyelidPtosis', label: 'Ptosis', read: _eyelidPtosis),
    PrintableMeasurementField(
        key: 'eyelidLagophthalmos',
        label: 'Lagophthalmos',
        read: _eyelidLagophthalmos),
    PrintableMeasurementField(
        key: 'palpableLymphNodes',
        label: 'Lymph Nodes',
        read: _palpableLymphNodes),
    PrintableMeasurementField(
        key: 'palpableTemporalArtery',
        label: 'Temporal Artery',
        read: _palpableTemporalArtery),
    PrintableMeasurementField(
        key: 'exophthalmometry',
        label: 'Exophthalmometry',
        read: _exophthalmometry),
  ]),
  PrintableMeasurementGroup(title: 'Eye Structure', fields: [
    PrintableMeasurementField(key: 'cornea', label: 'Cornea', read: _cornea),
    PrintableMeasurementField(
        key: 'anteriorChamber',
        label: 'Anterior Chamber',
        read: _anteriorChamber),
    PrintableMeasurementField(key: 'iris', label: 'Iris', read: _iris),
    PrintableMeasurementField(key: 'lens', label: 'Lens', read: _lens),
    PrintableMeasurementField(
        key: 'anteriorVitreous',
        label: 'Anterior Vitreous',
        read: _anteriorVitreous),
  ]),
  PrintableMeasurementGroup(title: 'Fundus Examination', fields: [
    PrintableMeasurementField(
        key: 'fundusOpticDisc', label: 'Optic Disc', read: _fundusOpticDisc),
    PrintableMeasurementField(
        key: 'fundusMacula', label: 'Macula', read: _fundusMacula),
    PrintableMeasurementField(
        key: 'fundusVessels', label: 'Vessels', read: _fundusVessels),
    PrintableMeasurementField(
        key: 'fundusPeriphery', label: 'Periphery', read: _fundusPeriphery),
  ]),
  PrintableMeasurementGroup(title: 'External Features', fields: [
    PrintableMeasurementField(key: 'lids', label: 'Lids', read: _lids),
    PrintableMeasurementField(key: 'lashes', label: 'Lashes', read: _lashes),
    PrintableMeasurementField(key: 'sclera', label: 'Sclera', read: _sclera),
    PrintableMeasurementField(
        key: 'conjunctiva', label: 'Conjunctiva', read: _conjunctiva),
    PrintableMeasurementField(
        key: 'lacrimalSystem',
        label: 'Lacrimal System',
        read: _lacrimalSystem),
  ]),
];

/// Selection identity: an eye plus a field key, e.g. `Right.refinedRefractionAxis`.
String printableFieldId(String eye, String fieldKey) => '$eye.$fieldKey';

class ResolvedPrintableField {
  const ResolvedPrintableField({
    required this.eye,
    required this.group,
    required this.label,
    required this.value,
  });

  final String eye;
  final String group;
  final String label;
  final String value;
}

/// Renders a stored measurement for print. Lists join with " - "; the three
/// "not recorded" markers used across the platform (empty, `-`, and null) all
/// resolve to null so they can be left off the page.
String? formatPrintableMeasurementValue(dynamic value) {
  if (value == null) return null;

  if (value is List) {
    final parts = value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(' - ');
  }

  final text = value.toString().trim();
  if (text.isEmpty || text == '-') return null;
  return text;
}

/// Resolve the selected field ids against an examination's measurements, dropping
/// anything with no reading rather than printing it as a dash.
List<ResolvedPrintableField> resolvePrintableFields(
  Set<String> selectedIds,
  List<Measurement> measurements,
) {
  if (selectedIds.isEmpty) return const [];

  final resolved = <ResolvedPrintableField>[];

  for (final eye in const ['Right', 'Left']) {
    Measurement? measurement;
    for (final candidate in measurements) {
      if (candidate.eye?.toLowerCase() == eye.toLowerCase()) {
        measurement = candidate;
        break;
      }
    }
    if (measurement == null) continue;

    for (final group in printableMeasurementGroups) {
      for (final field in group.fields) {
        if (!selectedIds.contains(printableFieldId(eye, field.key))) continue;

        final value = formatPrintableMeasurementValue(field.read(measurement));
        if (value == null) continue;

        resolved.add(ResolvedPrintableField(
          eye: eye,
          group: group.title,
          label: field.label,
          value: value,
        ));
      }
    }
  }

  return resolved;
}

// Top-level accessors: `const` group definitions cannot hold closures.
dynamic _oldSpherical(Measurement m) => m.oldSpherical;
dynamic _oldCylindrical(Measurement m) => m.oldCylindrical;
dynamic _oldAxis(Measurement m) => m.oldAxis;
dynamic _oldGlassesVa(Measurement m) => m.oldGlassesVa;
dynamic _autorefSpherical(Measurement m) => m.autorefSpherical;
dynamic _cycloplegicSpherical(Measurement m) => m.cycloplegicSpherical;
dynamic _cycloplegicCylindrical(Measurement m) => m.cycloplegicCylindrical;
dynamic _cycloplegicAxis(Measurement m) => m.cycloplegicAxis;
dynamic _autorefCylindrical(Measurement m) => m.autorefCylindrical;
dynamic _autorefAxis(Measurement m) => m.autorefAxis;
dynamic _refinedSpherical(Measurement m) => m.refinedRefractionSpherical;
dynamic _refinedCylindrical(Measurement m) => m.refinedRefractionCylindrical;
dynamic _refinedAxis(Measurement m) => m.refinedRefractionAxis;
dynamic _nearVisionAddition(Measurement m) => m.nearVisionAddition;
dynamic _ucva(Measurement m) => m.ucva;
dynamic _bcva(Measurement m) => m.bcva;
dynamic _iop(Measurement m) => m.iop;
dynamic _meansOfMeasurement(Measurement m) => m.meansOfMeasurement;
dynamic _additionalIop(Measurement m) => m.acquireAnotherIopMeasurement;
dynamic _pupilsShape(Measurement m) => m.pupilsShape;
dynamic _pupilsLightReflex(Measurement m) => m.pupilsLightReflexTest;
dynamic _pupilsNearReflex(Measurement m) => m.pupilsNearReflexTest;
dynamic _pupilsSwinging(Measurement m) => m.pupilsSwingingFlashLightTest;
dynamic _pupilsOtherDisorders(Measurement m) => m.pupilsOtherDisorders;
dynamic _eyelidPtosis(Measurement m) => m.eyelidPtosis;
dynamic _eyelidLagophthalmos(Measurement m) => m.eyelidLagophthalmos;
dynamic _palpableLymphNodes(Measurement m) => m.palpableLymphNodes;
dynamic _palpableTemporalArtery(Measurement m) => m.palpableTemporalArtery;
dynamic _exophthalmometry(Measurement m) => m.exophthalmometry;
dynamic _cornea(Measurement m) => m.cornea;
dynamic _anteriorChamber(Measurement m) => m.anteriorChamber;
dynamic _iris(Measurement m) => m.iris;
dynamic _lens(Measurement m) => m.lens;
dynamic _anteriorVitreous(Measurement m) => m.anteriorVitreous;
dynamic _fundusOpticDisc(Measurement m) => m.fundusOpticDisc;
dynamic _fundusMacula(Measurement m) => m.fundusMacula;
dynamic _fundusVessels(Measurement m) => m.fundusVessels;
dynamic _fundusPeriphery(Measurement m) => m.fundusPeriphery;
dynamic _lids(Measurement m) => m.lids;
dynamic _lashes(Measurement m) => m.lashes;
dynamic _sclera(Measurement m) => m.sclera;
dynamic _conjunctiva(Measurement m) => m.conjunctiva;
dynamic _lacrimalSystem(Measurement m) => m.lacrimalSystem;
