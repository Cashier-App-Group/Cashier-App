// recipe_model.dart
import 'dart:io';

class Profile {
  String nama;
  String email;
  String phone;

  Profile({required this.nama, required this.email, required this.phone});

  factory Profile.fromFirestore(Map<String, dynamic> data) {
    return Profile(
      nama: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}
