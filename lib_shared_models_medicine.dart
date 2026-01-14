class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String?  description;
  final List<String> times; // Times in HH:mm format
  final DateTime createdAt;
  final bool isActive;

  Medicine({
    required this. id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.description,
    required this.times,
    required this.createdAt,
    this.isActive = true,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String?  description,
    List<String>? times,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      description: description ?? this.description,
      times: times ?? this. times,
      createdAt:  createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'description':  description,
      'times': times,
      'createdAt':  createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      description: map['description'],
      times: List<String>.from(map['times'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
    );
  }
}