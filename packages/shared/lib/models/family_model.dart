import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a family group in the StudyGuardian AI system.
///
/// A family links parent and child users together, enabling parents
/// to monitor child devices. The [pairingCode] is used during the
/// initial device setup to associate a child device with the family.
class FamilyModel {
  /// Unique identifier for this family.
  final String id;

  /// Display name of the family (e.g., "Sharma Family").
  final String name;

  /// A short code used to pair new child devices to this family.
  final String pairingCode;

  /// Timestamp when this family was created.
  final DateTime createdAt;

  /// List of user IDs for parents in this family.
  final List<String> parentIds;

  /// List of user IDs for children in this family.
  final List<String> childIds;

  /// The user ID of the primary parent (family administrator).
  /// The primary parent has full control over settings and can manage
  /// secondary parents.
  final String primaryParentId;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.pairingCode,
    required this.createdAt,
    this.parentIds = const [],
    this.childIds = const [],
    required this.primaryParentId,
  });

  /// Total number of members (parents + children) in the family.
  int get memberCount => parentIds.length + childIds.length;

  /// Whether the family has at least one parent and one child.
  bool get isComplete => parentIds.isNotEmpty && childIds.isNotEmpty;

  /// Whether the given user ID belongs to a parent in this family.
  bool isParent(String userId) => parentIds.contains(userId);

  /// Whether the given user ID belongs to a child in this family.
  bool isChild(String userId) => childIds.contains(userId);

  /// Whether the given user ID is a member of this family.
  bool isMember(String userId) =>
      parentIds.contains(userId) || childIds.contains(userId);

  /// Whether the given user ID is the primary parent.
  bool isPrimaryParent(String userId) => userId == primaryParentId;

  /// Creates a [FamilyModel] from a Firestore [DocumentSnapshot].
  factory FamilyModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FamilyModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      pairingCode: data['pairingCode'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      parentIds: List<String>.from(data['parentIds'] as List? ?? []),
      childIds: List<String>.from(data['childIds'] as List? ?? []),
      primaryParentId: data['primaryParentId'] as String? ?? '',
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'pairingCode': pairingCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'parentIds': parentIds,
      'childIds': childIds,
      'primaryParentId': primaryParentId,
    };
  }

  /// Creates a [FamilyModel] from a plain JSON map.
  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pairingCode: json['pairingCode'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      parentIds: List<String>.from(json['parentIds'] as List? ?? []),
      childIds: List<String>.from(json['childIds'] as List? ?? []),
      primaryParentId: json['primaryParentId'] as String? ?? '',
    );
  }

  /// Converts this model to a plain JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pairingCode': pairingCode,
      'createdAt': createdAt.toIso8601String(),
      'parentIds': parentIds,
      'childIds': childIds,
      'primaryParentId': primaryParentId,
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  FamilyModel copyWith({
    String? id,
    String? name,
    String? pairingCode,
    DateTime? createdAt,
    List<String>? parentIds,
    List<String>? childIds,
    String? primaryParentId,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pairingCode: pairingCode ?? this.pairingCode,
      createdAt: createdAt ?? this.createdAt,
      parentIds: parentIds ?? this.parentIds,
      childIds: childIds ?? this.childIds,
      primaryParentId: primaryParentId ?? this.primaryParentId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FamilyModel(id: $id, name: $name, pairingCode: $pairingCode, '
      'parents: ${parentIds.length}, children: ${childIds.length})';
}
