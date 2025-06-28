import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? userId;
  String? email;
  String? displayName;
  DateTime? joinDate;
  String? dateOfBirth;
  String? profilePictureUrl;
  String? phoneNumber;
  String? address;
  String? bio;
  int? coins;
  DateTime? dailyCoinsLastClaimed;

  UserModel({
    this.userId,
    this.email,
    this.displayName,
    this.joinDate,
    this.dateOfBirth,
    this.profilePictureUrl,
    this.phoneNumber,
    this.address,
    this.bio,
    this.coins,
    this.dailyCoinsLastClaimed,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'join_date': joinDate != null ? Timestamp.fromDate(joinDate!) : null,
      'date_of_birth': dateOfBirth,
      'profile_picture_url': profilePictureUrl,
      'phone_number': phoneNumber,
      'address': address,
      'bio': bio,
      'coins': coins,
      'daily_coins_last_claimed': dailyCoinsLastClaimed != null
          ? Timestamp.fromDate(dailyCoinsLastClaimed!)
          : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as String?,
      email: map['email'] as String?,
      displayName: map['display_name'] as String?,
      joinDate: map['join_date'] != null
          ? (map['join_date'] as Timestamp).toDate()
          : null,
      dateOfBirth: map['date_of_birth'] as String?,
      profilePictureUrl: map['profile_picture_url'] as String?,
      phoneNumber: map['phone_number'] as String?,
      address: map['address'] as String?,
      bio: map['bio'] as String?,
      coins: map['coins'] as int?,
      dailyCoinsLastClaimed: map['daily_coins_last_claimed'] != null
          ? (map['daily_coins_last_claimed'] as Timestamp).toDate()
          : null,
    );
  }
}
