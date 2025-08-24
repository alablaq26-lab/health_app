import 'models.dart';

final appointments = <Appointment>[
  Appointment(
    dept: "OMFS 2",
    hospital: "Sohar Hospital",
    dateTime: DateTime(2025, 8, 10, 11, 50),
    status: AppointmentStatus.confirmed,
  ),
];

final prescriptionGroups = <PrescriptionGroup>[
  PrescriptionGroup(
    visit: Visit(
      at: DateTime(2025, 7, 30, 9, 54),
      location: "Saham Extended Health Center (PolyClinic)",
    ),
    meds: [
      Medication(
        name: "Chlorhexidine",
        instructions: "Gargle 0.2 %, 3 times a day for 5 days",
        completed: true,
      ),
      Medication(
        name: "Paracetamol",
        instructions: "Take 1000.0 Mg, 4 times a day for 3 days",
        completed: true,
      ),
      Medication(
        name: "Ibuprofen",
        instructions: "Take 400.0 Mg, 3 times a day for 3 days",
        completed: true,
      ),
    ],
  ),
  PrescriptionGroup(
    visit: Visit(
      at: DateTime(2025, 7, 30, 9, 54),
      location: "Saham Extended Health Center (PolyClinic)",
    ),
    meds: [
      Medication(
        name: "Amoxyclav",
        instructions: "Take 625.0 Mg, 3 times a day for 5 days",
        completed: true,
      ),
    ],
  ),
];

final labTests = <LabTest>[
  LabTest(
    title: "CBC, Panel",
    visit: Visit(
      at: DateTime(2025, 7, 6, 7, 23),
      location: "Saham Extended Health Center (PolyClinic)",
    ),
    doctor: "Rayyan Ahmed Rashid Al-Badi",
    completed: true,
    components: [
      LabComponent(
        name: "Haemoglobin in Blood",
        value: "11.8 g/dL",
        range: "14.5 / 11",
      ),
      LabComponent(
        name: "Lymphocytes % in Blood",
        value: "46.1 %",
        range: "45 / 18",
        abnormal: true,
      ),
      LabComponent(
        name: "Mean Cell Volume",
        value: "72.9 fL",
        range: "95 / 78",
        abnormal: true,
      ),
    ],
  ),
  LabTest(
    title: "Lipid Profile, Panel",
    visit: Visit(
      at: DateTime(2025, 7, 6, 7, 23),
      location: "Saham Extended Health Center (PolyClinic)",
    ),
    doctor: "Rayyan Ahmed Rashid Al-Badi",
    completed: true,
    components: [],
  ),
  LabTest(
    title: "Urea and Electrolytes and GFR, Panel",
    visit: Visit(
      at: DateTime(2025, 7, 6, 7, 23),
      location: "Saham Extended Health Center (PolyClinic)",
    ),
    doctor: "Rayyan Ahmed Rashid Al-Badi",
    completed: true,
    components: [],
  ),
  LabTest(
    title: "Urine Analysis",
    visit: Visit(
      at: DateTime(2025, 7, 6, 7, 23),
      location: "Saham Extended Health Center (PolyClinic)",
    ),
    doctor: "Rayyan Ahmed Rashid Al-Badi",
    completed: false,
    components: [],
  ),
];

final procedures = <ProcedureItem>[
  ProcedureItem(
    title: "Nursing Procedure",
    visit: Visit(
      at: DateTime(2023, 5, 30, 2, 1, 6),
      location: "Sohar Hospital",
    ),
    notes: [
      "Intramuscular injection: Inj Olfen 75mg IM given in right gluteal muscle. Patient left clinic in stable condition.",
      "27/09/2022 8:13am – ECG (REST): ECG done as doctor order.",
      "27/09/2022 8:12am – RBS 5.6 mmol/L.",
      "26/07/2022 – GRBS=6.1 mmol/l, SpO2=100%, HR=110, BP=142/80 mmHg. Advised to consult doctor.",
    ],
  ),
];

final hospitals = <Hospital>[
  Hospital(name: "Saham Extended Health Center (PolyClinic)", id: "53517"),
  Hospital(name: "Sohar Hospital", id: "769372"),
];

/// NEW: المستشفيات الخاصة التي زارها المريض (ضع أمثلة أو اتركها فاضية)
final privateHospitalsVisited = <Hospital>[
  // مثال:
  // Hospital(name: "Starcare Hospital", id: "PRV-001"),
  // Hospital(name: "Burjeel Medical Center", id: "PRV-002"),
];
