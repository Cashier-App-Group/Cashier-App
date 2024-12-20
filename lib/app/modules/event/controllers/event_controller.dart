import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventController extends GetxController {
  var isIdulFitriTheme = false.obs;
  var isKemerdekaanTheme = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isIdulFitriTheme.value = prefs.getBool('isIdulFitriTheme') ?? false;
    isKemerdekaanTheme.value = prefs.getBool('isKemerdekaanTheme') ?? false;
  }

  void saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isIdulFitriTheme', isIdulFitriTheme.value);
    await prefs.setBool('isKemerdekaanTheme', isKemerdekaanTheme.value);
  }

  void toggleIdulFitriTheme(bool value) {
    isIdulFitriTheme.value = value;
    if (value) {
      isKemerdekaanTheme.value = false;
    }
    saveTheme();
  }

  void toggleKemerdekaanTheme(bool value) {
    isKemerdekaanTheme.value = value;
    if (value) {
      isIdulFitriTheme.value = false;
    }
    saveTheme();
  }

  void resetThemes() {
    isIdulFitriTheme.value = false;
    isKemerdekaanTheme.value = false;
    saveTheme();
  }
}
