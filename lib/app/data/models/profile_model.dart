// recipe_model.dart

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
