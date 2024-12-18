import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Mendefinisikan tema
  var isDarkMode = false.obs;

  // Fungsi untuk toggle tema
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    if (isDarkMode.value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }
}
