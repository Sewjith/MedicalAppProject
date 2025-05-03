// Medicines which fetched from supabase table
class SupabaseMedicine {
  final String id;
  final String name;
  final String? type;

  SupabaseMedicine({required this.id, required this.name, this.type});

  factory SupabaseMedicine.fromMap(Map<String, dynamic> map) {
    return SupabaseMedicine(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String?,
    );
  }
}

// Medicines whic selected by the doctor for the prescription
class SelectedMedicine {
  final String medicineId;
  final String medicineName;
  String dosage;
  String frequency;
  int duration;
  String instructions;

  SelectedMedicine({
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = "",
  });
}
