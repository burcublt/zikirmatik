class ZikrDefinition {
  const ZikrDefinition({
    required this.id,
    required this.title,
    required this.defaultTarget,
    required this.createdAt,
    required this.updatedAt,
    this.arabicText,
    this.description,
    this.isBuiltIn = false,
    this.isArchived = false,
    this.isFavorite = false,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String? arabicText;
  final String? description;
  final int defaultTarget;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBuiltIn;
  final bool isArchived;
  final bool isFavorite;
  final int sortOrder;

  ZikrDefinition copyWith({
    String? title,
    String? arabicText,
    String? description,
    int? defaultTarget,
    DateTime? updatedAt,
    bool clearArabicText = false,
    bool? isFavorite,
    bool clearDescription = false,
  }) {
    return ZikrDefinition(
      id: id,
      title: title ?? this.title,
      arabicText: clearArabicText ? null : (arabicText ?? this.arabicText),
      description: clearDescription ? null : (description ?? this.description),
      defaultTarget: defaultTarget ?? this.defaultTarget,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBuiltIn: isBuiltIn,
      isArchived: isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
      sortOrder: sortOrder,
    );
  }
}
