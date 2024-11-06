import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyDrawerController extends GetxController {
  final scaffoldkey = GlobalKey<ScaffoldState>();

  Rx<String> userName = ''.obs;
  Rx<String> userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          userName.value = doc['name'] ?? 'No Name';
          userEmail.value = doc['email'] ?? 'No Email';
        }
      } catch (e) {
        print('Error fetching user data: $e');
        await Future.delayed(Duration(seconds: 3));
        fetchUserData();
      }
    }
  }

  void closeDrawer() {
    scaffoldkey.currentState?.closeDrawer();
  }
}
