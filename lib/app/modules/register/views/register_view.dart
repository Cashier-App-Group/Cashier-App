import 'package:cashier/app/data/models/profile_model.dart';
import 'package:cashier/app/modules/authentication/controllers/auth_controller.dart';
import 'package:cashier/app/modules/home/views/home_view.dart';
import 'package:cashier/app/modules/login/views/login_view.dart';
import 'package:cashier/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  final AuthController authController = Get.put(AuthController());

  // Membuat TextEditingController untuk setiap field
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  RegisterView({Key? key}) : super(key: key);

  Future<void> _submitProfile() async {
    Profile newProfile = Profile(
      nama: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
    );

    await authController.registerUser(
      emailController.text,
      passwordController.text,
      newProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 60,
              ),
              SizedBox(height: 10),
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 0),
              Text(
                'by creating a free account.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 80),
              // Field untuk nama
              Container(
                width: 350,
                height: 55,
                child: TextField(
                  controller: nameController, // Menghubungkan controller
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F2F2),
                    labelText: 'Full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 17.0),
                      child: Image.asset(
                        'assets/name.png',
                        width: 35,
                        height: 35,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Field untuk email
              Container(
                width: 350,
                height: 55,
                child: TextField(
                  controller: emailController, // Menghubungkan controller
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F2F2),
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 17.0),
                      child: Image.asset(
                        'assets/mail.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Field untuk nomor telepon
              Container(
                width: 350,
                height: 55,
                child: TextField(
                  controller: phoneController, // Menghubungkan controller
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F2F2),
                    labelText: 'Phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 17.0),
                      child: Image.asset(
                        'assets/phone.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Field untuk password
              Container(
                width: 350,
                height: 55,
                child: TextField(
                  controller: passwordController, // Menghubungkan controller
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F2F2),
                    labelText: 'Strong password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 17.0),
                      child: Image.asset(
                        'assets/lock.png',
                        width: 35,
                        height: 32,
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
              // Tombol register
              ElevatedButton(
                onPressed: _submitProfile,
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFCD2B21),
                  onPrimary: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 145.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman Login jika sudah memiliki akun
                  Get.to(() => LoginView());
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Already a Cashier? '),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: Color(0xFFCD2B21),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
