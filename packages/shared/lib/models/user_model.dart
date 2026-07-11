import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the StudyGuardian AI system.
///
/// A user can be either a parent (monitor) or a child (monitored device user).
/// Each user is associated with a Firebase Authentication account and may have
/// multiple FCM tokens for push notifications across devices.
class UserModel {
  /// Unique identifier (matches Firebase Auth UID).
  final String id;

  /// User's email address.
  final String email;

  /// User's display name.
  final String displayName;

  /// URL to the user's profile photo, if available.
  final String? photoUrl;

  /// Role of the user: `'parent'` or `'child'`.
  final String role;

  /// Timestamp when the user account was created.
  final DateTime createdAt;

  /// List of Firebase Cloud Messaging tokens for push notifications.
  final List<String> fcmTokens;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.fcmTokens = const [],
  });

  /// Whether this user has the parent role.
  bool get isParent => role == 'parent';

  /// Whether this user has the child role.
  bool get isChild => role == 'child';

  /// Creates a [UserModel] from a Firestore [DocumentSnapshot].
  ///
  /// The document ID is used as the user [id]. Returns a model with
  /// sensible defaults for any missing fields.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'child',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmTokens: List<String>.from(data['fcmTokens'] as List? ?? []),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  ///
  /// [DateTime] values are converted to [Timestamp] for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmTokens': fcmTokens,
    };
  }

  /// Creates a [UserModel] from a plain JSON map.
  ///
  /// Suitable for REST API responses or local storage deserialization.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? 'child',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      fcmTokens: List<String>.from(json['fcmTokens'] as List? ?? []),
    );
  }

  /// Converts this model to a plain JSON map.
  ///
  /// [DateTime] values are serialized as ISO 8601 strings.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'fcmTokens': fcmTokens,
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    List<String>? fcmTokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          role == other.role;

  @override
  int get hashCode => Object.hash(id, email, displayName, photoUrl, role);

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, displayName: $displayName, role: $role)';
}
