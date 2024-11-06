import 'package:cashier/app/data/models/profile_model.dart';
import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final profileName = ''.obs;
  RxBool isLoading = false.obs;
  var profiles = <Profile>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  // Fungsi untuk login
  Future<void> loginUser(String email, String password) async {
    try {
      // Menunggu proses login dengan email dan password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Jika login berhasil, arahkan ke CashierView
      if (userCredential.user != null) {
        Get.offAll(
            () => CashierView()); // Mengarahkan ke CashierView setelah login
      }
    } on FirebaseAuthException catch (e) {
      // Menampilkan alert jika terjadi kesalahan
      String errorMessage = 'Terjadi kesalahan. Cek email dan password.';
      if (e.code == 'user-not-found') {
        errorMessage =
            'Pengguna belum terdaftar. Silakan daftar terlebih dahulu.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password salah. Coba lagi.';
      }
      Get.snackbar('Login Gagal', errorMessage,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Fungsi untuk register (optional jika diperlukan di sini)
  Future<void> registerUser(
      String email, String password, Profile profile) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty.',
          backgroundColor: Colors.red);
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('profiles').doc(uid).set({
        'name': profile.nama,
        'email': profile.email,
        'phone': profile.phone
      }, SetOptions(merge: true));

      Get.snackbar('Success', 'Profile successfully created',
          backgroundColor: Colors.green);
      Get.toNamed('/login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar('Error', 'The password provided is too weak.',
            backgroundColor: Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'The account already exists for that email.',
            backgroundColor: Colors.red);
      } else {
        Get.snackbar('Error', 'An error occurred: ${e.message}',
            backgroundColor: Colors.red);
      }
    } catch (error) {
      Get.snackbar('Error', 'Profile creation failed: $error',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
